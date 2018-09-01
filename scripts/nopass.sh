#!/bin/sh
# ------------------------------------------------------------------
# [Script] init_ssh_nopass.sh
# [Author] Hai Ji <jhsea3do@gmail.com>
#          main script
# ------------------------------------------------------------------
# assumption: all nodes must have sshpass tool installed
# https://unix.stackexchange.com/questions/230084/send-the-password-through-stdin-in-ssh-copy-id
# [ ! -x "sshpass" ] && yum install -y sshpass;

function init_ssh_nopass_cluster {
EXEC_HOME=$(realpath $(dirname $0))

ssh_nodes=${ssh_nodes:-"
127.0.0.1
"}
ssh_user=${ssh_user:-"$USER"}
ssh_pass=${ssh_pass:-"mypassword"}
ssh_init=init_ssh_nopass_node-$ssh_user.sh

echo "#!/bin/sh
ssh_home=\$HOME
ssh_host=\$HOSTNAME
ssh_user=\$USER
ssh_pass=\${1:-$ssh_pass}
shift
ssh_opts=\$@
[ ! -f \"\$ssh_home/.ssh/id_rsa\" ] \
  && ssh-keygen -C \"\$ssh_user@\$ssh_host\" -f \$ssh_home/.ssh/id_rsa -N '' \
  && ls -la \$ssh_home/.ssh/id_rsa*;
ssh_nodes='$ssh_nodes';
for ssh_node in \$ssh_nodes; do
  sshpass -p \"\$ssh_pass\" ssh-copy-id \$ssh_opts \$ssh_node
done
exit 0;
" > $EXEC_HOME/$ssh_init

# deploy current host
sudo -u $ssh_user cp $EXEC_HOME/$ssh_init /tmp/$ssh_init
sudo -u $ssh_user sh /tmp/$ssh_init $ssh_pass -o 'StrictHostKeyChecking=no'

for ssh_node in $ssh_nodes; do
  echo sudo -u $ssh_user scp $EXEC_HOME/$ssh_init $ssh_user@$ssh_node:/tmp
  sudo -u $ssh_user scp $EXEC_HOME/$ssh_init $ssh_user@$ssh_node:/tmp
  sudo -u $ssh_user ssh -T $ssh_user@$ssh_node sh /tmp/$ssh_init $ssh_pass -o 'StrictHostKeyChecking=no'
  sudo -u $ssh_user ssh -T $ssh_user@$ssh_node rm -rf /tmp/$ssh_init
done

rm -rf $EXEC_HOME/$ssh_init /tmp/$ssh_init

exit 0;
}

init_ssh_nopass_cluster $@

# hint: ssh_nodes="10.0.24.101 10.0.24.102" ssh_user=shjihai ssh_pass=$(cat /tmp/mypass.txt) sh init_ssh_nopass.sh
