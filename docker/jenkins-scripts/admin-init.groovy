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

// Set up Role-Based Authorization Strategy
def rbas = new RoleBasedAuthorizationStrategy()

// Define the Admin role with all permissions
def adminPermissions = Permission.getAll() // Grants all permissions
def adminRole = new Role("admin", adminPermissions)

// Add Admin role to global roles
rbas.addRole(RoleBasedAuthorizationStrategy.GLOBAL, adminRole)

// Assign the Admin user to the Admin role
rbas.assignRole(RoleBasedAuthorizationStrategy.GLOBAL, adminRole, adminUsername)

// Apply the RBAC strategy to Jenkins
instance.setAuthorizationStrategy(rbas)
instance.save()

println "--> Admin user ${adminUsername} assigned to the Admin role."
