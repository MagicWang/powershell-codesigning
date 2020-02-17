#Requires -RunAsAdministrator

Function script:New-CodeSigningCert {
[CmdletBinding()]
Param(
	[Parameter(Mandatory=$True,HelpMessage="Certificate subject name")]
	[String]$Subject,
	
	[Parameter(Mandatory=$True,HelpMessage="Certificate e-mail address")]
	[string]$EMail,
	
	[Parameter(Mandatory=$True,HelpMessage="Certificate friendly name")]
	[string]$FriendlyName,
	
	[Parameter(Mandatory=$True,HelpMessage="Certificate PFX password for export")]
	[string]$PFXPassword,
	
	[Parameter(HelpMessage="Certificate export path")]
	$CertFilePath,
	
	[Parameter(HelpMessage="Certificate validity in years")]
	[int]$CertValidYears,
	
	[Parameter(HelpMessage="Certificate e-mail address")]
	$SubjectFull = "CN=$Subject,E=$EMail"
)
$SecurePassword = ConvertTo-SecureString -String $PFXPassword -AsPlainText -Force

#Generate certificate
$CodeSigningCert = New-SelfSignedCertificate -Type CodeSigningCert -KeyUsage DigitalSignature -KeyAlgorithm RSA -CertStoreLocation "Cert:\CurrentUser\My" -Subject $SubjectFull -NotAfter $(Get-Date).AddYears($CertValidYears) -FriendlyName $FriendlyName

#Export certificate
Export-PfxCertificate -Cert $CodeSigningCert -FilePath $CertFilePath\$FriendlyName.pfx -Password $SecurePassword

#Install cert in root store so it is trusted - Requires RunAsAdministrator in script usage
Import-PfxCertificate -FilePath $CertFilePath\$FriendlyName.pfx -CertStoreLocation "Cert:\LocalMachine\Root\" -Password $SecurePassword
} #End New-CodeSigningCert


New-CodeSigningCert -Subject "Tyler Applebaum Code Signing Cert" -EMail "tylerapplebaum@gmail.com" -PFXPassword "1234" -FriendlyName "PSCodeSigningTest" -CertValidYears 5 -CertFilePath $([Environment]::GetFolderPath("Desktop"))