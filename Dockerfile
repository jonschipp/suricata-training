# Suricata
#
# VERSION               1.0
FROM      ubuntu
MAINTAINER Jon Schipp <jonschipp@gmail.com>

# Metadata
LABEL organization=oisf
LABEL program=suricata

# Specify container username e.g. training, demo
ENV VIRTUSER suricata
ENV DEBIAN_FRONTEND noninteractive

# Install dependencies
RUN apt-get update -qq
RUN apt-get install -yq man-db software-properties-common vim nano screen tmux \
 htop tcpdump tshark wget gdb linux-tools-generic libluajit-5.1-dev git-core \
 oinkmaster jq python python-scapy ethtool --no-install-recommends
RUN apt-get install -yq libnss3-dev libnspr4-dev libgeoip-dev libgeoip1 --no-install-recommends
RUN apt-get install -yq libpcre3 libpcre3-dbg libpcre3-dev \
 build-essential autoconf automake libtool libpcap-dev libnet1-dev \
 libyaml-0-2 libyaml-dev zlib1g zlib1g-dev libcap-ng-dev libcap-ng0 \
 make libmagic-dev libjansson-dev libjansson4 pkg-config --no-install-recommends

# Configure Suricata
RUN add-apt-repository ppa:oisf/suricata-stable
RUN apt-get update -qq
RUN apt-get -yd install suricata
COPY suricata.8.gz /usr/share/man/man8/

# User configuration
RUN adduser --disabled-password --gecos "" $VIRTUSER

# Passwords
RUN echo "$VIRTUSER:$VIRTUSER" | chpasswd
RUN echo "root:suricata" | chpasswd

# Sudo
RUN usermod -aG sudo $VIRTUSER

# Environment
WORKDIR /home/$VIRTUSER
USER $VIRTUSER
