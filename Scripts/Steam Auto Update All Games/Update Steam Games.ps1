#########
# Update Steam Games
#########

# Steam variables
$SteamRegKey = "HKLM:\SOFTWARE\WOW6432Node\Valve\Steam"
$InstallPath = (Get-ItemProperty -Path $SteamRegKey -Name "InstallPath").InstallPath
$SteamLibraryFolders = "$InstallPath\steamapps\libraryfolders.vdf"

# Read the content of the libraryfolders.vdf
$SteamLibraryFoldersFile = Get-Content -Path $SteamLibraryFolders

# Use a regular expression to find all "path" nodes
$Paths = [regex]::Matches($SteamLibraryFoldersFile, '"path"\s+"([^"]+)"')

$CorrectedPaths = @()
# Display the paths
foreach ($Path in $Paths) {
    Write-Output $Path.Groups[1].Value
    
    $CorrectedPaths += $Path.Groups[1].Value -replace '\\\\', '\'
}

foreach ($Entry in $CorrectedPaths) {
    $Files = Get-ChildItem -Path "$entry\steamapps" -Filter *.acf
    
    foreach ($File in $Files) {
        $Content = Get-Content -Path $File.FullName
        $UpdatedContent = $Content -replace '	"AutoUpdateBehavior"		"0"', '	"AutoUpdateBehavior"		"2"'
        Set-Content -Path $file.FullName -Value $UpdatedContent
    }

}
