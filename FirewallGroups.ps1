# FirewallGroups.ps1 - Written by Sean Worsley on 6/10/2013
# A script which uses a specified sqlite database to store relations between hosts and groups

# Requires the sqlite powershell module to be installed. Download from http://psqlite.codeplex.com/
# Written with Powershell 3.0

# Declare all parameters
param(
	[string]$dbPath = ""
)

# Load required powershell modules
Import-Module sqlite

# Load supporting functions. Assumes functions are located in the same directory
$curPath = Get-Location
. $curPath\CRUD.ps1

# Globals
$sqliteDriveName = "db"

# Set default dbPath if no DB specified
if ($dbPath -eq "") {
	Write-Host "No DB argument specified, searching for db locally..."
	$curPath = Get-Location
	$dbName = "db.sqlite"
	$dbPath = "$curPath\$dbName"
	
	$dbExists = Test-Path $dbPath
	if ($dbExists) {
		mount-sqlite -name $sqliteDriveName -dataSource $dbPath
	} else {
		Write-Host "No local DB found. Creating new Database and initialising tables"
		# Init DB with default database tables
		mount-sqlite -name $sqliteDriveName -dataSource $dbPath
		New-Item db:\grp -Value @{ grpname="TEXT NOT NULL" } | Out-Null
		New-Item db:\hosts -Value @{ hostname="TEXT"; ipv4="TEXT NOT NULL" } | Out-Null
		New-Item db:\grphosts -Value @{ parentid="INTEGER NOT NULL"; childid="INTEGER NOT NULL"; g2g="BOOLEAN NOT NULL" } | Out-Null
	}
	
} else {
	mount-sqlite -name $sqliteDriveName -dataSource $dbPath
}

# Main Menu
while ($true) {
	$title = "Firewall Database"
	$message = "What would you like to do?"
	$add = New-Object System.Management.Automation.Host.ChoiceDescription "&Add", `
		"Add an entry to the database."
	$remove = New-Object System.Management.Automation.Host.ChoiceDescription "&Remove", `
		"Remove an entry from the database."
	$inspect = New-Object System.Management.Automation.Host.ChoiceDescription "&Inspect", `
		"Inspect current entries"
	$quit = New-Object System.Management.Automation.Host.ChoiceDescription "&Quit", `
		"Quit"
	$options = [System.Management.Automation.Host.ChoiceDescription[]]($add, $remove, $inspect, $quit)

	$result = $host.ui.PromptForChoice($title, $message, $options, 0) 

	switch ($result)
		{
			0 
			{	
				$ipaddr = Read-Host "Enter the ipaddress to add"
				$hostname = Read-Host "Enter the hostname to add (Optional)"
				addHostEntry($ipaddr,$hostname)
			}
			1 {"You selected Remove."}
			2 {"You selected Inspect."} 
			3 
			{
				"Cleaning up and Exiting"
				$driveStatus = Get-PSDrive | select Name | where { $_.name -eq $sqliteDriveName}
				if ($driveStatus -ne $null) {
					Remove-PSDrive $sqliteDriveName
				}
				Exit
			}
		}

}