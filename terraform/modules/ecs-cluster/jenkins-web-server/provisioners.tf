resource "null_resource" "jenkins_agent_node" {
  depends_on = [ module.load_balancer, null_resource.wait_for_task_and_fetch_eni ]
  # This will make sure the resource is recreated if the Jenkins URL changes
  triggers = {
    jenkins_url = "http://${module.load_balancer.jenkins_web_dns}"
    runner_count = var.jenkins_runner_count
  }

  provisioner "local-exec" {
    command = <<EOF
      # Wait for Jenkins to be up
      while true; do
        # Get status code from the curl command
        status_code=$(curl -s -o /dev/null -w "%%{http_code}" ${self.triggers.jenkins_url})

        if [ "$status_code" = "200" ] || [ "$status_code" = "403" ]; then
          echo "Jenkins is up with status code $status_code."
          break
        elif [ "$status_code" = "503" ]; then
          echo "Service unavailable (503), continuing to wait..."
        else
          echo "Unexpected status code: $status_code, continuing to wait..."
        fi

        sleep 10
      done

      # Get CSRF token
      CRUMB_AND_COOKIE=$(curl -s -u ${var.jenkins_admin_username}:${var.jenkins_admin_password} "${self.triggers.jenkins_url}/crumbIssuer/api/json" -c cookies.txt)
      CRUMB=$(echo $CRUMB_AND_COOKIE | awk -F ':' '{print $3}' | awk -F ',' '{print $1}' | sed 's/^.\(.*\).$/\1/' | tr -d '[:space:]')

      # Create the agent node
      curl -X POST "${self.triggers.jenkins_url}/computer/doCreateItem" \
      -u ${var.jenkins_admin_username}:${var.jenkins_admin_password} \
      -H "Jenkins-Crumb: $CRUMB" \
      -b cookies.txt \
      --data-urlencode "name=agent1" \
      --data-urlencode "type=hudson.slaves.DumbSlave" \
      --data-urlencode "json={
        'name': 'agent1',
        'nodeDescription': 'Jenkins agent node',
        'numExecutors': '${self.triggers.runner_count}',
        'remoteFS': '/home/jenkins',
        'labelString': 'agent',
        'mode': 'NORMAL',
        'retentionStrategy': {'stapler-class': 'hudson.slaves.RetentionStrategy\$Always'},
        'nodeProperties': {'stapler-class-bag': 'true'},
        'launcher': {
          'stapler-class': 'hudson.slaves.JNLPLauncher',
          'tunnel': '',
          'vmargs': '',
        },
        'jnlpLauncher': {
          'workDirSettings': {
            'disabled': false,
            'failIfWorkDirIsMissing': false,
            'internalDir': 'remoting',
            'stapler-class': 'jenkins.slaves.WorkDirSettings'
            }
          }
        }"
      curl -s -u ${var.jenkins_admin_username}:${var.jenkins_admin_password} \
        "${self.triggers.jenkins_url}/computer/agent1/slave-agent.jnlp" \
        -H "Jenkins-Crumb: $CRUMB" \
        -b cookies.txt | xmllint --xpath '/jnlp/application-desc/argument[1]/text()' - | sed -e 's/<<EOT//' -e 's/EOT//' | tr -d '[:space:]' | tee /tmp/jenkins_output.txt
    EOF
  }
}

data "local_file" "jenkins_output" {
  depends_on = [ null_resource.jenkins_agent_node ]
  filename = "/tmp/jenkins_output.txt"
}

output "agent_secret" {
  value = data.local_file.jenkins_output.content
}