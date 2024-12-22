"""Sample test script to test Iceberg Hadoop catalog with MinIO"""
from pyspark.sql import SparkSession

spark = SparkSession.builder.appName("test")\
        .config("spark.executor.cores", "4")\
        .config("spark.executor.memory", "1g")\
        .config("spark.jars.packages",'org.apache.iceberg:iceberg-spark-runtime-3.5_2.12:1.4.2,org.apache.spark:spark-avro_2.12:3.5.0')\
        .config('spark.sql.catalog.local','org.apache.iceberg.spark.SparkCatalog') \
        .config('spark.sql.catalog.local.type','hadoop') \
        .config('spark.sql.catalog.local.warehouse','/opt/spark/data/warehouse') \
        .getOrCreate()

# Creating an Iceberg table
# spark.sql("CREATE TABLE local.db.sales (order_number bigint, product_code string, year_id int, month_id int) USING iceberg PARTITIONED BY (year_id, month_id)")

# Create some dummy data for sales table
# spark.sql("INSERT INTO local.db.sales VALUES (1, 'ABC', 2023, 1), (2, 'XYZ', 2023, 1), (3, 'ABC', 2023, 2), (4, 'XYZ', 2023, 2), (5, 'ABC', 2024, 1), (6, 'XYZ', 2024, 1), (7, 'ABC', 2024, 2), (8, 'XYZ', 2024, 2)")
spark.sql("select * from local.db.sales.history").show(truncate=False)
spark.sql("select * from local.db.sales").show(truncate=False)

# docker exec spark-master spark-submit --master spark://spark-master:7077 --deploy-mode client --jars /opt/extra-jars/iceberg-spark-runtime-3.5_2.12-1.4.2.jar ./apps/spark-test.py