#########
# Create Scheduled Task
#########

# Define the path to the PowerShell script you want to run at login
$CurrentScriptPath = Join-Path -Path (Split-Path -Parent $MyInvocation.MyCommand.Definition) -ChildPath "Update Steam Games - Create Scheduled Task.ps1"
$ScheduledTaskScriptPath = Join-Path -Path (Split-Path -Parent $MyInvocation.MyCommand.Definition) -ChildPath "Update Steam Games.ps1"

# Define the name of the scheduled task
$TaskName = "UpdateSteamGamesImmediately"

# Define the folder for the scheduled task
$TaskFolder = "Steam"

# Function to check if the script is running with admin rights
function Test-Admin {
    $currentUser = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    return $currentUser.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

# Relaunch the script with admin rights if not already running as admin
if (-not (Test-Admin)) {
    Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$CurrentScriptPath`"" -Verb RunAs
    exit
}

# Check if the scheduled task already exists
$TaskExists = Get-ScheduledTask -TaskName $TaskName -TaskPath "\$TaskFolder\" -ErrorAction SilentlyContinue

if ($TaskExists) {
    Write-Host "Scheduled task already exists. No action taken."
    Pause
} else {
    # Create the scheduled task
    $Action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-NoProfile -ExecutionPolicy Bypass -File `"$ScheduledTaskScriptPath`""
    $Trigger = New-ScheduledTaskTrigger -AtLogOn
    $Principal = New-ScheduledTaskPrincipal -UserId "$env:USERNAME" -LogonType Interactive -RunLevel Highest
    $Settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable

    Register-ScheduledTask -Action $Action -Trigger $Trigger -Principal $Principal -Settings $Settings -TaskName $TaskName -TaskPath "\$TaskFolder\" -Force

    Write-Host "Scheduled task created successfully in the 'Steam' folder!"
    Pause
}