# Implement your module commands in this script.
. ./function-Get-AzPimAssignment.ps1
. ./function-Remove-AzPimAssignment.ps1
. ./function-Add-AzPimAssignment.ps1

# Export only the functions using PowerShell standard verb-noun naming.
# Be sure to list each exported functions in the FunctionsToExport field of the module manifest file.
# This improves performance of command discovery in PowerShell.
Export-ModuleMember -Function Get-AzPimAssignment, Remove-AzPimAssignment, Add-AzPimAssignment
