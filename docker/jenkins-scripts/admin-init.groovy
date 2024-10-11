import jenkins.model.*
import hudson.security.*

def instance = Jenkins.getInstance()

def adminUsername = System.getenv("JENKINS_ADMIN_ID")
def adminPassword = System.getenv("JENKINS_ADMIN_PASSWORD")

if (adminUsername && adminPassword) {
    def hudsonRealm = new HudsonPrivateSecurityRealm(false)
    hudsonRealm.createAccount(adminUsername, adminPassword)
    instance.setSecurityRealm(hudsonRealm)

    def strategy = new FullControlOnceLoggedInAuthorizationStrategy()
    instance.setAuthorizationStrategy(strategy)
    instance.save()

    println "--> Admin user ${adminUsername} created."
} else {
    println "--> Admin credentials not provided, skipping user creation."
}