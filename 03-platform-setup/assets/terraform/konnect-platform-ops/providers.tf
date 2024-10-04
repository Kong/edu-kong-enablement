provider "konnect" {
  system_account_access_token = var.system_account_access_token
  server_url                  = var.server_url
}

# provider "konnect" {
#   alias                       = "global"
#   system_account_access_token = var.system_account_access_token
#   server_url                  = "https://global.api.konghq.com"
# }