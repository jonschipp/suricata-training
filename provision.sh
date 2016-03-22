#!/bin/bash
# Author: Jon Schipp <jonschipp@gmail.com>
# Written for Ubuntu Saucy and Trusty, should be adaptable to other distros.

## Variables
VAGRANT=/home/vagrant
[[ -d "$VAGRANT" ]] && CONFIG="$VAGRANT/suricata.conf" || CONFIG="$PWD/suricata.conf"
HOME=/root
cd $HOME

# Installation notification
COWSAY=/usr/games/cowsay
IRCSAY=/usr/local/bin/ircsay
IRC_CHAN="#replace_me"
HOST=$(hostname -s)
LOGFILE=/root/islet_install.log
EMAIL=user@company.com

function die {
  if [ -f ${COWSAY:-none} ]; then
      $COWSAY -d "$*"
  else
      echo "$*"
  fi
  if [ -f $IRCSAY ]; then
      ( set +e; $IRCSAY "$IRC_CHAN" "$*" 2>/dev/null || true )
  fi
  echo "$*" | mail -s "[vagrant] Bro Sandbox install information on $HOST" $EMAIL
  exit 1
}

function hi {
  if [ -f ${COWSAY:-none} ]; then
      $COWSAY "$*"
  else
      echo "$*"
  fi
  if [ -f $IRCSAY ]; then
      ( set +e; $IRCSAY "$IRC_CHAN" "$*" 2>/dev/null || true )
  fi
  echo "$*" | mail -s "[vagrant] Bro Sandbox install information on $HOST" $EMAIL
}

install_dependencies(){
  apt-get update -qq
  apt-get install -yq cowsay git make sqlite pv linux-tools-$(uname -r) sysstat htop
  [[ -d /exercises ]] || mkdir /exercises
}

install_islet(){
  if ! [ -d islet ]
  then
    git clone http://github.com/jonschipp/islet || die "Clone of islet repo failed"
    cd islet
    make install-docker && ./configure && make logo &&
    make install && make user-config USER=training PASS=suricata
  fi
}

install_environment(){
  local apport=/etc/default/apport
  [[ -f $CONFIG ]] && install -o root -g root -m 0644 $CONFIG /etc/islet/environments
  sed -i 's/demo/training/' /etc/islet/islet.conf
  sysctl kernel.perf_event_paranoid=-1
  echo "kernel.perf_event_paranoid = -1" > /etc/sysctl.d/10-perf.conf
  # apparmor profile prevents ``timeout -s KILL 8h tcpdump'' from running in container
  # tcpdump: error while loading shared libraries: libcrypto.so.1.0.0: cannot open shared object file: Permission denied
  apparmor_parser -R /etc/apparmor.d/usr.sbin.tcpdump
  service apport stop
  [[ -f "$apport" ]] && grep "enabled=0" "$apport" && sed -i 's/=1$/=0/' "$apport"
}

install_dependencies "1.)"
install_islet "2.)"
install_environment "3.)"

echo -e "\nTry it out: ssh -p 2222 training@127.0.0.1 -o UserKnownHostsFile=/dev/null"
