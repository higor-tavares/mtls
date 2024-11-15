resource "aws_api_gateway_domain_name" "domain" {
  regional_certificate_arn = var.certificate_arn
  domain_name              = var.domain_name
  security_policy          = "TLS_1_2"
  mutual_tls_authentication {
    truststore_uri = var.truststore_uri
  }
  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_base_path_mapping" "example" {
  api_id      = aws_api_gateway_rest_api.hook.id
  stage_name  = aws_api_gateway_stage.stage.stage_name
  domain_name = aws_api_gateway_domain_name.domain.domain_name
}