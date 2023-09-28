

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