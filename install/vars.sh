#!/bin/bash
################################################################################
# SET INTERNAL VARIABLE
################################################################################

# EXIT CODES
# No error (normal exit)
EXIT_OK="0"
# No backup directory could be found
EXIT_NOBKPDIR="1"
# Running without root privileges
EXIT_NOROOT="2"
# Missing dependency
EXIT_DEPNOTFOUND="3"
# Missing connection to install packages
EXIT_NO_CONNECTION="4"
# Can't create the user for some reason
EXIT_CREATE_USER="5"

# ZMBACKUP INSTALLATION PATH
# The directory where the install script is
MYDIR=$(dirname $0)
# The main script stay here
ZMBKP_SRC="/usr/local/bin"
# The config/blacklist directory
ZMBKP_CONF="/etc/zmbackup"
# Keep for upgrade routine
ZMBKP_SHARE="/usr/local/share/zmbackup"
# The new path for the libs
ZMBKP_LIB="/usr/local/lib/zmbackup"

# ZIMBRA DEFAULT INSTALLATION PATH AND INTERNAL CONFIGURATION
# Zimbra's unix user
OSE_USER="zimbra"
# The Zimbra's installation path
OSE_INSTALL_DIR="/opt/zimbra"
# Where you will store your backup
OSE_DEFAULT_BKP_DIR="/backup"
# Zimbra's Domain
OSE_INSTALL_DOMAIN=$(su -s /bin/bash -c "$OSE_INSTALL_DIR/bin/zmprov gad | head -1" $OSE_USER)
OSE_INSTALL_HOSTNAME=$(hostname --fqdn)
# Zimbra's Server Address
OSE_INSTALL_ADDRESS=$(ping -c1 $OSE_INSTALL_HOSTNAME | head -1 | cut -d" " -f3 | sed 's#(##g' | sed 's#)##g')
# Zimbra's LDAP Password
OSE_INSTALL_LDAPPASS=$(su -s /bin/bash -c "$OSE_INSTALL_DIR/bin/zmlocalconfig -s zimbra_ldap_password" $OSE_USER | awk '{print $3}')
# Zmbackup's mail alert account
ZMBKP_MAIL_ALERT="admin@"$OSE_INSTALL_DOMAIN
# Zmbackup's default user for mail delivery
ZMBKP_MAIL_SENDER="root@"$OSE_INSTALL_DOMAIN
# Zmbackup's backup account
ZMBKP_ACCOUNT="zmbackup@"$OSE_INSTALL_DOMAIN
# Zmbackup's backup password
ZMBKP_PASSWORD=$(
    date +%s | sha256sum | base64 | head -c 32
    echo
)
# Zmbackup's number of threads
MAX_PARALLEL_PROCESS="3"
# Zmbackup's max of days before housekeeper
ROTATE_TIME="30"
# Zmbackup's backup lock
LOCK_BACKUP=true
# Zmbackup's latest version
ZMBKP_VERSION="Zmbackup version: 2.0.0"
# Zmbackup's default session type
SESSION_TYPE="TXT"

# REPOSITORIES FOR PACKAGES
OLE6_TANGE="http://download.opensuse.org/repositories/home:/tange/CentOS_CentOS-6/home:tange.repo"
OLE7_TANGE="http://download.opensuse.org/repositories/home:/tange/CentOS_7/home:tange.repo"

# Force a terminal type - Issue #90
export TERM="linux"
