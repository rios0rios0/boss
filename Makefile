$(eval WSL_GATEWAY = $(shell sh -c "ifconfig eth0 | grep 'inet ' | sed -e 's/  */:/g' | cut -d: -f3"))
export WSL_GATEWAY

up-scrap:
	docker-compose -f docker-compose.yaml up -d

start-ab:
	#docker-compose -f docker-compose.ab.yaml build
	docker-compose -f docker-compose.ab.yaml up -d

start-h2:
	#docker-compose -f docker-compose.h2.yaml build
	docker-compose -f docker-compose.h2.yaml up -d

start-aj:
	#docker-compose -f docker-compose.aj.yaml build
	docker-compose -f docker-compose.aj.yaml up -d
