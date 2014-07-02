box-setup-umbraco-app
=====================

Multi-sites Umbraco setup in a load-balanced enviornment

http://blog.aminjam.com/multi-sites-umbraco-setup-in-a-load-balanced-enviornment/

(Admin Only Box)
------
```
powershell.exe -ExecutionPolicy Bypass -NoLogo -NoProfile -File BoxSetup.ps1 -Admin 
-AppUrl "MyCompany.MyBrand.com" -MediaFolder "D:\MyCompany.MyBrand.Web.Media"  
-ExamineIndexesFolder "D:\MyCompand.MyBrand.Web.ExamineIndexes" -ConfigureShare
```

(Web Only Box: Server 1)
------
```
powershell.exe -ExecutionPolicy Bypass -NoLogo -NonInteractive -NoProfile -File BoxSetup.ps1 -Web 
-AppUrl "MyCompany.MyBrand.com" -ServerNumber 1 -MediaFolder "\\MyCompanyMyBrandWebMediaConnection\MyCompanyMyBrandWebMedia" 
-ExamineIndexesFolder "\\MyCompanyMyBrandWebExamineIndexesConnection\MyCompanyMyBrandWebExamineIndexes" -WindowsShareIP XX.XX.XX.XX
```

(Local VM DEV Machines)
------
```
powershell.exe -ExecutionPolicy Bypass -NoLogo -NonInteractive -NoProfile -File BoxSetup.ps1 -Web 
-AppUrl "MyCompany.MyBrand.com" -MediaFolder "\\MyCompanyMyBrandWebMediaConnection\MyCompanyMyBrandWebMedia" 
-ExamineIndexesFolder "\\MyCompanyMyBrandWebExamineIndexesConnection\MyCompanyMyBrandWebExamineIndexes" 
-WebsitePath "C:\PATH\TO\SOLUTION\WEB\FOLDER"  -WindowsShareIP XX.XX.XX.XX
```