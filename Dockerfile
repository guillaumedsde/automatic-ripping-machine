FROM ubuntu:bionic as build

ADD https://github.com/just-containers/s6-overlay/releases/latest/download/s6-overlay-amd64.tar.gz s6-overlay-amd64.tar.gz

RUN mkdir -p /rootfs \
    && tar xzf s6-overlay-amd64.tar.gz -C /rootfs 

# copy S6 overlay configuration
COPY rootfs/ /

WORKDIR /rootfs/opt

# Copy source code
COPY arm arm
COPY scripts scripts

# Copy udev rules
COPY setup/51-automedia.rules /lib/udev/rules.d/
COPY runui.py .

FROM ubuntu:bionic 

# install dependency packages
RUN apt-get update \
    && apt-get install -y software-properties-common \
    && add-apt-repository ppa:heyarje/makemkv-beta \
    && add-apt-repository ppa:stebbins/handbrake-releases \
    && add-apt-repository ppa:mc3man/bionic-prop \
    && apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y  --no-install-recommends \
    regionset \
    git \
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
    python3 \
    python3-pip\
    libcurl4-openssl-dev \
    libssl-dev \
    libdvd-pkg \
    default-jre-headless

WORKDIR /opt

# install python requirements
COPY requirements.txt .
RUN pip3 install -r requirements.txt \
    && groupadd arm \
    && useradd -m arm -g arm -G cdrom

# copy S6 overlay
COPY --from=build /rootfs/ /

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