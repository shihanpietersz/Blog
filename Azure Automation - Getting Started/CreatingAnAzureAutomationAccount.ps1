[cmdletbinding()]
param(
[parameter(ValueFromPipeline=$True,ValueFromPipelineByPropertyName=$True,Mandatory=$True)]
[String]$AutomationAccountName,
[parameter(ValueFromPipeline=$True,ValueFromPipelineByPropertyName=$True,Mandatory=$True)]
[String]$ResourceGroupName,
[parameter(ValueFromPipeline=$True,ValueFromPipelineByPropertyName=$True,Mandatory=$True)]
[String]$Location,
[parameter(ValueFromPipeline=$True,ValueFromPipelineByPropertyName=$True,Mandatory=$false)]
[validateset("Free","Basic")]
[String]$Plan = "Free",
[parameter(ValueFromPipeline=$True,ValueFromPipelineByPropertyName=$True,Mandatory=$false)]
[hashtable]$Tags
)

BEGIN{
    #Test if AzureRM Mdoule is Installed
    function Get-AzureModuleStatus {
        [cmdletbinding()]
        param()
        Write-Verbose "[$((get-date).TimeOfDay.ToString()) BEGIN ] Checking if AZ Module is installed"
        Remove-module AZ -ErrorAction SilentlyContinue
        Import-Module -Name AZ -ErrorAction SilentlyContinue
        $InstalledAzureAZModuleVersion = Get-Module -Name AZ
        if($InstalledAzureAZModuleVersion.count -ne 0){
            $CurrentAzureAZModuleVersion = find-module -name AZ
            if($InstalledAzureAZModuleVersion.Version -ne $CurrentAzureAZModuleVersion.Version){
                Write-Verbose "[$((get-date).TimeOfDay.ToString()) BEGIN ] New Version $($CurrentAzureAZModuleVersion.Version) of Azure AZ Module Found"
                Write-Host "Current Version is $($CurrentAzureAZModuleVersion.Version)" -ForegroundColor Green
                Write-Host "Installed Module Version $($InstalledAzureAZModuleVersion.Version)" -ForegroundColor Red
                Update-module -Name AZ -Scope CurrentUser -Confirm:$false -force
                Remove-module AZ -ErrorAction SilentlyContinue
                Get-AzureModuleStatus -verbose
            }#END_IF_ModuleVersioncheck
            else{
               Write-Verbose "[$((get-date).TimeOfDay.ToString()) BEGIN ] AZ Module is upto date"
            }#END_else
        }#END_if_InstalledAzureRMModuleVersion
        else{
            Write-Verbose "[$((get-date).TimeOfDay.ToString()) BEGIN ] Azure AZ Module not found Installing Now"
            Install-module -Name AZ -Scope CurrentUser -Confirm:$false -Force
            Remove-module AZ -ErrorAction SilentlyContinue
            Get-AzureModuleStatus -verbose
        }#END_Else
    }#END_Function_AzureRMModuleStatus
    Get-AzureModuleStatus -verbose
}#END_BEGIN
PROCESS{
    if ([string]::IsNullOrEmpty($(Get-AzContext).Account)) {Login-AzAccount}
    $ResourceGroup = Get-AzResourceGroup -Name $ResourceGroupName -ErrorAction SilentlyContinue
    if($ResourceGroup.ResourceGroupName -ne "$ResourceGroupName"){
        do {
            $Answer = read-host -Prompt "$($ResourceGroupName) does not exists. Do you want to create it now ? Y or N"
        switch($Answer){
            "Y"{
                New-AzResourceGroup -Name $ResourceGroupName -Location $Location -Tag $Tags -Force
            }
            "N"{
                Write-Host "Exiting Script"
                exit
            }
            default{
                Write-Host "Select Y or N"
            }
        }#EndSwtich
        }until ($Answer -eq 'Y' -or $Answer -eq 'N')

    }#END_IF_ResourceGroup
    $ResourceGroup = Get-AzResourceGroup -Name $ResourceGroupName -ErrorAction SilentlyContinue
    if($ResourceGroupName){
        New-AzAutomationAccount -ResourceGroupName $ResourceGroupName -Name $AutomationAccountName -Location $Location -Plan $Plan -Tags $Tags
    }

}#END_PROCESS
END{

}#END_END
