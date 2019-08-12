Tirr Infra
========

```
# Requires terraform ~> 0.12.6
terraform init

# Print IAM access keys
terraform console <<< 'local.encrypted_admin_access_key'
terraform console <<< 'local.encrypted_service_access_key'
```
