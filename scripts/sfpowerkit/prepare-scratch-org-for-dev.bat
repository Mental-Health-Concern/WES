:: Script to be run after scratch org create to prepare the environment for development

:: This is a batch script version to be run locally on windows. It mirrors functionality
:: of prepare-scratch-org.sh which called by sfpowerscript for each dev pool org created
:: by the CI


:: Scratch org and dev hub username are passed by sfpowerkit as parameters 1 and 2
:: To execute from command line, run "prepare-scratch-org-for-dev.bat scratchOrgAlias devHubAlias"
set username=%1
set devhubusername=%2


:: Install all managed packages identified as dependencies in the sfdx-project.json
echo Installing managed package dependencies for scratch org %username%...
call sfdx sfpowerkit:package:dependencies:install -u %username% -v %devhubusername% -r

:: Push source metadata
echo Pushing metadata...
call sfdx force:source:push -u %username%

:: Assign all permission sets and permission set groups specified by name in config/wes-permission-set-groups-for-admin.txt
:: Remember to add new ones into the file to make sure they're assigned :)
echo Assigning permission sets to default user...
for /F "tokens=*" %%P in (config/wes-permission-set-groups-for-admin.txt) do (
    echo Assigning %%P...
    call sfdx force:user:permset:assign -u %username% --permsetname %%P
)