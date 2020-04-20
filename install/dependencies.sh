#!/bin/bash
################################################################################

################################################################################
# install_ubuntu: Install all the dependencies in Ubuntu Server
################################################################################
function install_ubuntu() {
  echo "Installing dependencies. Please wait..."
  apt-get update > /dev/null 2>&1
  apt-get install -y parallel wget curl > /dev/null 2>&1
  if [[ $? -eq 0 ]]; then
    echo "Dependencies installed with success!"
  else
    echo "Dependencies wasn't installed in your server"
    echo "Please check if you have connection with the internet and apt-get is"
    echo "working and try again."
    echo "Or you can try manual execute the command:"
    echo "apt-get update && apt-get install -y parallel wget curl"
    exit $EXIT_DEPNOTFOUND
  fi
}

################################################################################
# install_redhat: Install all the dependencies in Red Hat and CentOS
################################################################################
function install_redhat() {
  echo "Installing dependencies. Please wait..."
  yum install wget -y > /dev/null 2>&1
  if [[ $? -ne 0 ]]; then
    echo "Failure - Can't install Wget"
    exit $EXIT_NO_CONNECTION
  fi
  cat /etc/redhat-release | grep "release 6." > /dev/null 2>&1
  if [[ $? -eq 0 ]]; then
    wget -O "/etc/yum.repos.d/tange.repo" $OLE6_TANGE > /dev/null 2>&1

    if [[ $? -ne 0 ]]; then
      echo "Failure - Can't install Tange's repository for Parallel"
      exit 1
    fi
  else
    cat /etc/redhat-release | grep "release 7." > /dev/null 2>&1
    if [[ $? -eq 0 ]]; then
        wget -O "/etc/yum.repos.d/tange.repo" $OLE7_TANGE > /dev/null 2>&1

        if [[ $? -ne 0 ]]; then
            echo "Failure - Can't install Tange's repository for Parallel"
            exit 1
        fi
    fi
  fi
  yum install -y epel-release  > /dev/null 2>&1
  yum install -y parallel curl  > /dev/null 2>&1
  if [[ $? -eq 0 ]]; then
    echo "Dependencies installed with success!"
  else
    echo "Dependencies wasn't installed in your server"
    echo "Please check if you have connection with the internet and yum is"
    echo "working and try again."
    echo "Or you can try manual execute the command:"
    echo "yum install -y epel-release && yum install -y parallel wget curl"
    exit $EXIT_DEPNOTFOUND
  fi
}

################################################################################
# uninstall_ubuntu: Remove all the dependencies in Ubuntu Server
################################################################################
function uninstall_ubuntu() {
  echo "Removing dependencies. Please wait..."
  apt-get --purge remove -y parallel wget curl > /dev/null 2>&1
  if [[ $? -eq 0 ]]; then
    echo "Dependencies removed with success!"
  else
    echo "Dependencies wasn't removed in your server"
    echo "Please check if you have connection with the internet and apt-get is"
    echo "working and try again."
    echo "Or you can try manual execute the command:"
    echo "apt-get remove -y parallel wget curl"
  fi
}

################################################################################
# uninstall_redhat: Install all the dependencies in Red Hat and CentOS
################################################################################
function uninstall_redhat() {
  echo "Removing dependencies. Please wait..."
  yum remove -y parallel > /dev/null 2>&1
  # Remove parallel's repo
  rm -f /etc/yum.repos.d/tange.repo

  if [[ $? -eq 0 ]]; then
    echo "Dependencies removed with success!"
  else
    echo "Dependencies wasn't removed in your server"
    echo "Please check if you have connection with the internet and yum is"
    echo "working and try again."
    echo "Or you can try manual execute the command:"
    echo "yum install -y epel-release && yum install -y parallel wget curl"
  fi
}
