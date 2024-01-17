function Add-AzPimAssignment {
    [CmdletBinding()]
    param (
        [string]$PrincipalId,
        [string]$Scope,
        [string]$RoleDefinitionId,
        [string]$ApiVersion = "2020-10-01"
    )

    process {
        $guid = (New-Guid).Guid

        $Properties = [ordered]@{RoleDefinitionId = $RoleDefinitionId; PrincipalId = $PrincipalId; RequestType = "AdminAssign" }
        $payload = [ordered]@{Properties = $properties }

        
        try {
            $restParam = @{
                Method  = "post"
                Payload = $($payload | ConvertTo-Json)
            }

            # Check if scope is subscription
            $regex = '^[0-9a-f]{8}-([0-9a-f]{4}-){3}[0-9a-f]{12}$'
            if ([regex]::IsMatch($Scope, $regex)) {
                $restParam.Add("SubscriptionId", $Scope)
                $restParam.Add("ApiVersion", "2020-10-01")
                $restParam.Add("ResourceProviderName", "Microsoft.Authorization")
                $restParam.Add("ResourceType", "roleEligibilityScheduleRequests")
                $restParam.Add("Name", $guid)
            }
            else {
                $restParam.Add("Path", "$Scope/providers/Microsoft.Authorization/roleEligibilityScheduleRequests/$($guid)?api-version=$($ApiVersion)")
                Write-Verbose $restParam.Path
            }
            
            $restResult = Invoke-AzRestMethod @restParam
            if ($restResult.StatusCode -eq "201") {
                return $true
            }
            else {
                Write-Warning $restResult.Content
                return $false
            }
        }
        catch {
            throw "Could not remove PIM Assignment: $($Error[0].Exception.Message)"
        }
    }
}