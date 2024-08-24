AMI=ami-041e2ea9402c46c32
INSTANCES=("mongodb" "redis" "mysql" "rabbitmq" "catalogue" "user" "cart" "shipping" "payment" "dispatch" "web" )
SG=sg-0c4a89aa9e5ea0b6e
SN=subnet-07359f2bebc552ce1
DOMAIN_NAME=getmydomain.xyz

for i in "${INSTANCES[@]}"
do
if [ $i == "mongodb" ] || [ $i == "mysql" ]
then
INSTANCETYPE="t3.small"
else
INSTANCETYPE="t2.micro"
fi

IP_AD=$(aws ec2 run-instances --image-id $AMI --instance-type $INSTANCETYPE --security-group-ids $SG --subnet-id $SN --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$i}]" --count 1 --query 'Instances[0].PrivateIpAddress' --output text)

aws route53 change-resource-record-sets \
    --hosted-zone-id Z01728923FVTHITHAMO0O \
    --change-batch '{
        "Comment": "Create an A record for example.com",
        "Changes": [
            {
                "Action": "UPSERT",
                "ResourceRecordSet": {
                    "Name": "'$i'.'$DOMAIN_NAME'",
                    "Type": "A",
                    "TTL": 300,
                    "ResourceRecords": [
                        {
                            "Value": "'$IP_AD'"
                        }
                    ]
                }
            }
        ]
    }
'

done
