resource "shoreline_notebook" "kafka_topic_offset_decreased_incident" {
  name       = "kafka_topic_offset_decreased_incident"
  data       = file("${path.module}/data/kafka_topic_offset_decreased_incident.json")
  depends_on = [shoreline_action.invoke_increase_replication,shoreline_action.invoke_auto_offset_reset_script]
}

resource "shoreline_file" "increase_replication" {
  name             = "increase_replication"
  input_file       = "${path.module}/data/increase_replication.sh"
  md5              = filemd5("${path.module}/data/increase_replication.sh")
  description      = "Increase the replication factor of the Kafka topic to prevent data loss and ensure that data is not lost in the event of an offset decrease."
  destination_path = "/tmp/increase_replication.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_file" "auto_offset_reset_script" {
  name             = "auto_offset_reset_script"
  input_file       = "${path.module}/data/auto_offset_reset_script.sh"
  md5              = filemd5("${path.module}/data/auto_offset_reset_script.sh")
  description      = "Check the configuration settings of the Kafka topic to make sure that the offset is not set to decrease automatically. If this is the case, change the configuration setting to prevent automatic decreases in the future."
  destination_path = "/tmp/auto_offset_reset_script.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_action" "invoke_increase_replication" {
  name        = "invoke_increase_replication"
  description = "Increase the replication factor of the Kafka topic to prevent data loss and ensure that data is not lost in the event of an offset decrease."
  command     = "`chmod +x /tmp/increase_replication.sh && /tmp/increase_replication.sh`"
  params      = ["ZOOKEEPER_SERVER","NEW_REPLICATION_FACTOR","NUM_PARTITIONS"]
  file_deps   = ["increase_replication"]
  enabled     = true
  depends_on  = [shoreline_file.increase_replication]
}

resource "shoreline_action" "invoke_auto_offset_reset_script" {
  name        = "invoke_auto_offset_reset_script"
  description = "Check the configuration settings of the Kafka topic to make sure that the offset is not set to decrease automatically. If this is the case, change the configuration setting to prevent automatic decreases in the future."
  command     = "`chmod +x /tmp/auto_offset_reset_script.sh && /tmp/auto_offset_reset_script.sh`"
  params      = ["TOPIC_NAME","CONFIG_FILE"]
  file_deps   = ["auto_offset_reset_script"]
  enabled     = true
  depends_on  = [shoreline_file.auto_offset_reset_script]
}

