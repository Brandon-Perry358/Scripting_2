#!/bin/bash

#file sh.sh
#Creates users on the popVM and sends emails in order to notify people
#author Brandon Perry
#Project - Scripting 2
#date 10/22/2020

#This checks to see if the root user is running the script and will exit the script if root isn't
if [ "$EUID" != 0 ]; then

    echo "Script Failure: Not being ran as root"
    exit 1

fi


#This checks to see if the file containing the email address exists and exits the script if it is not found
file=$1

[ -f $file ] && [[ $file != "" ]] || eval "echo Script Failure: File could not be found; exit 2"


for l in $(cat $file)

    do
        #This grabs the username from the email address
        uName=$(echo $l | cut -d"@"  -f1)
        #This generates a random one time password
        pass=$(openssl rand -base64 12)
        if newUser --badnames $uName -p $(echo $pass | openssl passwd -1 -stdin);then

            #This sends an email that contains a temporary password to the new user
            echo "Dear ${uName}, You have been given the temporary password: ${pass}"| sendmail -s 'VM Account creation' $l
            echo "VM ${uName} has been added to the system"

        else

            #This sends a different email that contains the users new password
            echo -e "${pass}\n${pass}" | passwd $uName
            echo "Dear ${uName}, Your password has been changed. Your new password is: ${pass}" | sendmail -s 'VM Password update' $l

        fi

done
