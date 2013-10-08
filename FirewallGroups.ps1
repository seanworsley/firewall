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

# Load supporting function. Assumes functions are located in the same directory
.{.\CRUD.ps1}

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
		New-Item db:\grp -Value @{ name="TEXT NOT NULL"; parentid="INTEGER" } | Out-Null
		New-Item db:\hosts -Value @{ hostname="TEXT"; ipv4="TEXT NOT NULL"; parentid="INTEGER" } | Out-Null
		New-Item db:\relns -Value @{ parentid="INTEGER NOT NULL"; childid="INTEGER NOT NULL" } | Out-Null
	}
	
} else {
	mount-sqlite -name $sqliteDriveName -dataSource $dbPath
}

# Main Menu
$title = "Firewall Database"
$message = "What would you like to do?"
$add = New-Object System.Management.Automation.Host.ChoiceDescription "&Add", `
    "Add an entry to the database."
$remove = New-Object System.Management.Automation.Host.ChoiceDescription "&Remove", `
    "Remove an entry from the database."
$inspect = New-Object System.Management.Automation.Host.ChoiceDescription "&Inspect", `
	"Inspect current entries"
$options = [System.Management.Automation.Host.ChoiceDescription[]]($add, $remove, $inspect)

$result = $host.ui.PromptForChoice($title, $message, $options, 0) 

switch ($result)
    {
        0 {"You selected Add."}
        1 {"You selected Remove."}
		2 {"You selected Inspect."} 
    }


# Cleanup
$driveStatus = Get-PSDrive | select Name | where { $_.name -eq $sqliteDriveName}
if ($driveStatus -ne $null) {
	Remove-PSDrive $sqliteDriveName
}