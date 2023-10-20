

#!/bin/bash

# Set variables

REPLICATION_FACTOR=${NEW_REPLICATION_FACTOR}

# Increase replication factor

kafka-topics --zookeeper ${ZOOKEEPER_SERVER} --alter --topic $KAFKA_TOPIC --partitions ${NUM_PARTITIONS} --replication-factor $REPLICATION_FACTOR