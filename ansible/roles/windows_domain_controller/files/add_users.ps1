$name=$args[0]
$admin=$args[1]
$account_password = $args[2] | ConvertTo-SecureString -asPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential($admin,$account_password)

New-ADUser -Server localhost -Name $name -AccountPassword $account_password -Enabled 1 -Credential $credential
Add-ADGroupMember -Server localhost -Identity "Domain Admins" -Members $name -Credential $credential
