IMG:='registry.cn-hangzhou.aliyuncs.com/sqjian/tmpl:ats'
ATS:='ats'

all: ats
logs:
	docker-compose logs -f ${ATS}
up:
	docker-compose up -d ${ATS}
down:
	docker-compose down -v
pull:
	docker-compose pull -v
ats:
	docker run \
		-itd \
		--rm \
		--name=ats \
		--net=bridge \
		--entrypoint /opt/scripts/entrypoint.sh \
		-v ${PWD}/config:/opt/ats/etc/trafficserver \
		-v ${PWD}/data/trafficserver:/opt/ats/var/trafficserver \
		${IMG} /opt/ats/bin/traffic_manager
build:
	docker build -t sqjian/tmpl:ats -f ats.dockerfile .
