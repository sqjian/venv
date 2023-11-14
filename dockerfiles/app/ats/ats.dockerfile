FROM ubuntu:22.04

ENV DEBIAN_FRONTEND noninteractive

WORKDIR /opt/scripts

COPY scripts .

RUN set -eux \
        && chmod +x -R * \
        && ./deps.sh \
        && ./ats.sh \
        && ./env.sh \
        && ./cleanup.sh
        
WORKDIR /opt/ats

ENTRYPOINT ["/opt/scripts/entry.sh"]

CMD ["/opt/ats/bin/traffic_manager"]
