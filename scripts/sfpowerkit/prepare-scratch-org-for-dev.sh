## Script to be run after scratch org create to prepare the environment for development

## This script will be called by sfpowerkit for each dev pool org created
## by the CI, and can also be run directly on a Mac


# Scratch org and dev hub username are passed by sfpowerkit as parameters 1 and 2
# To execute from command line, run "prepare-scratch-org-for-dev.sh scratchOrgAlias devHubAlias"
username=$1
devhubusername=$2


# Install all managed packages identified as dependencies in the sfdx-project.json
echo Installing managed package dependencies for scratch org $username...
sfdx sfpowerkit:package:dependencies:install -u $username -v $devhubusername -r

# Push source metadata
echo Pushing metadata...
sfdx force:source:push -u $username

# Assign all permission sets and permission set groups specified by name in config/wes-permission-set-groups-for-admin.txt
# Remember to add new ones into the file to make sure they're assigned :)
echo Assigning permission sets to default user...
while read permSetName; do
    echo Assigning $permSetName...
    sfdx force:user:permset:assign -u $username --permsetname $permSetName
done <config/wes-permission-set-groups-for-admin.txt