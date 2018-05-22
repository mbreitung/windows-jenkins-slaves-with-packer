<powershell>

# Set administrator password
net user Administrator Ryp7PBeBm6Cde6F3
wmic useraccount where "name='Administrator'" set PasswordExpires=FALSE

mkdir c:\Jenkins

write-output "Starting Jenkins slave ... "
write-host "(host) Starting Jenkins slave  ... "

$url = "https://ci.draios.com/computer/windows-64-builder/slave-agent.jnlp"
#Start-Process java -ArgumentList '-jar', 'slave.jar', '-jnlpUrl', $url, '-jnlpCredentials', 'windows-slave:sysdigletmein'  -RedirectStandardOutput '.\console.out' -RedirectStandardError '.\console.err'
Start-Process java -ArgumentList '-jar', 'slave.jar', '-jnlpUrl', $url, -RedirectStandardOutput '.\console.out' -RedirectStandardError '.\console.err'

</powershell>
<persist>true</persist>