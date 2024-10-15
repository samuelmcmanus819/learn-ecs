# Step 1: Create a WAF Web ACL
resource "aws_wafv2_web_acl" "jenkins_web_acl" {
  name        = "jenkins-web-acl"
  scope       = "REGIONAL" # Set to "CLOUDFRONT" if you're using CloudFront
  description = "Web ACL for ALB"

  default_action {
    allow {}
  }

  rule {
    name     = "AWS-AWSManagedRulesCommonRuleSet"
    priority = 1

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = false
      metric_name                = "waf-common-rule-set"
      sampled_requests_enabled   = false
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = false
    metric_name                = "my-web-acl"
    sampled_requests_enabled   = false
  }
}
