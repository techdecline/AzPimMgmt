function Get-AzPimAssignment {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)]
        [string]$Scope
    )

    # Checking Azure Context
    try {
        $ctx = Get-AzContext
    }
    catch {
        Write-Warning "Could not get Azure Context: $($error[0].Exception.Message)"
        return $false
    }

    if (!($Scope)) {
        Write-Verbose "No Scope has been identified, using current Subscription"
        $Scope = "/subscriptions/$($ctx.Subscription.Id)"
    }
    try {
        return (Get-AzResource -ResourceId "$Scope/providers/Microsoft.Authorization/roleEligibilitySchedules" -ApiVersion "2020-10-01" -ExpandProperties | `
                Select-Object -Property @{Name = 'SubscriptionName'; Expression = { $ctx.Subscription.Name } },
            @{Name = 'SubscriptionId'; Expression = { $ctx.Subscription.Id } },
            @{Name = "RoleDefinitionName"; Expression = { (Get-AzRoleDefinition -Id ($_.Properties.RoleDefinitionId -split "/")[-1]).Name } },
            @{Name = 'PrincipalName'; Expression = { Get-MgIdentityName -IdentityType $_.Properties.PrincipalType -IdentityId $_.Properties.PrincipalId } },
            @{Name = 'PrincipalId'; Expression = { $_.Properties.PrincipalId } },
            @{Name = 'RoleDefinitionId'; Expression = { $_.Properties.RoleDefinitionId } }, 
            ResourceId)
    }
    catch {
        Write-Warning "Could not get Azure PIM Assignments: $($error[0].Exception.Message)"
        return $false
    }
}
