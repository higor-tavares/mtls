resource "aws_api_gateway_rest_api" "hook" {
  body = jsonencode({
    openapi = "3.0.1"
    info = {
      title   = "hook"
      version = "1.0"
    }
    paths = {
      "/hook" = {
        post = {
          summary     = "Post hook data"
          description = "An endpoint that accepts JSON data without authorization"
          requestBody = {
            content = {
              "application/json" = {
                schema = {
                  type = "object"
                  properties = {
                    name = {
                      type = "string"
                    }
                  }
                  required = ["name"]
                }
              }
            }
          }
          responses = {
            "200" = {
              description = "Successful response"
            }
          }
          security = [] #'NONE' authorizer

          x-amazon-apigateway-integration = {
            httpMethod           = "POST"
            payloadFormatVersion = "1.0"
            type                 = "MOCK"
            responses = {
              default = {
                statusCode = "200"
                responseTemplates = {
                  "application/json" = "{\"statusCode\": 200, \"message\": \"Success\"}"
                }
              }
            }
            requestTemplates = {
              "application/json" = "{\"statusCode\": 200}"
            }
          }
        }
      }
    }
  })

  name        = "hook"
  description = "Webhook sample"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
  disable_execute_api_endpoint = true
}

resource "aws_api_gateway_deployment" "deployment" {
  rest_api_id = aws_api_gateway_rest_api.hook.id

  triggers = {
    redeployment = sha1(jsonencode(aws_api_gateway_rest_api.hook.body))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "stage" {
  deployment_id = aws_api_gateway_deployment.deployment.id
  rest_api_id   = aws_api_gateway_rest_api.hook.id
  stage_name    = "v1"
}

resource "aws_api_gateway_method_settings" "settings" {
  rest_api_id = aws_api_gateway_rest_api.hook.id
  stage_name  = aws_api_gateway_stage.stage.stage_name
  method_path = "*/*"
  settings {
    metrics_enabled = true
    logging_level   = "INFO"
  }
}