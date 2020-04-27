#!/bin/bash
################################################################################

################################################################################
# contract: Print the contract and informations about the project to the user
################################################################################
function contract() {
    clear
    echo "##################################################################################"
    echo "#                                                                                #"
    cat <<"EOF"
#   _____          _                _                                            #
#  |__  /_ __ ___ | |__   __ _  ___| | ___   _ _ __                              #
#    / /| '_ ` _ \| '_ \ / _` |/ __| |/ / | | | '_ \                             #
#   / /_| | | | | | |_) | (_| | (__|   <| |_| | |_) |                            #
#  /____|_| |_| |_|_.__/ \__,_|\___|_|\_\\__,_| .__/                             #
#                                             |_|                                #
EOF
    echo "#                                                                                #"
    echo "##################################################################################"
    echo "#                                                                                #"
    echo "# Zmbackup is a reliable Bash shell script developed to help you in your daily   #"
    echo "# task to backup and restore mails and accounts from Zimbra Open Source Email    #"
    echo "# Platform. This script is based on another project called Zmbkpose, and         #"
    echo "# completely compatible with the structure if you have plans on migrate from one #"
    echo "# to another.                                                                    #"
    echo "#                                                                                #"
    echo "#         This script was made by the community for the community.               #"
    echo "#                                                                                #"
    echo "##################################################################################"
    echo -e "\n"
    echo "##################################################################################"
    echo "#                                                                                #"
    echo "# PLEASE, READ THIS AGREEMENT CAREFULLY BEFORE USING THE SOFTWARE. THIS PROGRAM  #"
    echo "# IS FREE SOFTWARE; YOU CAN REDISTRIBUTE IT AND/OR MODIFY IT UNDER THE TERMS OF  #"
    echo "# VERSION 3 OF THE GNU GENERAL PUBLIC LICENCE AS PUBLISHED BY THE FREE SOFTWARE  #"
    echo "# FOUNDATION.                                                                    #"
    echo "#                                                                                #"
    echo "# THIS PROGRAM IS DISTRIBUTED IN THE HOPE THAT IT WILL BE USEFUL, BUT WITHOUT    #"
    echo "# ANY WARRANT; WITHOUT EVEN THE IMPLIED WARRANTY OF MERCHANTABILITY OR FITNESS   #"
    echo "# FOR A PARTICULAR PURPOSE. SEE THE GNU GENERAL PUBLIC LICENCE FOR MORE DETAILS. #"
    echo "#                                                                                #"
    echo "# LICENSE TERMS FOR THIS ZMBACKUP SOFTWARE:                                      #"
    echo "# https://www.gnu.org/licenses/gpl.md                                            #"
    echo "#                                                                                #"
    echo "##################################################################################"
    echo -e "\n"
    printf "Do you agree with the terms of the software license agreements? [N/y]: "
    read OPT
    if [[ $OPT != 'Y' && $OPT != 'y' ]]; then
        echo "Stoping the installation process..."
        exit 0
    fi
}

################################################################################
# set_values: Set all the variables for Zmbackup
################################################################################
function set_values() {
    echo "##################################################################################"
    echo "#                                                                                #"
    echo "# The follow messages will ask you about some configurations for Zmbackup run in #"
    echo "# your server. Please answer each one of then or press ENTER to assume the       #"
    echo "# default value.                                                                 #"
    echo "#                                                                                #"
    echo "##################################################################################"
    echo -e "\n"

    # Inform Zimbra's default user
    printf "Inform Zimbra's defaut user - DEFAULT [$OSE_USER]:"
    read TMP
    OSE_USER=${TMP:-$OSE_USER}

    # Inform Zimbra's default install path
    printf "\nInform Zimbra's defaut install path - DEFAULT [$OSE_INSTALL_DIR]:"
    read TMP
    OSE_INSTALL_DIR=${TMP:-$OSE_INSTALL_DIR}

    # Inform Zmbackup's backup store
    printf "\nInform the path Zmbackup will use to store - DEFAULT [$OSE_DEFAULT_BKP_DIR]:"
    read TMP
    OSE_DEFAULT_BKP_DIR=${TMP:-$OSE_DEFAULT_BKP_DIR}

    # Configure mail alert
    printf "\nInform the account to receive all Zmbackup's alerts - DEFAULT [$ZMBKP_MAIL_ALERT]:"
    read TMP
    ZMBKP_MAIL_ALERT=${TMP:-$ZMBKP_MAIL_ALERT}

    # Configure number of threads to run in parallel
    printf "\nInform Zmbackup's number of threads - DEFAULT [$MAX_PARALLEL_PROCESS]:"
    read TMP
    MAX_PARALLEL_PROCESS=${TMP:-$MAX_PARALLEL_PROCESS}

    # Configure backup folder
    printf "\nInform the number of days Zmbackup should store the backups - DEFAULT [$ROTATE_TIME]:"
    read TMP
    ROTATE_TIME=${TMP:-$ROTATE_TIME}

    # Configure if should lock backup
    printf "\nLimit to one backup per day? - DEFAULT [$LOCK_BACKUP]:"
    read TMP
    LOCK_BACKUP=${TMP:-$LOCK_BACKUP}

    # Configure mail alert
    while ! [[ "$TMP" == 'SQLITE3' || "$TMP" == 'TXT' ]]; do
        printf "\nHow do you want to store Zmbackup's sessions? TXT or SQLITE3 - DEFAULT [$SESSION_TYPE]:"
        read TMP
        TMP=${TMP:-$SESSION_TYPE}
    done
    SESSION_TYPE=${TMP:-$SESSION_TYPE}

    # Change Zmbackup password
    printf "\nInform a password for Zmbackup user - DEFAULT [$ZMBKP_PASSWORD]:"
    read TMP
    TMP=${TMP:-$ZMBKP_PASSWORD}

    echo -e "\n\n"
    echo "##################################################################################"
    echo "#                                                                                #"
    echo "#                            CONFIGURATION COMPLETED                             #"
    echo "#                                                                                #"
    echo "##################################################################################"
}
