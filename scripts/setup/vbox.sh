#!/bin/sh
set -e

MAIN_LINK=https://github.com/titanlixio/klaudinit.git
MAIN_IFDEV=enp0s3
MAIN_KLAUDENV=dev
NODE_NAME=node01
NODE_DOMAIN=dev.ttlix

cat << EOF

ifup $MAIN_IFDEV
yum install -y openssh-server openssh-clients git
systemctl start sshd
cd /tmp
git clone $MAIN_LINK
###-------------------------------------------------###
###-------------------------------------------------###
KLAUDENV=dev \
  sh /tmp/klaudinit/extensions/setup/main.sh      \\
  -l localhost                                    \\
  -e node_name=node01 -e node_domain=dev.ttlix    \\
  -e vols_part=False  -e swap_part=False
###-------------------------------------------------###
###-------------------------------------------------###

EOF
