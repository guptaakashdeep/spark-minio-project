"""Integration test script for Spark-MinIO Iceberg"""
import os
from pyspark.sql import SparkSession


ICEBERG_CATALOG = "ic_minio"

spark = (
    SparkSession.builder.master("spark://spark-master:7077")
    .appName("spark-minio")
    .config("spark.hadoop.fs.s3a.endpoint", os.environ.get("MINIO_ENDPOINT"))
    .config("spark.hadoop.fs.s3a.access.key", os.environ.get("MINIO_ACCESS_KEY"))
    .config("spark.hadoop.fs.s3a.secret.key", os.environ.get("MINIO_SECRET_KEY"))
    .config("spark.hadoop.fs.s3a.path.style.access", "true")
    .config("spark.hadoop.fs.s3a.impl", "org.apache.hadoop.fs.s3a.S3AFileSystem")
    .config(
        "spark.hadoop.fs.s3a.aws.credentials.provider",
        "org.apache.hadoop.fs.s3a.SimpleAWSCredentialsProvider",
    )
    .config(
        f"spark.sql.catalog.{ICEBERG_CATALOG}", "org.apache.iceberg.spark.SparkCatalog"
    )
    .config(f"spark.sql.catalog.{ICEBERG_CATALOG}.type", "hadoop")
    .config(f"spark.sql.catalog.{ICEBERG_CATALOG}.warehouse", "s3a://warehouse/iceberg")
    .getOrCreate()
)

# Even after adding this, it still requires jars to be passed in spark-submit
# .config("spark.jars", "/opt/extra-jars/hadoop-aws-3.3.4.jar,/opt/extra-jars/aws-java-sdk-bundle-1.12.262.jar")\


print(f"MinIO Endpoint: {os.environ.get('MINIO_ENDPOINT')}")
# Write test
# Create a dummy dataframe and write into MinIO warehouse bucket
# df = spark.createDataFrame([(1, "foo"), (2, "bar")], ["id", "value"])
# df.coalesce(1).write.format("parquet").mode("overwrite").save("s3a://warehouse/conn_test/")

# # Read Test
# read_df = spark.read.parquet("s3a://warehouse/conn_test/")
# read_df.show()

TABLE_NAME = f"{ICEBERG_CATALOG}.db.sales"
spark.sql(
    f"""CREATE TABLE IF NOT EXISTS {TABLE_NAME} (
    order_number bigint, 
    product_code string, 
    year_id int, month_id int) 
    USING iceberg 
    PARTITIONED BY (year_id, month_id)"""
)

# Create some dummy data for sales table
spark.sql(
    f"""INSERT INTO {TABLE_NAME} VALUES 
        (1, 'ABC', 2023, 1), 
        (2, 'XYZ', 2023, 1), 
        (3, 'ABC', 2023, 2), 
        (4, 'XYZ', 2023, 2), 
        (5, 'ABC', 2024, 1), 
        (6, 'XYZ', 2024, 1), 
        (7, 'ABC', 2024, 2), 
        (8, 'XYZ', 2024, 2)"""
)
spark.table(f"{TABLE_NAME}.history").show(truncate=False)
spark.table(TABLE_NAME).show(truncate=False)
# docker exec spark-master spark-submit --master spark://spark-master:7077 \
# --deploy-mode client --executor-memory 1g --executor-cores 2 \
# --jars /opt/extra-jars/hadoop-aws-3.3.4.jar,/opt/extra-jars/aws-java-sdk-bundle-1.12.262.jar,/opt/extra-jars/iceberg-spark-runtime-3.5_2.12-1.4.2.jar \
# ./apps/spark-minio-test.py
