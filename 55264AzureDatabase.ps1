### Create an Azure SQL server and databases.  If your subscription resources allow, keep these databases for future labs.
### Change the first variable below ($SubscriptionName) to your actual subscription name.

### Configure Objects & Variables
$SubscriptionName = "Azure Pass"     # Replace with the name of your Azure Subscription
Set-StrictMode -Version 2.0
Set-Item Env:\SuppressAzurePowerShellBreakingChangeWarnings "true"
$ExternalIP = ((Invoke-WebRequest -URI IPv4.Icanhazip.com -UseBasicParsing).Content).Trim()                                          # You may substitute with the Internet IP of your computer
$WorkFolder = "C:\Labfiles.55264\Tools\"
Set-Location $WorkFolder
If (Get-Module -ListAvailable -Name SQLServer) {Write-Output "SQLServer module already installed" ; Import-Module SQLServer} Else {Install-Module -Name SQLServer -Force ; Import-Module -Name SQLServer}
$SQLLogin1 = "sqllogin1"
$Password = 'Pa$$w0rdPa$$w0rd'
$PW = Write-Output $Password | ConvertTo-SecureString -AsPlainText -Force        # Password for SQL Database server
$SQLCredentials =  (New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $SQLLogin1, $PW)
$Location = "EASTUS"
$NamePrefix = "in" + (Get-Date -Format "HHmmss")       # Replace "in" with your initials.  Date information is added in this example to help make the names unique
$ResourceGroupName = $NamePrefix.ToLower() + "rg"
$StorageAccountName = $NamePrefix.ToLower() + "sa"     # Must be lower case
$AzureServer = "mia-sql" + $NamePrefix.ToLower()
$AzureServerDNS = $AzureServer + ".database.windows.net"
$AdventureWorksDatabase = "adventureworks"
$DB1Database = "database001"
$AdventureWorksConnectionString = "Server=tcp:$AzureServerDNS;Database=$AdventureWorksDatabase;User ID=$SQLLogin1@$AzureServer;Password=$Password;Trusted_Connection=False;Encrypt=True;"
$DB1ConnectionString = "Server=tcp:$AzureServerDNS;Database=$DB1Database;User ID=$SQLLogin1@$AzureServer;Password=$Password;Trusted_Connection=False;Encrypt=True;"
$SAShare = "55264"                                    # Must be lower case
$TMPData = $WorkFolder + "employees.tmp"
$SQLData = $WorkFolder + "employees.sql"
$CustomerCSV = $WorkFolder + "customer.csv"
# Manually configured Variables
$ResourceGroupNameAAD = "azad55264rg"

### Log start time of script
$logFilePrefix = "55264AzureDatabase" + (Get-Date -Format "HHmm") ; $logFileSuffix = ".txt" ; $StartTime = Get-Date
"Create Azure Server and Database"   >  $WorkFolder$logFilePrefix$logFileSuffix
"Start Time: " + $StartTime >> $WorkFolder$logFilePrefix$logFileSuffix

# Install PowerShell Modules
If ((Get-PSRepository -Name PSGallery).InstallationPolicy = "Trusted") {Write-Output "PSGallery is already a trusted repository"} Else {Set-PSRepository -Name PSGallery -InstallationPolicy Trusted}
If (Get-PackageProvider -Name NuGet) {Write-Output "NuGet PackageProvider already installed."} Else {Install-PackageProvider -Name "NuGet" -Force -Confirm:$False}
If (Get-Module -ListAvailable -Name PowerShellGet) {Write-Output "PowerShellGet module already installed"} Else {Find-Module PowerShellGet -IncludeDependencies | Install-Module -Force}
If (Get-Module -ListAvailable -Name Az.*) {Write-Output "PowerShellGet module already installed"} Else {Find-Module Az -IncludeDependencies | Install-Module -Force ; Import-Module -Name Az}
If (Get-Module -ListAvailable -Name SQLServer) {Write-Output "SQLServer module already installed" ; Import-Module SQLServer} Else {Install-Module -Name SQLServer -AllowClobber -Force ; Import-Module -Name SQLServer}
Register-AzResourceProvider -ProviderNamespace Microsoft.Batch

### Login to Azure
<#
# You may use the automated login credentials of AzureAdmin1@<domain> if they were configured at the beginning of the class
$AzureAdminName = "AzureAdmin1"
$SecurePassword = Write-Output "Password:123" | ConvertTo-SecureString -AsPlainText -Force
$Sub = Import-CliXML $WorkFolder"Subscription.xml"
$AzureAdminUPN = $AzureAdminName + "@" + $Sub.Tenant.Directory
$AZCredentials = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $AzureAdminName, $SecurePassword
$ADCredentials = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $AzureAdminUPN, $SecurePassword
Connect-AzureRMAccount -TenantID $Sub.Subscription.TenantID -ServicePrincipal -Credential $AZCredentials
$Subscription = Get-AzureRMSubscription -SubscriptionName $SubscriptionName | Set-AzureRMContext
$AzureAD = Connect-AzureAD -TenantID $Sub.Tenant.ID -Credential $ADCredentials
$Domain = (Get-AzureADDomain)[0]
#>
Connect-AzAccount
$Subscription = Get-AzSubscription -SubscriptionName $SubscriptionName | Select-AzSubscription

### Create Resource Group, Storage Account & Storage Account Share
$ResourceGroup = New-AzResourceGroup -Name $ResourceGroupName  -Location $Location
$StorageAccount = New-AzStorageAccount -ResourceGroupName $ResourceGroupName -Name $StorageAccountName -Location $location -Type Standard_RAGRS
$StorageAccountKey = (Get-AzStorageAccountKey -ResourceGroupName $ResourceGroupName -Name $StorageAccountName)[0].Value
$StorageAccountContext = New-AzStorageContext -StorageAccountName $StorageAccountName -StorageAccountKey $StorageAccountKey
$BlobContainer = New-AzStorageContainer -Name $SAShare.ToLower() -Context $StorageAccountContext -Permission Container -Verbose
$BlobLocation = $BlobContainer.cloudblobcontainer.Uri.AbsoluteUri
Get-ChildItem -File $WorkFolder"employees.*" | Set-AzStorageBlobContent -Container $SAShare -Context $StorageAccountContext -Force

### Create Azure Database Server
$AzureSQLServer = New-AzSQLServer -ResourceGroupName $ResourceGroupName -ServerName $AzureServer -Location $Location -SqlAdministratorCredentials $SQLCredentials

### Create and Copy Azure Databases
New-AzSQLDatabase -ResourceGroupName $ResourceGroupName -ServerName $AzureServer -DatabaseName $DB1Database -RequestedServiceObjectiveName "S0"
New-AzSQLDatabase -ResourceGroupName $ResourceGroupName -ServerName $AzureServer -DatabaseName $AdventureWorksDatabase -SampleName "AdventureWorksLT" -RequestedServiceObjectiveName "S0"
New-AzSqlDatabaseCopy -ResourceGroupName $ResourceGroupName -ServerName $AzureServer -DatabaseName $AdventureWorksDatabase -CopyResourceGroupName $ResourceGroupName -CopyServerName $AzureServer -CopyDatabaseName "AdventureWorksCopy"

### Create Firewall Rules
New-AzSQLServerFirewallRule -ResourceGroupName $ResourceGroupName -ServerName $AzureServer -FirewallRuleName "RemoteConnection1" -StartIpAddress $ExternalIP -EndIpAddress $ExternalIP
New-AzSQLServerFirewallRule -ResourceGroupName $ResourceGroupName -ServerName $AzureServer -FirewallRuleName "AllowAllWindowsAzureIPs" -StartIpAddress 0.0.0.0 -EndIpAddress 0.0.0.0

### Query Database and Export Table Data
Get-AzSQLServer -ResourceGroupName $ResourceGroupName | Where-Object {$_.ServerName -eq $AzureServer}
Get-AzSQLDatabase -ServerName $AzureServer -ResourceGroupName $ResourceGroupName | Select-Object ServerName, DatabaseName, Location, Status
Invoke-SQLCMD -ConnectionString $AdventureWorksConnectionString -Query "SELECT * FROM SalesLT.Customer WHERE CompanyName > 'W'"          # Run "Import-Module SQLServer" if Invoke-SQLCMD does not work.  Other components may not work if Lab 0, Exercise 1 was not completed.
$CustomerData = Invoke-SQLCMD -ConnectionString $AdventureWorksConnectionString -Query "Select * From SalesLT.Customer"  | Select-Object customerid,firstname,lastname,companyname,salesperson,emailaddress,phone -Last 500
$CustomerData | Export-CSV $CustomerCSV -NoTypeInformation

### Configure employees.sql to Create Table and Import Data
Copy-Item $TMPData $SQLData -Force
(Get-Content $SQLData) -Replace '<password>', $Password | Set-Content $SQLData
(Get-Content $SQLData) -Replace '<storageaccountkey>', $StorageAccountKey | Set-Content $SQLData
(Get-Content $SQLData) -Replace '<bloblocation>', $BLOBLocation | Set-Content $SQLData
$InputFile = $WorkFolder + "employees.sql"
Invoke-SQLCMD -ConnectionString $DB1ConnectionString -InputFile $InputFile
Invoke-SQLCMD -ConnectionString $DB1ConnectionString -Query "Select * From dbo.employees" | Format-Table EmployeeID, FirstName, LastName, DateOfBirth, HireDate, Salary -AutoSize

### Log VM Information and delete the Resource Group
"AZ Database Server Name :  " + $AzureServerDNS >> $WorkFolder$logFilePrefix$logFileSuffix
"AZ Database Name        :  " + $DB1Database >> $WorkFolder$logFilePrefix$logFileSuffix
"Resource Group Name     :  " + $ResourceGroupName + "   # Delete the Resource Group to remove all Azure resources created by this script (e.g. Remove-AzureRMResourceGroup -Name $ResourceGroupName -Force)"  >> $WorkFolder$logFilePrefix$logFileSuffix
$EndTime = Get-Date ; $et = "55264AzureDatabase" + $EndTime.ToString("yyyyMMddHHmm")
"End Time:   " + $EndTime >> $WorkFolder$logFilePrefix$logFileSuffix
"Duration:   " + ($EndTime - $StartTime).TotalMinutes + " (Minutes)" >> $WorkFolder$logFilePrefix$logFileSuffix
Rename-Item -Path $WorkFolder$logFilePrefix$logFileSuffix -NewName $et$logFileSuffix
### Remove-AzureRMResourceGroup -Name $ResourceGroupName -Verbose -Force
### Clear-Item WSMan:\localhost\Client\TrustedHosts -Force

