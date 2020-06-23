FROM python:3.8-slim-buster

ARG DEBIAN_FRONTEND=noninteractive 
ARG DEBCONF_NONINTERACTIVE_SEEN=true

# install python requirements
COPY Pipfile* ./

# install dependency packages
RUN apt update \
    && apt install -y --no-install-recommends gnupg ca-certificates \
    && echo 'deb http://deb.debian.org/debian buster main contrib non-free' > /etc/apt/sources.list \
    && echo 'deb https://ramses.hjramses.com/deb/makemkv buster main' >> /etc/apt/sources.list \
    && apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 9E5738E866C5E6B2 \
    && mkdir -p /usr/share/man/man1/ \
    && apt update \
    && apt install -y --no-install-recommends \
    udev \
    makemkv-bin  \
    makemkv-oss  \
    handbrake-cli \
    libavcodec-extra \
    abcde  \
    flac \
    imagemagick \
    glyrc \
    cdparanoia \
    at \
    libcurl4-openssl-dev \
    libssl-dev \
    libdvd-pkg \
    default-jre-headless \
    && dpkg-reconfigure libdvd-pkg \
    && pip install --no-cache-dir pipenv \
    && pipenv install --system --deploy --ignore-pipfile \
    && wget -O "s6.tgz" "https://github.com/just-containers/s6-overlay/releases/latest/download/s6-overlay-amd64.tar.gz" \
    && tar xzf "s6.tgz" -C / \
    && rm "s6.tgz" \
    && pip uninstall -y pipenv \
    && apt purge -y software-properties-common gnupg \
    && apt --purge -y autoremove \
    && rm -rf "/var/lib/apt/lists/*"

# copy S6 overlay configuration
COPY rootfs /

WORKDIR /opt/arm

# Copy source code
COPY arm arm
COPY runui.py .

ENV WEBSERVER_IP="0.0.0.0" \
    WEBSERVER_PORT="8080" \
    DBFILE="/config/arm.db" \
    LOGPATH="/config/logs/" \
    ARMPATH="/data/completed" \
    MEDIA_DIR="/data/movies" \
    RAWPATH="/data/raw" \
    ARM_CHECK_UDF="true" \ 
    GET_VIDEO_TITLE="true" \ 
    SKIP_TRANSCODE="false" \ 
    VIDEOTYPE="auto" \ 
    MINLENGTH="600" \ 
    MAXLENGTH="99999" \ 
    MANUAL_WAIT="true" \ 
    MANUAL_WAIT_TIME="600" \ 
    EXTRAS_SUB="extras" \ 
    INSTALLPATH="/opt/arm/" \ 
    LOGLEVEL="INFO" \ 
    LOGLIFE=1 \ 
    SET_MEDIA_PERMISSIONS="false" \ 
    CHMOD_VALUE=777 \ 
    SET_MEDIA_OWNER=false \ 
    CHOWN_USER= \ 
    CHOWN_GROUP= \ 
    RIPMETHOD="backup"  \ 
    MKV_ARGS="" \ 
    DELRAWFILES=true \ 
    HASHEDKEYS=False \ 
    HB_PRESET_DVD="HQ 720p30 Surround"  \ 
    HB_PRESET_BD="HQ 1080p30 Surround"  \ 
    DEST_EXT=mkv \ 
    HANDBRAKE_CLI=HandBrakeCLI \ 
    MAINFEATURE=false \ 
    HB_ARGS_DVD="--subtitle scan -F" \ 
    HB_ARGS_BD="--subtitle scan -F --subtitle-burned --audio-lang-list eng --all-audio" \ 
    EMBY_REFRESH=false \ 
    EMBY_SERVER="" \ 
    EMBY_PORT="8096" \ 
    EMBY_CLIENT="ARM" \ 
    EMBY_DEVICE="ARM" \ 
    EMBY_DEVICEID="ARM" \ 
    EMBY_USERNAME="" \ 
    EMBY_USERID="" \ 
    EMBY_PASSWORD="" \ 
    EMBY_API_KEY="" \ 
    NOTIFY_RIP=true \ 
    NOTIFY_TRANSCODE=true \ 
    PB_KEY="" \ 
    IFTTT_KEY="" \ 
    IFTTT_EVENT="arm_event" \ 
    PO_USER_KEY="" \ 
    PO_APP_KEY="" \ 
    OMDB_API_KEY="" \
    MAKEMKV_KEY=""

ENTRYPOINT [ "/init" ]