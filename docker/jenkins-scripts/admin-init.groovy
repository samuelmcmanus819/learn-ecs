import jenkins.model.*
import hudson.security.*
import jenkins.security.s2m.AdminWhitelistRule

// Get Jenkins instance
def instance = Jenkins.getInstance()

// Setup security realm to allow Jenkins to manage user authentication
def hudsonRealm = new HudsonPrivateSecurityRealm(false)
def adminUsername = System.getenv("JENKINS_ADMIN_ID")
def adminPassword = System.getenv("JENKINS_ADMIN_PASSWORD")

// Add the admin user
hudsonRealm.createAccount(adminUsername, adminPassword)
instance.setSecurityRealm(hudsonRealm)

// Setup authorization strategy to use Role-Based Access Control (RBAC)
def strategy = new GlobalMatrixAuthorizationStrategy()

// Grant full admin permissions to the admin user
strategy.add(Jenkins.ADMINISTER, adminUsername)

// Disallow anonymous users from accessing the dashboard (i.e., authenticated users only)
strategy.add(Jenkins.READ, 'authenticated')

// Set the authorization strategy
instance.setAuthorizationStrategy(strategy)

// Disable the agent-to-controller security whitelist
Jenkins.instance.injector.getInstance(AdminWhitelistRule.class).setMasterKillSwitch(false)

// Save the Jenkins configuration
instance.save()
