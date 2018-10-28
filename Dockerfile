# SickChill
#
# Version 1.0

FROM resin/rpi-raspbian:jessie
LABEL maintainer "ahuh"

# Volume config: contains SickChill config.ini (generated at first start if needed)
VOLUME /config
# Volume data: contains SickChill database, config, cache and log files
VOLUME /data
# Volume tvshowsdir: root directory containing tv shows files
# WARNING: must have read/write accept for execution user (PUID/PGID)
VOLUME /tvshowsdir
# Volume postprocessingdir: contains downloaded files, ready to by post-processed by SickChill
# WARNING: must have read/write accept for execution user (PUID/PGID)
VOLUME /postprocessingdir
# Volume userhome: home directory for execution user
VOLUME /userhome

# Set environment variables
# - Set torrent mode (transmission or qbittorrent), label and port, and execution user (PUID/PGID)
ENV AUTO_UPDATE=\
	TORRENT_MODE=\
	TORRENT_PORT=\
	TORRENT_LABEL=\
	PUID=\
    PGID=
# - Set xterm for nano
ENV TERM xterm

# Remove previous apt repos
RUN rm -rf /etc/apt/preferences.d* \
	&& mkdir /etc/apt/preferences.d \
	&& rm -rf /etc/apt/sources.list* \
	&& mkdir /etc/apt/sources.list.d \
	&& mkdir /root/tmp

# Copy custom bashrc to root (ll aliases)
COPY root/ /root/
# Copy apt config for jessie (stable) and stretch (testing) repos
COPY preferences.d/ /etc/apt/preferences.d/
COPY sources.list.d/ /etc/apt/sources.list.d/
# Copy unrar bin to root tmp
COPY unrar/ /root/tmp/

# Update packages and install software
RUN apt-get update \
	&& apt-get install -y curl gzip nano crudini \
	&& apt-get install -y git libssl-dev libxslt1-dev libxslt1.1 libxml2-dev libxml2 libssl-dev libffi-dev \
	&& apt-get install -y build-essential \
	&& apt-get install -y python-pip python-dev \
	&& apt-get install -y nodejs-legacy \
	&& apt-get install -y dumb-init -t stretch \
	&& apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
    
# Install openssl python module
RUN pip install pyopenssl==0.13.1

# Install unrar
RUN gzip -d /root/tmp/unrar-5.3.7-arm.gz \
    && mv /root/tmp/unrar-5.3.7-arm /usr/bin/unrar \
    && chmod 755 /usr/bin/unrar \
    && rm -rf /root/tmp

# Get and install sickchill from git
RUN mkdir /opt/sickchill \
    && git clone --depth 1 https://github.com/SickChill/SickChill.git /opt/sickchill

# Create and set user & group for impersonation
RUN groupmod -g 1000 users \
    && useradd -u 911 -U -d /userhome -s /bin/false abc \
    && usermod -G users abc
	
# Copy scripts
COPY sickchill/ /etc/sickchill/

# Make scripts executable
RUN chmod +x /etc/sickchill/*.sh

# Expose port
EXPOSE 8081

# Launch SickChill at container start
CMD ["dumb-init", "/etc/sickchill/start.sh"]
