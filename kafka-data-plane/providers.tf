provider "kafka" {
  bootstrap_servers = [var.bootstrap_servers]
  
  sasl_mechanism = "scram-sha512"
  sasl_username  = var.kafka_admin_username
  sasl_password  = var.kafka_admin_password
  
  tls_enabled     = true  
  skip_tls_verify = var.skip_tls_verify
  
  timeout = 120  
}
