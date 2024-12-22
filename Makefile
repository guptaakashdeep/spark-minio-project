# Get jar filenames from local jars directory and prepend /opt/extra-jars path
JARS = $(shell ls jars/*.jar | sed 's|jars/|/opt/extra-jars/|g' | tr '\n' ',' | sed 's/,$$//')

build:
	docker compose build

build-nc:
	docker compose build --no-cache

build-progress:
	docker compose build --no-cache --progress=plain

clean:
	docker compose down --rmi="all" --volumes

down:
	docker compose down --volumes --remove-orphans

run:
	make down && docker compose up

run-scaled:
	make down && sh ./docker-compose-generator.sh 3 && docker compose -f docker-compose.generated.yaml up

run-d:
	make down && docker compose up -d

stop:
	docker compose stop

submit:
	docker exec spark-master spark-submit --master spark://spark-master:7077 --deploy-mode client --jars $(JARS) ./apps/$(app)

submit-py-pi:
	docker exec spark-master spark-submit --master spark://spark-master:7077 --jars $(JARS) /opt/spark/examples/src/main/python/pi.py

rm-results:
	rm -r data/results/*

jars-download:
	bash ./jar-downloader.sh