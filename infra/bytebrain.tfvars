# Resource group configuration
resource_group_name = "rg-bytebrain-dev-southindia"
location            = "South India"

# Azure Container Registry (ACR) configuration
acr_name = "acrbytebraindev01"

# Bytebrain VM/VMSS Configuration
admin_username = "bytebrainadmin"
# Below will be passed in as a secret in GitHub Actions workflow, so we can leave it empty here.
ssh_public_key = ""
db_connection_string = ""
jwt_secret = ""