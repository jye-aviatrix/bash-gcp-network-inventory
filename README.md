# bash-gcp-network-inventory
Bash script running in GCP Cloud Shell using gcloud to inventory VPC, Load balancer, VPN, Interconnect information


# Usage
- Launch GCP Cloud Shell
- run following command to download this repository
```
git clone https://github.com/jye-aviatrix/bash-gcp-network-inventory
```
- Switch directory to the inventory folder
```
cd bash-gcp-network-inventory/
```
- Run the invetory script
```
sh inventory.sh
```
- When prompted, enter project name, then hit enter
```
Provide GCP project name
my-project
```
- You may be prompted to authorize the Cloud Shell
- Wait until the script to complete, it will tell you a zip file is ready
```
<>
```
