
### About Shoreline
The Shoreline platform provides real-time monitoring, alerting, and incident automation for cloud operations. Use Shoreline to detect, debug, and automate repairs across your entire fleet in seconds with just a few lines of code.

Shoreline Agents are efficient and non-intrusive processes running in the background of all your monitored hosts. Agents act as the secure link between Shoreline and your environment's Resources, providing real-time monitoring and metric collection across your fleet. Agents can execute actions on your behalf -- everything from simple Linux commands to full remediation playbooks -- running simultaneously across all the targeted Resources.

Since Agents are distributed throughout your fleet and monitor your Resources in real time, when an issue occurs Shoreline automatically alerts your team before your operators notice something is wrong. Plus, when you're ready for it, Shoreline can automatically resolve these issues using Alarms, Actions, Bots, and other Shoreline tools that you configure. These objects work in tandem to monitor your fleet and dispatch the appropriate response if something goes wrong -- you can even receive notifications via the fully-customizable Slack integration.

Shoreline Notebooks let you convert your static runbooks into interactive, annotated, sharable web-based documents. Through a combination of Markdown-based notes and Shoreline's expressive Op language, you have one-click access to real-time, per-second debug data and powerful, fleetwide repair commands.

### What are Shoreline Op Packs?
Shoreline Op Packs are open-source collections of Terraform configurations and supporting scripts that use the Shoreline Terraform Provider and the Shoreline Platform to create turnkey incident automations for common operational issues. Each Op Pack comes with smart defaults and works out of the box with minimal setup, while also providing you and your team with the flexibility to customize, automate, codify, and commit your own Op Pack configurations.

# Kafka topic offset decreased
---

This incident type refers to a situation where the Kafka topic offset has decreased. Kafka is a distributed streaming platform that is used for building real-time data pipelines and streaming applications. The offset is a unique identifier for a message within a Kafka partition. A decrease in the offset value means that some messages have been lost or deleted, which can result in data inconsistency and loss of critical information. This type of incident requires immediate attention to investigate the root cause and prevent further data loss.

### Parameters
```shell
export SERVER_PORT="PLACEHOLDER"

export TOPIC_NAME="PLACEHOLDER"

export COMMA_SEPARATED_PARTITION_IDS="PLACEHOLDER"

export CONSUMER_GROUP_NAME="PLACEHOLDER"

export KAFKA_OFFSET_VALUE="PLACEHOLDER"

export ZOOKEEPER_HOST="PLACEHOLDER"

export ZOOKEEPER_PORT="PLACEHOLDER"

export KAFKA_BOOTSTRAP_SERVER="PLACEHOLDER"
```

## Debug

### Find the Kafka broker IDs for the given topic
```shell
kafka-topics.sh --bootstrap-server ${SERVER_PORT} --describe --topic ${TOPIC_NAME}
```

### Check if any partitions are under-replicated
```shell
kafka-topics.sh --bootstrap-server ${SERVER_PORT} --describe --under-replicated-partitions --topic ${TOPIC_NAME}
```

### Get the latest offset for each partition
```shell
kafka-run-class.sh kafka.tools.GetOffsetShell --broker-list ${SERVER_PORT} --topic ${TOPIC_NAME} --time -1 --partitions ${COMMA_SEPARATED_PARTITION_IDS}
```

### Get the earliest offset for each partition
```shell
kafka-run-class.sh kafka.tools.GetOffsetShell --broker-list ${SERVER_PORT} --topic ${TOPIC_NAME} --time -2 --partitions ${COMMA_SEPARATED_PARTITION_IDS}
```

### Get the current offset for each partition
```shell
kafka-consumer-groups.sh --bootstrap-server ${SERVER_PORT} --group ${CONSUMER_GROUP_NAME} --describe | grep ${TOPIC_NAME}
```

### Check if there are any missing messages in the topic
```shell
kafka-run-class.sh kafka.tools.GetOffsetShell --broker-list ${SERVER_PORT} --topic ${TOPIC_NAME} --time -1 | awk -F ":" '{print $3}' | paste -sd+ | bc
```

### Check if there are any duplicate messages in the topic
```shell
kafka-consumer-groups.sh --bootstrap-server ${SERVER_PORT} --group ${CONSUMER_GROUP_NAME} --describe | grep ${TOPIC_NAME} | awk '{print $5}' | uniq -d
```

### Check if there is any lag in consuming messages
```shell
kafka-consumer-groups.sh --bootstrap-server ${SERVER_PORT} --describe --group ${CONSUMER_GROUP_NAME}
```

### Check if the disk space is low on the Kafka brokers
```shell
df -h
```

### An application or a consumer that is consuming messages from Kafka may have accidentally or intentionally deleted some of the messages, causing the offset to decrease.
```shell


#!/bin/bash



# Define variables

KAFKA_TOPIC=${TOPIC_NAME}

KAFKA_CONSUMER_GROUP=${CONSUMER_GROUP_NAME}

KAFKA_OFFSET=${KAFKA_OFFSET_VALUE}



# Check if Kafka topic exists

if ! kafka-topics.sh --describe --topic $TOPIC --zookeeper ${ZOOKEEPER_HOST}:${ZOOKEEPER_PORT}; then

    echo "Kafka topic $TOPIC does not exist"

    exit 1

fi



# Check if Kafka consumer group exists

if ! kafka-consumer-groups.sh --describe --group CONSUMER_GROUP --bootstrap-server ${KAFKA_BOOTSTRAP_SERVER}; then

    echo "Kafka consumer group $CONSUMER_GROUP does not exist"

    exit 1

fi



# Check if offset value is valid

if [ $KAFKA_OFFSET -lt 0 ]; then

    echo "Invalid Kafka offset value $KAFKA_OFFSET"

    exit 1

fi



# Check if there are any messages with a lower offset value

if kafka-console-consumer.sh --topic $TOPIC --bootstrap-server ${KAFKA_BOOTSTRAP_SERVER} --consumer-property group.id=$KAFKA_CONSUMER_GROUP --offset $KAFKA_OFFSET --max-messages 1 | grep -q "no messages available"; then

    echo "No messages with a lower offset value found"

else

    echo "Messages with a lower offset value found"

fi


```