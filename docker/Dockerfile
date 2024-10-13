FROM jenkins/jenkins:jdk17
USER root
# Install Docker
RUN apt-get update && apt-get install -y lsb-release --no-install-recommends
RUN curl -fsSLo /usr/share/keyrings/docker-archive-keyring.asc \
  https://download.docker.com/linux/debian/gpg
RUN echo "deb [arch=$(dpkg --print-architecture) \
  signed-by=/usr/share/keyrings/docker-archive-keyring.asc] \
  https://download.docker.com/linux/debian \
  $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list
RUN apt-get update && apt-get install -y docker-ce-cli --no-install-recommends
USER jenkins
# Download the blue ocean and docker-workflow plugins
RUN jenkins-plugin-cli --plugins "blueocean docker-workflow"
# Copy the admin user startup script
COPY docker/jenkins-scripts/admin-init.groovy /usr/share/jenkins/ref/init.groovy.d/admin-user.groovy
# Don't run the setup wizard
ENV JAVA_OPTS -Djenkins.install.runSetupWizard=false