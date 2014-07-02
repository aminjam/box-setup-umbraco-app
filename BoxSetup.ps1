# Copyright 2014 Amin Jamali
# aminjam@outlook.com
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
[CmdletBinding(DefaultParameterSetName="Web")]
param(

[Parameter(ParameterSetName="Admin")][switch] $Admin,
[Parameter(ParameterSetName="Web")][switch] $Web,

[Parameter(Mandatory=$true)][string] $AppUrl,

[Parameter(ParameterSetName="Admin")][string[]] $Servers,

[Parameter(ParameterSetName="Web")][int] $ServerNumber,

[Parameter()][string]$MediaFolder,

[Parameter()][string]$ExamineIndexesFolder,

[Parameter(ParameterSetName="Admin")][switch]$ConfigureShare,

[Parameter()][string]$WebsitePath,

[Parameter()][string]$WindowsShareIP
)

Set-StrictMode -Version Latest

& 'C:\Utilities\Carbon\Import-Carbon.ps1'

if (!$WebsitePath){
	$WebsitePath = 'C:\inetpub\MyCompany.MyBrand.Web\'
	if (!$MediaFolder){
		$MediaFolder = 'C:\inetpub\MyCompany.MyBrand.Web\media'
	}
	if (!$ExamineIndexesFolder){
		$ExamineIndexesFolder = 'C:\inetpub\MyCompany.MyBrand.Web\examineIndexes'
	}
}
if (-not (Test-Path -path $WebsitePath))
{
    New-Item -Path $WebsitePath -type directory 
}


Install-User -Username MyCompanyMyBrandUser -Password "V3rYH@rDPW" -Description "MyCompany MyBrand User for Accessing the Shared Media Folder"
Grant-Permission -Path $WebsitePath -Permission Modify -Identity 'MyCompanyMyBrandUser'

if($Admin -and $ConfigureShare ) {
	Install-SmbShare -Name MyCompanyMyBrandWebMedia -Path $MediaFolder -Description 'Sharing Media Folder for Admin Node.' -ReadAccess "MyCompanyMyBrandUser"
	Install-SmbShare -Name MyCompanyMyBrandWebExamineIndexes -Path $ExamineIndexesFolder -Description 'Sharing Examine Indexes Folder for Admin Node.' -ReadAccess "MyCompanyMyBrandUser"
}

Grant-Permission -Path $WebsitePath -Permission Read -Identity 'Everyone'
				 
Set-HostsEntry -IPAddress 127.0.0.1 -HostName 'MyCompany.MyBrand.Web' -Description "Self MyCompany.MyBrand.Web Node"
Set-HostsEntry -IPAddress 127.0.0.1 -HostName $AppUrl -Description "AppUrl MyCompany.MyBrand.Web Node"

[string[]] $serverNames = "Server1.MyCompany.MyBrand.Web","Server2.MyCompany.MyBrand.Web","Server3.MyCompany.MyBrand.Web","Server4.MyCompany.MyBrand.Web"

if ($ServerNumber){
	Set-HostsEntry -IPAddress 127.0.0.1 -HostName $serverNames[$ServerNumber - 1] -Description "Which Server MyCompany.MyBrand.Web Node"
}
else {
	if ($Servers){
		for ($i=0; $i -lt $Servers.length; $i++) {
			Set-HostsEntry -IPAddress $Servers[$i] -HostName $serverNames[$i] -Description "Servers MyCompany.MyBrand.Web Node"
		}
	}
}

$appPoolName = 'MyCompany.MyBrand.Web'
Install-IisAppPool -Name $appPoolName -UserName 'MyCompanyMyBrandUser' -Password 'V3rYH@rDPW'

if ($ServerNumber){
	Set-Variable -Name serverName -Value $serverNames[$ServerNumber - 1]
	Install-IisWebsite -Path $WebsitePath -Name 'MyCompany.MyBrand.Web' `
					   -Bindings ("http/*:80:MyCompany.MyBrand.Web","http/*:80:$AppUrl","http/*:80:$serverName") -AppPoolName $appPoolName
}
else{
	Install-IisWebsite -Path $WebsitePath -Name 'MyCompany.MyBrand.Web' `
					   -Bindings ("http/*:80:MyCompany.MyBrand.Web","http/*:80:$AppUrl") -AppPoolName $appPoolName
}


Install-IisVirtualDirectory -SiteName 'MyCompany.MyBrand.Web' -VirtualPath 'media' -PhysicalPath $MediaFolder
Install-IisVirtualDirectory -SiteName 'MyCompany.MyBrand.Web' -VirtualPath 'examineIndexes' -PhysicalPath $ExamineIndexesFolder

if ($WindowsShareIP){
	Set-HostsEntry -IPAddress $WindowsShareIP -HostName "MyCompanyMyBrandWebMediaConnection" -Description "Media Connection"
	Set-HostsEntry -IPAddress $WindowsShareIP -HostName "MyCompanyMyBrandWebExamineIndexesConnection" -Description "Examine Indexes Connection"
}