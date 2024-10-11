import jenkins.model.*
import hudson.security.*
import com.michelin.cio.hudson.plugins.rolestrategy.*

// Get Jenkins instance
def instance = Jenkins.getInstance()

// Get the admin user from environment variables
def adminUsername = System.getenv("JENKINS_ADMIN_ID")
def adminPassword = System.getenv("JENKINS_ADMIN_PASSWORD")

println "--> Setting up Role-Based Authorization Strategy"

// Create the admin user if not exists
def hudsonRealm = new HudsonPrivateSecurityRealm(false)
hudsonRealm.createAccount(adminUsername, adminPassword)
instance.setSecurityRealm(hudsonRealm)

// Set up Global Matrix Authorization Strategy (RBAC)
def strategy = new GlobalMatrixAuthorizationStrategy()

// Grant full control to the admin user
strategy.add(Jenkins.ADMINISTER, adminUsername)

// Restrict anonymous access (unauthenticated users)
strategy.add(Jenkins.READ, "anonymous")

// Apply the authorization strategy
instance.setAuthorizationStrategy(strategy)
instance.save()

println "--> Admin user ${adminUsername} has been granted full access."
println "--> Anonymous users will be forced to log in."
