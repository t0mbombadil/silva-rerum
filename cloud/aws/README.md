# CLI useful commands 

```bash
# Show who created & when IAM users in account 
aws cloudtrail lookup-events --lookup-attributes AttributeKey=EventName,AttributeValue=CreateUser --region us-east-1 | jq

# Get MFA devices of users in IAM group
aws iam get-group --group-name admin --query "Users[*].UserName" | jq '.[]' | xargs -I {} aws iam list-mfa-devices --user {} | jq '.MFADevices[]'

```
