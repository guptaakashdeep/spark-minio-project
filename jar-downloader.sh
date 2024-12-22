#!/bin/bash

MAVEN_REPO="https://repo1.maven.org/maven2"
JARS_DIR="jars"

# Define versions
SPARK_VERSION="3.5"
HADOOP_VERSION="3.3.4"
ICEBERG_VERSION="1.4.2"
SCALA_VERSION="2.12"

# Create jars directory
mkdir -p "$JARS_DIR"
cd "$JARS_DIR"

# Define jar mappings - just add new entries here
# Format: "jar_name|maven_path"
JAR_MAPPINGS=(
    "hadoop-aws-${HADOOP_VERSION}.jar|org/apache/hadoop/hadoop-aws/${HADOOP_VERSION}"
    "aws-java-sdk-bundle-1.12.262.jar|com/amazonaws/aws-java-sdk-bundle/1.12.262"
    "iceberg-spark-runtime-${SPARK_VERSION}_${SCALA_VERSION}-${ICEBERG_VERSION}.jar|org/apache/iceberg/iceberg-spark-runtime-${SPARK_VERSION}_${SCALA_VERSION}/${ICEBERG_VERSION}"
)

# Download each jar
for mapping in "${JAR_MAPPINGS[@]}"; do
    jar_name="${mapping%%|*}"
    maven_path="${mapping#*|}"
    url="$MAVEN_REPO/$maven_path/$jar_name"
    
    if [ -f "$jar_name" ]; then
        echo "✓ $jar_name already exists, skipping download"
    else
        echo "Downloading $jar_name..."
        if curl -f -# -O "$url"; then
            echo "✓ Successfully downloaded $jar_name"
        else
            echo "✗ Failed to download $jar_name"
            exit 1
        fi
    fi
done

# Verify downloads
echo "Verifying downloads..."
for mapping in "${JAR_MAPPINGS[@]}"; do
    jar_name="${mapping%%|*}"
    if [ -f "$jar_name" ]; then
        echo "✓ $jar_name exists"
        echo "Size: $(ls -lh "$jar_name" | awk '{print $5}')"
    else
        echo "✗ $jar_name is missing"
    fi
done
