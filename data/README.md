This folder contains all the data that can be read directly into Spark Cluster by referring to the path `/opt/spark/data`.

Might not work while reading from Jupyter Notebook as this folder is not mapped to `spark-jupyter` container in [docker-compose.yaml](../docker-compose.yaml)