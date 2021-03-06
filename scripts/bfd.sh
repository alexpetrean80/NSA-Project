#!/usr/bin/env bash

install_bfd() {
    if [[ $(command -v bfd) != "" ]]; then
        return
    fi

    wget http://www.rfxnetworks.com/downloads/bfd-current.tar.gz 

    tar xvzf "/home/vagrant/bfd-current.tar.gz"

    bfd_dirname=$(ls | grep 'bfd' | grep -wv 'current') 

    cd "$bfd_dirname" || exit

    chmod +x install.sh && ./install.sh

    cd /home/vagrant || exit

    rm -rf bfd*
}

create_service_file() {
    cat < "/etc/systemd/system/bfd.service"<< EOF
[Unit]
Description=Brute Force Detector service
After=network.target

[Service]
Type=simple
User=vagrant
Group=vagrant
ExecStart=/usr/local/bfd -q
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF
}

create_configs() {
    cat < "/usr/local/bfd/conf.bfd"<< EOF
#!/bin/bash
#
# BFD 1.5-2 <bfd@rfxn.com>
# Copyright (C) 1999-2014, R-fx Networks <proj@r-fx.org>
# Copyright (C) 2014, Ryan MacDonald <ryan@r-fx.org>
# This program may be freely redistributed under the terms of the GNU GPL
#
# NOTE: This file should be edited with word/line wrapping off,
#       if your using pico please start it with the -w switch.
#       (e.g: pico -w filename)
#

# how many failure events must an address have before being blocked?
# you can override this on a per rule basis in /usr/local/bfd/rules/
TRIG=\"5\"

# send email alerts for all events [0 = off; 1 = on]
EMAIL_ALERTS=\"0\" 

# local user or email address alerts are sent to (separate multiple with comma)
EMAIL_ADDRESS=\"root\"

# subject of email alerts
EMAIL_SUBJECT=\"Brute Force Warning for $HOSTNAME\"

# executable command to block attacking hosts
BAN_COMMAND=\"/etc/apf/apf -d $ATTACK_HOST {bfd.$MOD}\"

######
# You should not need to edit any options below this line
######

# installation path
INSTALL_PATH=\"/usr/local/bfd\"

# rule files path
RULES_PATH=\"$INSTALL_PATH/rules\"

# track log script path
TLOG_PATH=\"$INSTALL_PATH/tlog\"

# syslog kernel log path
KERNEL_LOG_PATH=\"/var/log/messages\"

# syslog auth log path
AUTH_LOG_PATH=\"/var/log/secure\"

# bfd application log path
BFD_LOG_PATH=\"/var/log/bfd_log\"

# log all events to syslog [0 = off; 1 = on]
OUTPUT_SYSLOG=\"1\"

# log file path for syslog logging
OUTPUT_SYSLOG_FILE=\"$KERNEL_LOG_PATH\"

# template of the email message body
EMAIL_TEMPLATE=\"$INSTALL_PATH/alert.bfd\"

# contains list of files to search for addresses that are excluded from bans
IGNORE_HOST_FILES=\"$INSTALL_PATH/exclude.files\"

# grab the local time zone
TIME_ZONE=`date +"%z"`

# grab the local unix time
TIME_UNIX=`date +"%s"`

# lock file path
LOCK_FILE=\"$INSTALL_PATH/lock.utime\"

# lock file timeout
LOCK_FILE_TIMEOUT=\"300\"
EOF
}

install_bfd
create_service_file
create_configs

systemctl enable --now bfd.service