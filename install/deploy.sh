#!/bin/bash
################################################################################

################################################################################
# blacklist_gen: Generate a blacklist of all accounts Zmbackup should ignore
################################################################################
function blacklist_gen() {
    for ACCOUNT in $(su - $OSE_USER -c "zmprov -l gaa"); do
        if [[ "$ACCOUNT" = "galsync"* ]] ||
            [[ "$ACCOUNT" = "virus"* ]] ||
            [[ "$ACCOUNT" = "ham"* ]] ||
            [[ "$ACCOUNT" = "admin"* ]] ||
            [[ "$ACCOUNT" = "spam"* ]] ||
            [[ "$ACCOUNT" = "zmbackup"* ]] ||
            [[ "$ACCOUNT" = "postmaster"* ]] ||
            [[ "$ACCOUNT" = "root"* ]]; then
            echo $ACCOUNT >>$ZMBKP_CONF/blacklist.conf
        fi
    done
    echo $ZMBKP_ACCOUNT >>$ZMBKP_CONF/blacklist.conf
}

################################################################################
# deploy_new: Deploy a new version of Zmbackup
################################################################################
function deploy_new() {
    echo "Installing... Please wait while we made some changes."
    echo -ne '                      (0%)\r'
    mkdir -p $OSE_DEFAULT_BKP_DIR >/dev/null 2>&1
    if [[ $? -ne 0 ]]; then
        echo "[FAIL] - Can't create the directory"
        echo "For some reason the Zmbackup can't create the folder $OSE_DEFAULT_BKP_DIR."
        echo "Maybe you are using a NFS and the permissions are wrong?"
        echo "Please check what happened and try again."
        uninstall
        exit $EXIT_DEPNOTFOUND
    fi

    if [[ $SESSION_TYPE == "TXT" ]]; then
        touch $OSE_DEFAULT_BKP_DIR/sessions.txt
    elif [[ $SESSION_TYPE == "SQLITE3" ]]; then
        sqlite3 $OSE_DEFAULT_BKP_DIR/sessions.sqlite3 <src/database/database.sql >/dev/null 2>&1
    fi
    chown -R $OSE_USER. $OSE_DEFAULT_BKP_DIR >/dev/null 2>&1
    echo -ne '#                     (5%)\r'
    test -d $ZMBKP_CONF || mkdir -p $ZMBKP_CONF
    echo -ne '##                    (10%)\r'
    test -d $ZMBKP_SRC || mkdir -p $ZMBKP_SRC
    echo -ne '###                   (15%)\r'
    test -d $ZMBKP_SHARE || mkdir -p $ZMBKP_SHARE
    test -d $ZMBKP_LIB || mkdir -p $ZMBKP_LIB
    echo -ne '####                  (20%)\r'

    # Disable Parallel's message - Zmbackup remind the user about GNU Parallel
    mkdir $OSE_INSTALL_DIR/.parallel >/dev/null 2>&1 && touch $OSE_INSTALL_DIR/.parallel/will-cite
    chown -R $OSE_USER. $OSE_INSTALL_DIR/.parallel

    # Copy file
    install -o $OSE_USER -m 700 $MYDIR/src/zmbackup $ZMBKP_SRC
    echo -ne '#####                 (25%)\r'
    cp -R $MYDIR/src/lib/* $ZMBKP_LIB
    chown -R $OSE_USER. $ZMBKP_LIB
    chmod -R 700 $ZMBKP_LIB
    echo -ne '######                (30%)\r'

    install --backup=numbered -o root -m 600 $MYDIR/src/config/zmbackup.cron /etc/cron.d/zmbackup
    echo -ne '#######               (35%)\r'
    install --backup=numbered -o $OSE_USER -m 600 $MYDIR/src/config/zmbackup.conf $ZMBKP_CONF
    echo -ne '########              (40%)\r'
    install --backup=numbered -o $OSE_USER -m 600 $MYDIR/src/config/blacklist.conf $ZMBKP_CONF
    echo -ne '#########             (45%)\r'

    # Including custom settings
    sed -i "s|{OSE_DEFAULT_BKP_DIR}|${OSE_DEFAULT_BKP_DIR}|g" $ZMBKP_CONF/zmbackup.conf
    echo -ne '##########            (50%)\r'
    sed -i "s|{ZMBKP_ACCOUNT}|${ZMBKP_ACCOUNT}|g" $ZMBKP_CONF/zmbackup.conf
    echo -ne '###########           (55%)\r'
    sed -i "s|{ZMBKP_PASSWORD}|${ZMBKP_PASSWORD}|g" $ZMBKP_CONF/zmbackup.conf
    echo -ne '############          (60%)\r'
    sed -i "s|{ZMBKP_MAIL_ALERT}|${ZMBKP_MAIL_ALERT}|g" $ZMBKP_CONF/zmbackup.conf
    echo -ne '#############         (65%)\r'
    sed -i "s|{ZMBKP_MAIL_SENDER}|${ZMBKP_MAIL_SENDER}|g" $ZMBKP_CONF/zmbackup.conf
    echo -ne '#############         (65%)\r'
    sed -i "s|{OSE_INSTALL_ADDRESS}|${OSE_INSTALL_ADDRESS}|g" $ZMBKP_CONF/zmbackup.conf
    sed -i "s|{ZMBKP_MAIL_SENDER}|${OSE_INSTALL_ADDRESS}|g" $ZMBKP_CONF/zmbackup.conf
    echo -ne '##############        (70%)\r'
    sed -i "s|{OSE_INSTALL_LDAPPASS}|${OSE_INSTALL_LDAPPASS}|g" $ZMBKP_CONF/zmbackup.conf
    sed -i "s|{SESSION_TYPE}|${SESSION_TYPE}|g" $ZMBKP_CONF/zmbackup.conf
    echo -ne '###############       (75%)\r'
    sed -i "s|{OSE_USER}|${OSE_USER}|g" $ZMBKP_CONF/zmbackup.conf
    sed -i "s|{MAX_PARALLEL_PROCESS}|${MAX_PARALLEL_PROCESS}|g" $ZMBKP_CONF/zmbackup.conf
    echo -ne '################      (80%)\r'
    sed -i "s|{ROTATE_TIME}|${ROTATE_TIME}|g" $ZMBKP_CONF/zmbackup.conf
    sed -i "s|{LOCK_BACKUP}|${LOCK_BACKUP}|g" $ZMBKP_CONF/zmbackup.conf
    echo -ne '#################     (85%)\r'

    # Fix backup dir permissions (owner MUST be $OSE_USER)
    chown $OSE_USER. $OSE_DEFAULT_BKP_DIR
    echo -ne '##################    (90%)\r'

    # Generate Zmbackup's blacklist
    blacklist_gen
    echo -ne '###################   (95%)\r'

    # Create PID folder
    mkdir /var/run/zmbackup
    chown $OSE_USER. /var/run/zmbackup

    # Create log folder
    mkdir -p /var/log/zmbackup
    chown $OSE_USER. /var/log/zmbackup

    # Creating Zmbackup backup user
    STATUS=$(su - $OSE_USER -c "zmprov ca '$ZMBKP_ACCOUNT' '$ZMBKP_PASSWORD' zimbraIsAdminAccount TRUE zimbraAdminAuthTokenLifetime 1" 2>&1)
    if [[ $? -eq 0 ]]; then
        echo -ne '####################  (100%)\r'
    else
        echo "ERROR - Can't create the user. Executing rollback process"
        echo "Error description: $STATUS"
        uninstall
        exit $EXIT_CREATE_USER
    fi
}

################################################################################
# deploy_upgrade: Upgrade the old version to the new one
################################################################################
function deploy_upgrade() {
    # Removing old version
    echo "Upgrading... Please wait while we made some changes."
    echo -ne '                     (0%)\r'
    rm -rf $ZMBKP_SHARE $ZMBKP_SRC/zmbhousekeep >/dev/null 2>&1
    echo -ne '##########            (50%)\r'

    # Disable Parallel's message - Zmbackup remind the user about GNU Parallel
    mkdir $OSE_INSTALL_DIR/.parallel >/dev/null 2>&1 && touch $OSE_INSTALL_DIR/.parallel/will-cite
    chown -R $OSE_USER. $OSE_INSTALL_DIR/.parallel

    # Copy files
    install -o $OSE_USER -m 700 $MYDIR/src/zmbackup $ZMBKP_SRC
    echo -ne '###############       (75%)\r'
    test -d $ZMBKP_LIB || mkdir -p $ZMBKP_LIB
    cp -R $MYDIR/src/lib/* $ZMBKP_LIB
    chown -R $OSE_USER. $ZMBKP_LIB
    chmod -R 700 $ZMBKP_LIB
    echo -ne '####################  (100%)\r'
}

################################################################################
# uninstall: Remove zmbackup, their dependencies, and all files related
################################################################################
function uninstall() {
    echo "Removing... Please wait while we made some changes."
    source $ZMBKP_CONF/zmbackup.conf
    echo -ne '                     (0%)\r'
    rm -rf $ZMBKP_SHARE $ZMBKP_SRC/zmbhousekeep >/dev/null 2>&1
    rm -rf $OSE_INSTALL_DIR/.parallel
    echo -ne '#####                 (25%)\r'
    rm -rf /etc/yum.repos.d/tange.repo
    rm -rf /etc/cron.d/zmbackup
    rm -rf /var/run/zmbackup
    rm -rf $ZMBKP_LIB $ZMBKP_CONF $ZMBKP_SRC/zmbackup

    # Remove Zmbackup backup user
    echo "Removing zmbackup account..."
    STATUS=$(su - $OSE_USER -c "zmprov da '$ZMBKP_ACCOUNT'" 2>&1)

    echo -ne '##########            (50%)\r'
    if [[ -f $ZMBKP_CONF/blacklist.conf ]]; then
        install --backup=numbered -o $OSE_USER -m 600 $MYDIR/src/config/blacklist.conf $ZMBKP_CONF
        blacklist_gen
    fi
    echo -ne '###############       (75%)\r'

    # Delete zmbackup admin account
    sudo -H -u $OSE_USER bash -c "zmprov da $ZMBKP_ACCOUNT" >/dev/null 2>&1
    echo -ne '####################  (100%)\r'

    printf "Preserve Backup Storage?[n/Y]"
    read OPT
    if [[ $OPT == 'N' && $OPT == 'n' ]]; then
        echo "Removing backup storage..."
        rm -rf $WORKDIR/*
    fi
}
