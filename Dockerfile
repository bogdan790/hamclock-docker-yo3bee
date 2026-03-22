FROM alpine:3.21

# Default configuration - override via env_file or environment variables
ENV CALLSIGN="AB1CDE"
ENV LOCATOR="JJ00aa"
ENV LAT="00"
ENV LONG="00"
ENV UTC_OFFSET="2"
ENV VOACAP_MODE="38"
ENV VOACAP_POWER="100"
ENV CALLSIGN_BACKGROUND_COLOR="100,100,100"
ENV CALLSIGN_BACKGROUND_RAINBOW="0"
ENV CALLSIGN_COLOR="0,0,0"
ENV FLRIG_PORT="12345"
ENV FLRIG_HOST="localhost"
ENV USE_FLRIG="0"
ENV USE_METRIC="1"

USER root
WORKDIR /root/hamclock

# Install prerequisites
RUN apk add --no-cache curl make g++ libx11-dev openssl unzip perl

# Install HamClock
RUN curl -O https://www.clearskyinstitute.com/ham/HamClock/ESPHamClock.zip && \
    unzip ESPHamClock.zip && \
    cd ESPHamClock && \
    make -j 4 hamclock-web-2400x1440 && \
    make install && \
    cd .. && rm -f ESPHamClock.zip

# Install HamClock Contrib (hceeprom.pl)
RUN curl -O https://www.clearskyinstitute.com/ham/HamClock/hamclock-contrib.zip && \
    unzip hamclock-contrib.zip && \
    mv hamclock-contrib/hceeprom.pl ESPHamClock/hceeprom.pl && \
    chmod +x ESPHamClock/hceeprom.pl && \
    rm -f hamclock-contrib.zip

# Initialize config file
RUN /usr/local/bin/hamclock -t 20 & sleep 15; kill -INT %+

# Copy run script
COPY run.sh .
RUN chmod +x run.sh

VOLUME ["/root/.hamclock"]

HEALTHCHECK --interval=30s --timeout=10s --start-period=120s --retries=3 \
    CMD curl -f http://localhost:8081/live.html || exit 1

WORKDIR /root/hamclock/ESPHamClock
CMD /root/hamclock/run.sh