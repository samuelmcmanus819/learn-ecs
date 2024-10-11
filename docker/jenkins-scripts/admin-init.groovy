import jenkins.model.*
import hudson.security.*

def instance = Jenkins.getInstance()

// Get the admin user credentials from environment variables
def adminUsername = System.getenv("JENKINS_ADMIN_ID")
def adminPassword = System.getenv("JENKINS_ADMIN_PASSWORD")

println "--> Setting up Security Realm and Authorization Strategy"

// Create admin user if it doesn't exist
def hudsonRealm = new HudsonPrivateSecurityRealm(false)
hudsonRealm.createAccount(adminUsername, adminPassword)
instance.setSecurityRealm(hudsonRealm)

// Set up Global Matrix Authorization Strategy
def strategy = new GlobalMatrixAuthorizationStrategy()

// Grant full admin privileges to the admin user
strategy.add(Jenkins.ADMINISTER, adminUsername)

// Remove ALL permissions for anonymous users to force login
// This removes any default permissions like Jenkins.READ
println "--> Revoking all permissions for anonymous users"
strategy.add(Jenkins.READ, "authenticated") // Only authenticated users can read

// Apply the new strategy to Jenkins
instance.setAuthorizationStrategy(strategy)
instance.save()

println "--> Admin user ${adminUsername} has been granted full access."
println "--> Anonymous users will
