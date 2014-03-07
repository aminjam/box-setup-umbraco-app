<#
.SYNOPSIS
Example script showing how to setup a simple web server.

#>
# Copyright 2012 Aaron Jensen
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
[CmdletBinding(DefaultParameterSetName="WebAndAdmin")]
param(

[Parameter(ParameterSetName="WebAndAdmin")][switch] $WebAndAdmin,
[Parameter(ParameterSetName="AdminOnly")][switch] $AdminOnly,
[Parameter(ParameterSetName="WebOnly")][switch] $WebOnly,

[Parameter(Mandatory=$true)]
[string] $AppUrl,

[Parameter(ParameterSetName="AdminOnly",Mandatory=$true)]
[string[]] $Servers,

[Parameter(ParameterSetName="WebOnly",Mandatory=$true)][int] $ServerNumber,

[Parameter(ParameterSetName="WebOnly",Mandatory=$true)]
[Parameter(ParameterSetName="AdminOnly",Mandatory=$true)]
[string]$MediaFolder,

[Parameter(ParameterSetName="WebOnly",Mandatory=$true)]
[Parameter(ParameterSetName="AdminOnly",Mandatory=$true)]
[string]$ExamineIndexesFolder,

[Parameter(ParameterSetName="AdminOnly")]
[switch]$ConfigureShare
)

Set-StrictMode -Version Latest

& 'C:\Utilities\Carbon\Import-Carbon.ps1'

$deploymentWritersGroupName = 'DeploymentWriters'

$websitePath ='C:\inetpub\MyCompany.MyBrand.Web\'
if (-not (Test-Path -path $websitePath))
{
    New-Item -Path $websitePath -type directory 
}

if($WebOnly -or $AdminOnly){

	Install-User -Username MyCompanyMyBrandUser -Password "P@ssw0rd" -Description "MyCompany MyBrand User for Accessing the Shared Media Folder"
	if ($WebOnly){
		Grant-Permission -Path $websitePath -Permission Modify `
						 -Identity 'MyCompanyMyBrandUser'
	}
	else{
		Grant-Permission -Path $websitePath -Permission Modify `
					 -Identity 'NETWORK SERVICE'
		if($AdminOnly -and $ConfigureShare ) {
			Install-SmbShare -Name MyCompanyMyBrandWebMedia -Path $MediaFolder -Description 'Sharing Media Folder for Admin Node.' -ReadAccess "MyCompanyMyBrandUser"
			Install-SmbShare -Name MyCompanyMyBrandWebExamineIndexes -Path $ExamineIndexesFolder -Description 'Sharing Examine Indexes Folder for Admin Node.' -ReadAccess "MyCompanyMyBrandUser"
		}
	}
}
else {
	Grant-Permission -Path $websitePath -Permission Modify `
					 -Identity 'NETWORK SERVICE'
}
Grant-Permission -Path $websitePath -Permission Read `
                 -Identity 'Everyone'
				 
Set-HostsEntry -IPAddress 127.0.0.1 -HostName 'MyCompany.MyBrand.Web' -Description "Self MyCompany.MyBrand.Web Node"
Set-HostsEntry -IPAddress 127.0.0.1 -HostName $AppUrl -Description "AppUrl MyCompany.MyBrand.Web Node"

[string[]] $serverNames = "Server1.MyCompany.MyBrand.Web","Server2.MyCompany.MyBrand.Web","Server3.MyCompany.MyBrand.Web","Server4.MyCompany.MyBrand.Web"

if ($Servers){
	for ($i=0; $i -lt $Servers.length; $i++) {
		Set-HostsEntry -IPAddress $Servers[$i] -HostName $serverNames[$i] -Description "Servers MyCompany.MyBrand.Web Node"
	}
}


$appPoolName = 'MyCompany.MyBrand.Web'
if($WebOnly){
	Install-IisAppPool -Name $appPoolName -UserName 'MyCompanyMyBrandUser' -Password 'P@ssw0rd'
}
else{
	Install-IisAppPool -Name $appPoolName -ServiceAccount NetworkService
}
if ($ServerNumber){
	Set-Variable -Name serverName -Value $serverNames[$ServerNumber - 1]
	Install-IisWebsite -Path $websitePath -Name 'MyCompany.MyBrand.Web' `
					   -Bindings ("http/*:80:MyCompany.MyBrand.Web","http/*:80:$AppUrl","http/*:80:$serverName") -AppPoolName $appPoolName
}
else{
	Install-IisWebsite -Path $websitePath -Name 'MyCompany.MyBrand.Web' `
					   -Bindings ("http/*:80:MyCompany.MyBrand.Web","http/*:80:$AppUrl") -AppPoolName $appPoolName
}

if ($MediaFolder){
	Install-IisVirtualDirectory -SiteName 'MyCompany.MyBrand.Web' -VirtualPath 'media' -PhysicalPath $MediaFolder
}

if ($ExamineIndexesFolder){
	Install-IisVirtualDirectory -SiteName 'MyCompany.MyBrand.Web' -VirtualPath 'examineIndexes' -PhysicalPath $ExamineIndexesFolder
}

if ($WebOnly){
	Set-HostsEntry -IPAddress 54.83.12.45 -HostName "MyCompanyMyBrandWebMediaConnection" -Description "Media Connection to QA-Admin"
	Set-HostsEntry -IPAddress 54.83.12.45 -HostName "MyCompanyMyBrandWebExamineIndexesConnection" -Description "Examine Indexes Connection to QA-Admin"
}