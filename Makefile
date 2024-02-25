TAG := latest
COMPONENTS := postgres rabbitmq keycloak


.PHONY: build
build: $(addprefix build-,$(COMPONENTS))
$(addprefix build-,$(COMPONENTS)): build-%: FORCE
	cd $* && docker build \
		-t devtool-dockerfiles/$*:${TAG} \
		.


.PHONY: delete
delete: $(addprefix delete-,$(COMPONENTS))
$(addprefix delete-,$(COMPONENTS)): delete-%: FORCE
	docker rm -f devtool-dockerfiles-$*


.PHONY: run
run: run-postgres run-rabbitmq run-keycloak

.PNONY: run-postgres
run-postgres:
	cd postgres && docker run -d \
		-p 5432:5432 \
		-e POSTGRES_USER=postgres \
		-e POSTGRES_PASSWORD=postgres \
		-e POSTRES_DB=postgres \
		-e TZ=Asia/Tokyo \
		-v ./docker-data:/var/lib/postgresql/data \
		--name=devtool-dockerfiles-postgres \
		--restart=always \
		devtool-dockerfiles/postgres:latest

.PHONY: run-rabbitmq
# dockerのホスト名はランダムハッシュであり、
# rabbitmqはフォルダ名にホスト名を使うため決まった値を設定することで永続化できる
# https://github.com/docker-library/rabbitmq/issues/6#issuecomment-241882358
# https://stackoverflow.com/questions/41330514/cker-rabbitmq-persistency
# 本来はクラスターの場合を考慮してRABBITMQ_NODENAMEを設定すべき.
# https://www.rabbitmq.com/configure.html
# 15672はmanagement UIのport
# https://www.rabbitmq.com/management.html#usage-ui
run-rabbitmq:
	cd rabbitmq && docker run -d \
		-p 5672:5672 -p 15672:15672 \
		-v ./docker-data:/var/lib/rabbitmq \
		--hostname rabbit \
		--name=devtool-dockerfiles-rabbitmq \
		--restart=always \
		devtool-dockerfiles/rabbitmq:latest

.PHONY: run-keycloak
# ホストへはgatewayを使うと良さそう
# https://docs.docker.jp/desktop/networking.html
run-keycloak:
	cd keycloak &&	docker run -d \
		-p 8443:8443 \
		-e KEYCLOAK_ADMIN=admin \
		-e KEYCLOAK_ADMIN_PASSWORD=admin \
		-e KC_DB_URL=jdbc:postgresql://gateway.docker.internal:5432/keycloak \
		-e KC_DB_USERNAME=postgres \
		-e KC_DB_PASSWORD=postgres \
		-e KC_HOSTNAME=localhost \
		--name=devtool-dockerfiles-keycloak \
		--restart=always devtool-dockerfiles/keycloak:latest \
		start --optimized --hostname-port=8443

FORCE:
