# spark-minio-project
Builds a Spark Standalone Cluster on Docker in local with MinIO integration. 

This can be a Base Project for building and playing around different integrations with Spark as compute engine and MinIO as Object Storage.

Few of the integration examples include:
- Open Format Tables (Apache Iceberg, Apache Hudi and Delta Lake)
- OLAP engines like StarRocks for analytics for tables populated from Spark and data present in MinIO
- Airflow integration to run Spark Jobs from Airflow

> This project was built by referring the structure from this [Repo](https://github.com/mrn-aglic/spark-standalone-cluster/blob/main/Readme.md) for Spark Standalone cluster, and modifications are made on top of it.

## Getting Started
To make getting started with project easy, it includes a [Makefile](Makefile)

In case, you are on Windows system, `make` commands might not work, in that case you can just use the respective docker commands present in the Makefile.

### Makefile Commands

#### Downloading Jars that needs to be used by Spark Standalone Cluster
---
To download the required jars from MVNRepositories to be used in Spark Standalone Cluster.

```bash
make jars-download
```

> Jars that needs to be downloaded are included in [Jar Downloader Bash Script](jar-downloader.sh)

This creates a jars folder in the repo and downloads all the mentioned jars there.

This currently includes jars to support MinIO integration and Read/Write into Iceberg tables.

**Note:** *To add more jars to be downloaded via jars-downloader, add those jars in `JAR_MAPPING` in format `jar_name|maven_path` present in the jars-downloader.sh*

#### Building the Docker Images
---
```bash
make build-nc
```
Builds images present in the [Dockerfile](Dockerfile), that includes:
- Spark 3.5 (for master, worker and SparkHistory Server)
- MinIO
- JupyterLab

#### Running the containers
---
```bash
make run
```
Starts all the services, once all the images are built. 

This creates a Spark Standalone Cluster with *1 worker node*. 

**To create a multi worker cluster**, run
```bash
make run-scaled
```

This creates a Spark Standalone Cluster with *3 worker nodes*. To modify the number of worked nodes, update the number directly in `Makefile` command.

Once all the services are up and running, these services can be accesed in local on below URL:

- Spark Master: `localhost:9090`
- Spark History Server: `localhost:18080`
- MinIO UI: `localhost:9001`
- Jupyter Notebook Server: `localhost:8888`

Spark Master starts at `spark://spark-master:7077`

#### Integration Testing and Submitting PySpark Scripts
---
There are scripts present in `spark_apps` to test if the integration is working fine after everything is up and running.

- To test the integration, you can run
```bash
make submit app=spark_minio_test.py
```

Once this runs successfully you can go to MinIO UI, login via `ROOT_USER` and `ROOT_PASSWORD` present in [.env file](.env), and you will be able to see the data within `warehouse` bucket.

- To submit a spark job
```bash
make submit app=pyfilename.py # file present in spark_apps folder
```

#### To shut down everything
---
```bash
make down
```

### Data Mapping
---
To keep the data persistent that is being written via Spark:

- MinIO Buckets data, `minio_data` folder in repo is mapped with MinIO container volume.

- To read any data files while running the jobs in Spark Cluster, data can either be uploaded directly to MinIO buckets from MinIO UI running at `localhost:9001` or can be kept at `data` folder in repo.
    - `data` folder in Spark Cluster is mapped to `/opt/spark/data`
    - To read data from here in spark jobs:
    `spark.read.parquet('/opt/spark/data/file.parquet')`

> It's recommended to upload files in MinIO directly, to keep it simple to read data from Spark Jobs as well as the Jupyter Notebooks.