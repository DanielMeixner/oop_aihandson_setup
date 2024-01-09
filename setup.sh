!/bin/bash

# Usage: ./create_instance.sh <resource_group> <instance_name> <location> <subscription_id>

# Set the input parameters
resource_group=$1
instance_name=$2
location=$3
subscription_id=$4
nr_of_instances=$5
embedding_model="text-embedding-ada-002"
embedding_model_version="2"
completion_model="gpt-35-turbo"
completion_model_version="0301"
sku="s0"
completion_capacity="10"
embedding_capactiy="10"



for ((i=1; i<=$nr_of_instances; i++))
do
    # Create a resource group
    az group create --name $resource_group$i --location $location

    # Create the Open AI instance
    az cognitiveservices account create --name $2$i --custom-domain $2$i --resource-group $resource_group$i --location $3 --kind OpenAI --sku $sku --subscription $subscription_id
    
    # deployment completion
    az cognitiveservices account deployment create -g $resource_group$i -n $2$i --deployment-name $completion_model --model-name $completion_model --model-version $completion_model_version --model-format OpenAI --sku-capacity 1 --sku-name "Standard" --capacity=$completion_capacity
    
    # deployment embedding
    az cognitiveservices account deployment create -g $resource_group$i -n $2$i --deployment-name embedding --model-name $embedding_model --model-version $embedding_model_version --model-format OpenAI --sku-capacity 1 --sku-name "Standard" --capacity=$embedding_capactiy

    # Get the key & url for the instance into a txt file.
    echo "#######" >> keys.txt
    echo $2$i >> keys.txt    
    echo "OPENAI_API_BASE=https:/$2$i.openai.azure.com/" >> keys.txt
    key="az cognitiveservices account keys list --name $2 --resource-group $resource_group$i --query key1"
    echo OPENAI_API_KEY=$key >> keys.txt
    az cognitiveservices account keys list --name $2 --resource-group $resource_group$i -n $2 >> keys.txt

done
