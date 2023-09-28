resource "shoreline_notebook" "kafka_topic_offset_decreased" {
  name       = "kafka_topic_offset_decreased"
  data       = file("${path.module}/data/kafka_topic_offset_decreased.json")
  depends_on = [shoreline_action.invoke_kafka_validation_script]
}

resource "shoreline_file" "kafka_validation_script" {
  name             = "kafka_validation_script"
  input_file       = "${path.module}/data/kafka_validation_script.sh"
  md5              = filemd5("${path.module}/data/kafka_validation_script.sh")
  description      = "An application or a consumer that is consuming messages from Kafka may have accidentally or intentionally deleted some of the messages, causing the offset to decrease."
  destination_path = "/agent/scripts/kafka_validation_script.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_action" "invoke_kafka_validation_script" {
  name        = "invoke_kafka_validation_script"
  description = "An application or a consumer that is consuming messages from Kafka may have accidentally or intentionally deleted some of the messages, causing the offset to decrease."
  command     = "`chmod +x /agent/scripts/kafka_validation_script.sh && /agent/scripts/kafka_validation_script.sh`"
  params      = ["KAFKA_BOOTSTRAP_SERVER","ZOOKEEPER_PORT","KAFKA_OFFSET_VALUE","CONSUMER_GROUP_NAME","ZOOKEEPER_HOST","TOPIC_NAME"]
  file_deps   = ["kafka_validation_script"]
  enabled     = true
  depends_on  = [shoreline_file.kafka_validation_script]
}

