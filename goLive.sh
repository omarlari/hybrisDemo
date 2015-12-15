#!/bin/bash

# Find out what the ID of the hosted zone is that we're updating
AWS_EXT_DNS=$(aws route53 list-hosted-zones | grep -B 1 mckaws.omarlari.com | grep Id | awk -F\/ '{ print $3 }' | cut -d\" -f 1 | sed 2d)

# Get the DNS Name of the Load Balancer
AWS_INSTANCE_DNSNAME=$(curl -u reader:e8f8922efce5f8d861504a1131ce4f2a -s "10.99.254.83/job/hybrisGetIp/lastSuccessfulBuild/consoleText" | grep PUBLICIP | tail -n 1 | cut -d: -f2 | cut -c 11-)

# Create a temporary JSON file that is used to update DNS, leave the values that you are going to add blank

cat > modify-dns.json << EOF
{
  "Comment": "create the records for the stack.",
  "Changes": [
    {
      "Action": "",
      "ResourceRecordSet": {
        "Name": "hybris.mckaws.omarlari.com.",
        "Type": "A",
        "TTL": 300,
        "ResourceRecords": [
          {
            "Value": ""
          }
        ]
      }
    }
  ]
}
EOF

# Check if the name record already exists
AWS_DNS=$(aws route53 list-resource-record-sets --hosted-zone-id $AWS_EXT_DNS | grep hybris.mckaws.omarlari.com | awk -F\" '{ print $4 }')

# Use the result of the DNS Query to control the type of DNS update
if [ -n "$AWS_DNS" ]; then
  sed -i 's/Action\": \"/&UPSERT/' modify-dns.json 
  sed -i 's/Value\": \"/&'$AWS_INSTANCE_DNSNAME'/' modify-dns.json
else
  sed -i 's/Action\": \"/&CREATE/' modify-dns.json
  sed -i 's/Value": \"/&'$AWS_INSTANCE_DNSNAME'/' modify-dns.json
fi

# Use the JSON formatted text to update the record
aws route53 change-resource-record-sets --hosted-zone-id $AWS_EXT_DNS --change-batch file://modify-dns.json