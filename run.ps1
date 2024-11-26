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
