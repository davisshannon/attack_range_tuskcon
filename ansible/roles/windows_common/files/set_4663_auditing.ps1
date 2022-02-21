$TargetFolders = "C:\Files"
$AuditUser = "Everyone"
$AuditRules = "FullControl"
$InheritType = "ContainerInherit,ObjectInherit"
$AuditType = "Success,Failure"
$AccessRule = New-Object System.Security.AccessControl.FileSystemAuditRule($AuditUser,$AuditRules,$InheritType,"None",$AuditType)
foreach ($TargetFolder in $TargetFolders)
{
    $ACL = Get-Acl $TargetFolder
    $ACL.SetAuditRule($AccessRule)
    Write-Host "Processing >",$TargetFolder
    $ACL | Set-Acl $TargetFolder
} 
