function Remove-AzPimAssignment {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$PrincipalId,
        
        [Parameter(Mandatory = $false)]
        [string]$Scope,
        
        [Parameter(Mandatory)]
        [string]$RoleDefinitionId,

        [Parameter(Mandatory = $false)]
        [string]$ApiVersion = "2020-10-01"
    )

    process {

        # Checking Azure Context
        try {
            $ctx = Get-AzContext
        }
        catch {
            Write-Warning "Could not get Azure Context: $($error[0].Exception.Message)"
            return $false
        }

        # Sanitize Scope (Remove trailing /providers...until line ending)
        $Scope = $Scope -replace "/providers/Microsoft.Authorization/roleEligibilitySchedules/.*"

        $guid = (New-Guid).Guid

        $Properties = [ordered]@{RoleDefinitionId = $RoleDefinitionId; PrincipalId = $PrincipalId; RequestType = "AdminRemove" }
        $payload = [ordered]@{Properties = $properties }

        
        try {
            $restParam = @{
                Method  = "PUT"
                Payload = $($payload | ConvertTo-Json)
            }

            # Check if scope is subscription
            $regex = '^[0-9a-f]{8}-([0-9a-f]{4}-){3}[0-9a-f]{12}$'
            if ([regex]::IsMatch($Scope, $regex)) {
                # if scope is subscription id
                $restParam.Add("SubscriptionId", $Scope)
                $restParam.Add("ApiVersion", "2020-10-01")
                $restParam.Add("ResourceProviderName", "Microsoft.Authorization")
                $restParam.Add("ResourceType", "roleEligibilityScheduleRequests")
                $restParam.Add("Name", $guid)
            }
            elseif (!($scope)) {
                # else if: no scope provided, using sub id
                $restParam.Add("SubscriptionId", $ctx.Subscription.Id)
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