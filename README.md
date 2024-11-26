# OSTH Script for hash submissions

## Description
Basic powershell script that takes inputs from in.txt file, parses it through flag.exe and compares outputs with potential correct answer in answer.txt

## Usage
- transfer `run.ps1` to folder where flag.exe is located (Desktop by default)
- create answer.txt with all given hashes as an answers and in.txt where we input our potential correct answers
- open powershell,  `Set-ExecutionPolicy Bypass` and execute `.\run.ps1`

## run.ps1 content
```powershell
Get-Content "in.txt" | ForEach-Object {
	$output = ./flags.exe $_
	$in = $_
	$matchFound = $false
	Get-Content "answer.txt" | ForEach-Object {
		if ($output -eq $_) {
			Write-Host "[*] Match found for flag: $_ on input $in"
			$matchFound = $true
			break #Break on correct answer, comment if you want to check more flags
		}
	}
	if (-not $matchFound) {
		Write-Host "No match for: $output : $_"
	}
}
```


## Reason
It can be frustrating to find exact timestamp of some event or what specific program threat actor used to do specific action on target. But with this script we can narrow down our KQL to extract potential answers and brute force them until we get correct one.

## example 1
In this example, we are looking for SHA256 hashes of different executables on the system.
![a9cf266eb7a5a5dcfce8c066d1228507.png](_resources/a9cf266eb7a5a5dcfce8c066d1228507.png)

After threat hunting I managed to create following KQL with IOCs of dropped files by threat actor.
```KQL
index=* Hashes=* securitytools OR security_update OR "C:\Windows\Tasks\*" OR "C:\Users\h.jones\Downloads\*" OR mimikatz.exe OR nxc.exe OR winPEASany.exe OR db_exfil.exe OR tickets.exe OR test.log OR dbstatus.exe OR creds.exe OR *.bat OR securitytools.zip | table Hashes | uniq
```
![30f019b1fe38a70f199843cfb7f28838.png](_resources/30f019b1fe38a70f199843cfb7f28838.png)

We input all potential answers to answer.txt file, dump all SHA256 from Splunk output to in.txt file and run script to get answers.
![01f0b66268b8cc3757f8acce656bb360.png](_resources/01f0b66268b8cc3757f8acce656bb360.png)

We got three out of three hits, nice.

## example 2
In the following question, it can be tricky to distinguish what exactly are they looking for an answer.
![a50d2dd3fa9664c4a7140901f1aa9c74.png](_resources/a50d2dd3fa9664c4a7140901f1aa9c74.png)

Following are commands ran by the threat actor
```powershell
"C:\Windows\Tasks\creds.exe" privilege::debug "sekurlsa::minidump lsass.dmp" sekurlsa::logonpasswords exit
"C:\Windows\system32\net.exe" localgroup "Remote Desktop Users" helpdesk_1 /add
"C:\Windows\system32\net.exe" localgroup Administrators helpdesk_1 /add
"C:\Windows\system32\net.exe" user
"C:\Windows\system32\net.exe" user helpdesk_1 Password123 /add
```

So the answer could be new username, new password, name of the lsass dump or something else in other cases. We can break down all possible answers in in.txt file and try to brute force them.
![e6176caf15a746c649fe5b13430b7353.png](_resources/e6176caf15a746c649fe5b13430b7353.png)

Now we can see that they were looking for new username on the host, `helpdesk_1`