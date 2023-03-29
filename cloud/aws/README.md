# CLI useful commands 

```bash
# Show who created & when IAM users in account 
aws cloudtrail lookup-events --lookup-attributes AttributeKey=EventName,AttributeValue=CreateUser --region us-east-1 | jq

```
