This folder will include all the jars, that are:
- Downloaded via [jar-downloader.sh](../jar-downloader.sh)
- Jars can be added manually here too.

These jars will be included while running the spark-submit from master node.

Makefile command:
```bash
make submit app=pyfilename.py
```