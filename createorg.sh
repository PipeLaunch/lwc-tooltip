#! /bin/bash
#================================================================
#                           CREATE ORG                      
#================================================================
#% DESCRIPTION
#-  This script creates a scratch org with customizable parameters
#-  Uncomment relevant lines to customize the script
#-  Change the config variables
#
#% HISTORY
#-  version     date        author                  change log
#-  1.0         2022-01-01  samuel@pipelaunch.com   Initial version
#-  1.0         2022-08-11  samuel@pipelaunch.com   Apex output parsing
#================================================================

#===================== CONFIG VARIABLES ======================
DEVHUB_ALIAS="pipelaunch" # DevHub alias name
ORG_ALIAS="lwc-tooltip-scratch" # name of the scratch org to create
INSTALL_SCRIPT_PATH="install-scripts/enable-debug.apex" # path to the install script to run after creating the scratch org (eg. enable debug mode)
ORG_DURATION_DAYS=30 # 1 to 30 days
#PACKAGE_ID="04t"
#============== ./ END CONFIG VARIABLES ======================

START_TIME=`date +%s`
EXIT_CODE=0

read -e -i "$DEVHUB_ALIAS" -p "Dev Hub alias: " devhubaliasinput # requires bash 4.0 or later
DEVHUB_ALIAS=${devhubaliasinput:-$DEVHUB_ALIAS}
echo "Authorizing the Dev Hub..."
sf org login web \
    --set-default-dev-hub \
    --alias $DEVHUB_ALIAS
echo ""

read -e -i "$ORG_ALIAS" -p "Scratch org alias: " aliasinput # requires bash 4.0 or later
ORG_ALIAS=${aliasinput:-$ORG_ALIAS}

echo "Cleaning previously created scratch org..."
sf force org delete \
    -p \
    -u $ORG_ALIAS &> /dev/null
echo ""

read -e -i "$ORG_DURATION_DAYS" -p "Scratch org duration (days): " orgdurationinput # requires bash 4.0 or later
ORG_DURATION_DAYS=${orgdurationinput:-$ORG_DURATION_DAYS}

echo "Creating scratch org..."
sf org create scratch \
    --definition-file config/project-scratch-def.json \
    --duration-days $ORG_DURATION_DAYS \
    --wait 15 \
    --set-default \
    --alias $ORG_ALIAS
echo ""

echo "Pushing source..."
sf project deploy start \
	--target-org $ORG_ALIAS
echo ""

read -e -i "Y" -p "Do you want to enable the Debug Mode? Debug mode can slow down your salesforce org [Y/n] " response
response=${response,,}    # tolower
if [[ "$response" =~ ^(yes|y)$ ]]
then
    APEX_OUTPUT=$(sf apex run -f "$INSTALL_SCRIPT_PATH")
	EXIT_CODE="$?"
	if [ "$EXIT_CODE" -eq 0 ]; then # Check Salesforce CLI exit code
		APEX_ERRORS=$(echo "$APEX_OUTPUT" | grep 'Error: ') # Check for Apex runtime error https://gist.github.com/pozil/ce21a6dcfc939def4972f56ec9d35646
		if [ "$APEX_ERRORS" != '' ]; then
			echo "$APEX_ERRORS"
			EXIT_CODE=-1;
		else
			APEX_OUTPUT=$(echo "$APEX_OUTPUT" | grep 'USER_DEBUG') # Keep debug log lines only
			APEX_OUTPUT=$(echo "$APEX_OUTPUT" | sed -E 's,([0-9]{2}:[0-9]{2}:[0-9]{2}\.[0-9]+) \([0-9]+\)\|USER_DEBUG\|\[([0-9]+)\]\|DEBUG\|(.*),\1\tLine \2\t\3,') # Simplify debug log: keep time stamp, line number and message only
			echo "$APEX_OUTPUT"
		fi
	else
		echo "Salesforce CLI failed to execute anonymous Apex:"
		echo "$APEX_OUTPUT"
	fi
fi

echo "Generating the scratch org password... View the password.env file"
rm -rf password.env
sf force user password generate >> password.env
cat password.env

echo "Opening scratch org..."
sf force org open
echo ""

# end message
END_TIME=`date +%s`
TOTAL_RUNTIME=$((END_TIME-START_TIME))
echo "`tput bold`Done in $TOTAL_RUNTIME seconds.`tput sgr0`"
exit $EXIT_CODE
