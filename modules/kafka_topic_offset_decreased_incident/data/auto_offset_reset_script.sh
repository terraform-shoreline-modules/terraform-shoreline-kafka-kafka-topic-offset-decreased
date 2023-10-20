

#!/bin/bash


# Set the variables

KAFKA_TOPIC=${TOPIC_NAME}

KAFKA_CONFIG=${CONFIG_FILE}



# Check the current configuration setting for the Kafka topic

current_setting=$(grep "${KAFKA_TOPIC}" "${KAFKA_CONFIG}" | grep "auto.offset.reset")



if [ -z "${current_setting}" ]; then

  # If the setting is not found, add it to the configuration file

  echo "auto.offset.reset=latest" >> "${KAFKA_CONFIG}"

  echo "Added auto.offset.reset=latest to ${KAFKA_CONFIG} for ${KAFKA_TOPIC}"

else

  # If the setting is found, update it to prevent automatic decreases

  sed -i "s/${current_setting}/auto.offset.reset=latest/g" "${KAFKA_CONFIG}"

  echo "Updated auto.offset.reset setting in ${KAFKA_CONFIG} for ${KAFKA_TOPIC}"

fi