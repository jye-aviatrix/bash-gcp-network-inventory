#! /bin/bash

echo Provide GCP project name
read PROJECT_NAME
mkdir -p $PROJECT_NAME

gcloud projects describe $PROJECT_NAME --format=json > $PROJECT_NAME/project.json
gcloud projects describe $PROJECT_NAME > $PROJECT_NAME/project.txt

gcloud compute addresses list --project=$PROJECT_NAME --format=json > $PROJECT_NAME/ips.json
gcloud compute addresses list --project=$PROJECT_NAME > $PROJECT_NAME/ips.txt

gcloud compute target-pools list --project=$PROJECT_NAME --format=json > $PROJECT_NAME/target_pools.json
gcloud compute target-pools list --project=$PROJECT_NAME > $PROJECT_NAME/target_pools.txt

gcloud compute backend-services list --project=$PROJECT_NAME --format=json > $PROJECT_NAME/backend_services.json
gcloud compute backend-services list --project=$PROJECT_NAME > $PROJECT_NAME/backend_services.txt

gcloud compute routers list --project=$PROJECT_NAME --format=json > $PROJECT_NAME/cloud_routers.json
gcloud compute routers list --project=$PROJECT_NAME > $PROJECT_NAME/cloud_routers.txt
CLOUD_ROUTERS=$(jq -r '.[] | .name' $PROJECT_NAME/cloud_routers.json)
for $CLOUD_ROUTER in $CLOUD_ROUTERS
    QUERY=$(jq -r '.[] | "gcloud compute routers get-status \(.name) --region \(.region | split("/") | last)"' $PROJECT_NAME/cloud_routers.json)
    $(echo $QUERY --project $PROJECT_NAME) > $PROJECT_NAME/cloud_routers_dynamic_Routes.txt
done

gcloud compute vpn-tunnels list --project=$PROJECT_NAME --format=json > $PROJECT_NAME/vpn_tunnels.json
gcloud compute vpn-tunnels list --project=$PROJECT_NAME > $PROJECT_NAME/vpn_tunnels.txt

gcloud compute interconnects list --project=$PROJECT_NAME --format=json > $PROJECT_NAME/interconnects.json
gcloud compute interconnects list --project=$PROJECT_NAME > $PROJECT_NAME/interconnects.txt

echo "Collecting lis of VPCs..."
gcloud compute networks list --project=$PROJECT_NAME --format=json > $PROJECT_NAME/vpc.json
gcloud compute networks list --project=$PROJECT_NAME > $PROJECT_NAME/vpc.txt

# Get list of VPCs
VPCS=$(jq -r '.[] | .name' $PROJECT_NAME/vpc.json)
# echo $VPCS

# Loop through VPCs
for VPC in $VPCS
do
    mkdir -p $PROJECT_NAME/$VPC

    echo "Collecting VPC: $VPC subnet information..."
    gcloud compute networks subnets list --project=$PROJECT_NAME --network=$VPC --format=json > $PROJECT_NAME/$VPC/subnets.json
    gcloud compute networks subnets list --project=$PROJECT_NAME --network=$VPC > $PROJECT_NAME/$VPC/subnets.txt

    echo "Collecting VPC: $VPC IP information..."
    gcloud compute addresses list --project=$PROJECT_NAME --filter="network:$VPC" --format=json > $PROJECT_NAME/$VPC/ips.json
    gcloud compute addresses list --project=$PROJECT_NAME --filter="network:$VPC" > $PROJECT_NAME/$VPC/ips.txt

    echo "Collecting VPC: $VPC Firewall information..."
    gcloud compute firewall-rules list --project=$PROJECT_NAME --filter="network=$VPC" --format=json > $PROJECT_NAME/$VPC/firewall.json
    gcloud compute firewall-rules list --project=$PROJECT_NAME --filter="network=$VPC" > $PROJECT_NAME/$VPC/firewall.txt

    echo "Collecting VPC: $VPC non-dyanmic route information..."
    gcloud compute routes list --project=$PROJECT_NAME --filter="network=$VPC" --format=json > $PROJECT_NAME/$VPC/non_dynamic_routes.json
    gcloud compute routes list --project=$PROJECT_NAME --filter="network=$VPC" > $PROJECT_NAME/$VPC/non_dynamic_routes.txt

    echo "Collecting VPC: $VPC peering information..."
    gcloud compute networks peerings list --project=$PROJECT_NAME --network=$VPC --format=json > $PROJECT_NAME/$VPC/peerings.json
    gcloud compute networks peerings list --project=$PROJECT_NAME --network=$VPC > $PROJECT_NAME/$VPC/peerings.txt

    echo "Collecting VPC: $VPC private service connection information..."
    gcloud services vpc-peerings list --project=$PROJECT_NAME --network=$VPC --format=json > $PROJECT_NAME/$VPC/private_connections.json
    gcloud services vpc-peerings list --project=$PROJECT_NAME --network=$VPC > $PROJECT_NAME/$VPC/private_connections.txt

done

echo "Compressing infomration for project: $PROJECT_NAME..."
zip -r $PROJECT_NAME.zip $PROJECT_NAME/
echo "$PWD/$PROJECT_NAME.zip is ready"
