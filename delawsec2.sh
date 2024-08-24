# Retrieve instance IDs
INSTANCEIDS=$(aws ec2 describe-instances \
    --filters "Name=instance-state-name,Values=running" \
    --query "Reservations[*].Instances[?Tags[?Key=='Name' && Value!='web']].[InstanceId]" \
    --output text)

# Print retrieved instance IDs (for verification)
echo "$INSTANCEIDS"

# Iterate over each instance ID and terminate
for i in $INSTANCEIDS
do
    echo "Terminating instance: $i"
    aws ec2 terminate-instances --instance-ids "$i"
done
