# /bin/bash
CFNSTACKID=$(cat ~/hybrisDemo/vars/env001.yml | grep stackPrefix | cut -d: -f2 | cut -c 2-)
INSTANCEID=$(aws cloudformation list-stack-resources --stack-name $CFNSTACKID-serverCluster --region us-west-2 --query StackResourceSummaries[*].PhysicalResourceId --output text)
INSTANCEIP=$(aws ec2 describe-instances --instance-id $INSTANCEID --region us-west-2 --query 'Reservations[].Instances[].NetworkInterfaces[].PrivateIpAddress' --output text)
PUBLICIP=$(aws ec2 describe-instances --instance-id $INSTANCEID --region us-west-2 --query 'Reservations[].Instances[].NetworkInterfaces[].Association[].PublicIp' --output text)
echo IPADDRESS $INSTANCEIP
echo PUBLICIP $PUBLICIP