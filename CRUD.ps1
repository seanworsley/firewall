# CRUD.ps1 - Written by Sean Worsley on 8/10/2013
# Supporting functions for adding and removing entries from the database 
# Lack of overloading in Powershell seems to be preventing me from centralising duplicate checking code.

# addHostEntry - A function to add a host to the database
# If supplied with a parent argument, creates relevant relationships within the database
Function addHostEntry($ipaddr, $hostname="", $parentName) {
	# Check for duplicate
	# TODO
	
	# Add the new entry
	
}

# addGroupEntry - A function to add a new group
Function addGroupEntry($name) {

}