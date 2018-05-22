<powershell>


write-output "Running User Data Script"
write-host "(host) Running User Data Script"

Set-ExecutionPolicy Unrestricted -Scope LocalMachine -Force -ErrorAction Ignore

# Don't set this before Set-ExecutionPolicy as it throws an error
$ErrorActionPreference = "stop"

# Remove HTTP listener
Remove-Item -Path WSMan:\Localhost\listener\listener* -Recurse

Set-Item WSMan:\localhost\MaxTimeoutms 1800000
Set-Item WSMan:\localhost\Service\Auth\Basic $true

Enable-PSRemoting -force
Set-Item WSMan:\localhost\Client\trustedhosts -value * -force

$Cert = New-SelfSignedCertificate -CertstoreLocation Cert:\LocalMachine\My -DnsName "packer"
New-Item -Path WSMan:\LocalHost\Listener -Transport HTTPS -Address * -CertificateThumbPrint $Cert.Thumbprint -Force

# WinRM
write-output "Setting up WinRM"
write-host "(host) setting up WinRM"

cmd.exe /c winrm quickconfig -q
cmd.exe /c winrm set "winrm/config" '@{MaxTimeoutms="1800000"}'
cmd.exe /c winrm set "winrm/config/winrs" '@{MaxMemoryPerShellMB="1024"}'
cmd.exe /c winrm set "winrm/config/service" '@{AllowUnencrypted="true"}'
cmd.exe /c winrm set "winrm/config/client" '@{AllowUnencrypted="true"}'
cmd.exe /c winrm set "winrm/config/service/auth" '@{Basic="true"}'
cmd.exe /c winrm set "winrm/config/client/auth" '@{Basic="true"}'
cmd.exe /c winrm set "winrm/config/service/auth" '@{CredSSP="true"}'
cmd.exe /c winrm set "winrm/config/listener?Address=*+Transport=HTTPS" "@{Port=`"5986`";Hostname=`"packer`";CertificateThumbprint=`"$($Cert.Thumbprint)`"}"
cmd.exe /c netsh advfirewall firewall set rule group="remote administration" new enable=yes
cmd.exe /c netsh advfirewall firewall add rule name="Open Port 5986" dir=in action=allow protocol=TCP localport=5986
cmd.exe /c netsh advfirewall firewall add rule name="Open Port 22" dir=in action=allow protocol=TCP localport=22
cmd.exe /c net stop winrm
cmd.exe /c sc config winrm start= auto
cmd.exe /c net start winrm


#
#
#write-output "Running User Data Script"
#write-host "(host) Running User Data Script"
#
## turn off PowerShell execution policy restrictions
#Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope LocalMachine
#
## configure WinRM
#winrm quickconfig -q
#winrm set winrm/config/winrs '@{MaxMemoryPerShellMB="0"}'
#winrm set winrm/config '@{MaxTimeoutms="7200000"}'
#winrm set winrm/config/service '@{AllowUnencrypted="true"}'
#winrm set winrm/config/service/auth '@{Basic="true"}'
#
## open port 5985 in the internal Windows firewall to allow WinRM communication
#netsh advfirewall firewall add rule name="WinRM 5985" protocol=TCP dir=in localport=5985 action=allow
#
#winrm quickconfig -transport:http
#winrm set winrm/config '@{MaxTimeoutms="7200000"}'
#winrm set winrm/config/winrs '@{MaxMemoryPerShellMB="0"}'
#winrm set winrm/config/winrs '@{MaxProcessesPerShell="0"}'
#winrm set winrm/config/winrs '@{MaxShellsPerUser="0"}'
#winrm set winrm/config/service '@{AllowUnencrypted="true"}'
#winrm set winrm/config/service/auth '@{Basic="true"}'
#winrm set winrm/config/client/auth '@{Basic="true"}'
#winrm set winrm/config/listener?Address=*+Transport=HTTP '@{Port="5985"} '
#
#netsh advfirewall firewall set rule group="remote administration" new enable=yes
#netsh firewall add portopening TCP 5985 "Port 5985"
#net stop winrm
#sc.exe config winrm start= auto
#net start winrm
#
#Write-Host "Disabling UAC..."
#New-ItemProperty -Path HKLM:Software\Microsoft\Windows\CurrentVersion\Policies\System -Name EnableLUA -PropertyType DWord -Value 0 -Force
#New-ItemProperty -Path HKLM:Software\Microsoft\Windows\CurrentVersion\Policies\System -Name ConsentPromptBehaviorAdmin -PropertyType DWord -Value 0 -Force

</powershell>
