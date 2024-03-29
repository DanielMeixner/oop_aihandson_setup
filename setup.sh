!/bin/bash

# Usage: ./setup.sh <resource_group> <instance_name> <location> <subscription_id> <nr_of_instances> <completion_model> <completion_model_version> <completion capacity>

# Set the input parameters
resource_group=$1
instance_name=$2
location=$3
subscription_id=$4
nr_of_instances=$5
completion_model=$6
completion_model_version=$7
completion_capacity=$8

embedding_model="text-embedding-ada-002"
embedding_model_version="2"

sku="s0"
embedding_capactiy="10"

# Run the script in a loop x times
for ((i=1; i<=$nr_of_instances; i++))
do
    currentrgname=$resource_group$i
    currentoainame=$2$i

    # Create a resource group
    az group create --name $currentrgname --location $location

    # Create the Open AI instance
    az cognitiveservices account create -g $currentrgname -n $currentoainame --custom-domain $currentoainame  --location $3 --kind OpenAI --sku $sku --subscription $subscription_id
    
    # deployment completion
    az cognitiveservices account deployment create -g $currentrgname -n $currentoainame --deployment-name $completion_model --model-name $completion_model --model-version $completion_model_version --model-format OpenAI --sku-capacity 1 --sku-name "Standard" --capacity=$completion_capacity
    
    # deployment embedding
    az cognitiveservices account deployment create -g $currentrgname -n $currentoainame --deployment-name $embedding_model --model-name $embedding_model --model-version $embedding_model_version --model-format OpenAI --sku-capacity 1 --sku-name "Standard" --capacity=$embedding_capactiy


    # Get the key for the instance
    echo "#######" >> keys.txt
    echo $currentoainame >> keys.txt    
    echo "OPENAI_API_BASE=https://$currentoainame.openai.azure.com/" >> keys.txt
    
    key="az cognitiveservices account keys list --name $currentoainame --resource-group $currentrgname --query key1"
    echo OPENAI_API_KEY=$($key) >> keys.txt
   

done
