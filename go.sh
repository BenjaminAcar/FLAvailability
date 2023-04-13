#!/bin/bash
echo "Let's first setup our cluster and all components (the deployment images etc.). This takes a few minutes."
sleep 5

sudo kind create cluster --name redis --config=multi-node.yaml --image=kindest/node:v1.23.0
sudo kubectl apply -f statefulset-backend/redis/redis-configmap.yaml
sudo kubectl apply -f statefulset-backend/redis/redis-statefulset.yaml
sleep 60
sudo kubectl apply -f statefulset-backend/sentinel/sentinel-statefulset.yaml

sleep 10

VAR_LIST=$(sudo kubectl get pods -o wide -o json | jq -r '[.items[] | {name:.metadata.name, ip:.status.podIP}]')
echo "$VAR_LIST"

# get IPs of all redis pods
for row in $(echo "${VAR_LIST}" | jq -r '.[] | @base64'); do
    _jq() {
     echo ${row} | base64 --decode | jq -r ${1}
    }
   echo $(_jq '.name')

   if [[ $(_jq '.name') == "redis-0" ]]; then
    redis_0_ip=$(_jq '.ip')
    fi


   if [[ $(_jq '.name') == "redis-1" ]]; then
    redis_1_ip=$(_jq '.ip')
    fi

   if [[ $(_jq '.name') == "redis-2" ]]; then
    redis_2_ip=$(_jq '.ip')
    fi

done

# create interfaces in order to communicate with the different redis instances
sudo docker build -t interface-rest:v1.1 federated-learning/
sudo kind load docker-image interface-rest:v1.1 --name redis

export NAME="interface-rest-deployment-0"
export POD_IP="$redis_0_ip"
export INITIAL_MASTER='inital_master'
envsubst < deployment-interface-rest.yaml | sudo kubectl apply -f -
sleep 1

export NAME="interface-rest-deployment-1"
export POD_IP="$redis_1_ip"
export INITIAL_MASTER='not_inital_master'
envsubst < deployment-interface-rest.yaml | sudo kubectl apply -f -
sleep 1

export NAME="interface-rest-deployment-2"
export POD_IP="$redis_2_ip"
export INITIAL_MASTER='not_inital_master'
envsubst < deployment-interface-rest.yaml | sudo kubectl apply -f -
sleep 1

sudo docker build -t trigger-rest:v1.2 trigger/
sudo kind load docker-image trigger-rest:v1.2 --name redis

sleep 10

VAR_LIST=$(sudo kubectl get pods -o wide -o json | jq -r '[.items[] | {name:.metadata.name, ip:.status.podIP}]')
echo "$VAR_LIST"

# extract the IP of the interfaces in order to be able to trigger them

for row in $(echo "${VAR_LIST}" | jq -r '.[] | @base64'); do
    _jq() {
     echo ${row} | base64 --decode | jq -r ${1}
    }
   echo $(_jq '.name')

   if [[ $(_jq '.name') == *"interface-rest-deployment-0"* ]]; then
    interface_rest_deployment_0_ip=$(_jq '.ip')
    fi


   if [[ $(_jq '.name') == *"interface-rest-deployment-1"* ]]; then
    interface_rest_deployment_1_ip=$(_jq '.ip')
    fi

   if [[ $(_jq '.name') == *"interface-rest-deployment-2"* ]]; then
    interface_rest_deployment_2_ip=$(_jq '.ip')
    fi

done

echo "____________________________________________ Experiment _______________________________________________"
echo "Our setup is done. In the next step, we do our experiment."
sleep 5

echo "The current master-instance is redis-0. Lets update the model."
export POD_IP="$interface_rest_deployment_0_ip"
envsubst < deployment-trigger-rest-single-pod.yaml | sudo kubectl apply -f - # the trigger-rest-single-pod changes the model weights
sleep 3
sudo kubectl logs trigger-rest-deployment
sleep 1
sudo kubectl delete pod trigger-rest-deployment

echo "We see the last state of our model and how the script is changing the model weights by adding +1 at every single weight. In reality here the Federated Averaging algorithm is applied, to aggregate a global model out of the model updates of several clients."

echo "Now, lets delete the redis-0 pod so that another redis instance is selected as master."
current_master='redis-0'
sudo kubectl delete pod $current_master
sleep 10

echo "Now the current master is removed and a new pod is scheduled. As a result, our master changes. Let's figure out, which redis instance is the new master:"

# Now we have to extract the IP of the current redis master pod
current_redis_master_ip="$(sudo kubectl logs sentinel-0 | grep mymaster | tail -1 | cut -d "@" -f 2 | cut -d " " -f 3)"

if [ $current_redis_master_ip == $redis_0_ip ]; then
POD_IP=$interface_rest_deployment_0_ip
current_master='redis-0'
fi


if [ $current_redis_master_ip == $redis_1_ip ]; then
POD_IP=$interface_rest_deployment_1_ip
current_master='redis-1'
fi

if [ $current_redis_master_ip == $redis_2_ip ]; then
POD_IP=$interface_rest_deployment_2_ip
current_master='redis-2'
fi
echo "Our new master is $current_master. Let's update the model and see what happens".

export POD_IP
envsubst < deployment-trigger-rest-single-pod.yaml | sudo kubectl apply -f -
sleep 3
sudo kubectl logs trigger-rest-deployment
sleep 1
sudo kubectl delete pod trigger-rest-deployment
echo "As we can see, our model is not outdated. How can we see that? If the data would be outdated, the section 'Model before Update' should be equal to the aforementioned one. By continuing with the values in the second 'Model before Update' section, it is well shown, that our stored model in the new redis master instance is already changed by our process before. "


sleep 4

while true
do
    echo "Do you want another round? No = 1, Yes = 2"
    read user_input
    if [[ $user_input -eq 2 ]]; then
        # we start again by cleaning up all interfaces, since they are based on the IPs of the old pods, they are not useable anymore.
        sudo kubectl delete deployment interface-rest-deployment-0
        sudo kubectl delete deployment interface-rest-deployment-1
        sudo kubectl delete deployment interface-rest-deployment-2

        sudo kubectl delete pod $current_master
        sleep 15

        VAR_LIST=$(sudo kubectl get pods -o wide -o json | jq -r '[.items[] | {name:.metadata.name, ip:.status.podIP}]')

        # get IPs of all redis pods
        for row in $(echo "${VAR_LIST}" | jq -r '.[] | @base64'); do
            _jq() {
            echo ${row} | base64 --decode | jq -r ${1}
            }
        echo $(_jq '.name')

        if [[ $(_jq '.name') == "redis-0" ]]; then
            redis_0_ip=$(_jq '.ip')
            fi


        if [[ $(_jq '.name') == "redis-1" ]]; then
            redis_1_ip=$(_jq '.ip')
            fi

        if [[ $(_jq '.name') == "redis-2" ]]; then
            redis_2_ip=$(_jq '.ip')
            fi

        done

        # create again all redis interfaces
        export NAME="interface-rest-deployment-0"
        export POD_IP="$redis_0_ip"
        export INITIAL_MASTER='not_inital_master'
        envsubst < deployment-interface-rest.yaml | sudo kubectl apply -f -
        sleep 1

        export NAME="interface-rest-deployment-1"
        export POD_IP="$redis_1_ip"
        export INITIAL_MASTER='not_inital_master'
        envsubst < deployment-interface-rest.yaml | sudo kubectl apply -f -
        sleep 1

        export NAME="interface-rest-deployment-2"
        export POD_IP="$redis_2_ip"
        export INITIAL_MASTER='not_inital_master'
        envsubst < deployment-interface-rest.yaml | sudo kubectl apply -f -
        sleep 1

        # extract the IP of the redis communication interfaces        
        VAR_LIST=$(sudo kubectl get pods -o wide -o json | jq -r '[.items[] | {name:.metadata.name, ip:.status.podIP}]')
        echo "$VAR_LIST"

        for row in $(echo "${VAR_LIST}" | jq -r '.[] | @base64'); do
            _jq() {
            echo ${row} | base64 --decode | jq -r ${1}
            }
        echo $(_jq '.name')

        if [[ $(_jq '.name') == *"interface-rest-deployment-0"* ]]; then
            interface_rest_deployment_0_ip=$(_jq '.ip')
            fi


        if [[ $(_jq '.name') == *"interface-rest-deployment-1"* ]]; then
            interface_rest_deployment_1_ip=$(_jq '.ip')
            fi

        if [[ $(_jq '.name') == *"interface-rest-deployment-2"* ]]; then
            interface_rest_deployment_2_ip=$(_jq '.ip')
            fi

        done

        #extract the current redis master ip and identity
        current_redis_master_ip="$(sudo kubectl logs sentinel-0 | grep mymaster | tail -1 | cut -d "@" -f 2 | cut -d " " -f 3)"

        if [ $current_redis_master_ip == $redis_0_ip ]; then
        POD_IP=$interface_rest_deployment_0_ip
        current_master='redis-0'
        fi


        if [ $current_redis_master_ip == $redis_1_ip ]; then
        POD_IP=$interface_rest_deployment_1_ip
        current_master='redis-1'
        fi

        if [ $current_redis_master_ip == $redis_2_ip ]; then
        echo "test"
        POD_IP=$interface_rest_deployment_2_ip
        current_master='redis-2'
        fi

        echo "Our current master is $current_master. Let's update the model and see what happens".

        export POD_IP
        envsubst < deployment-trigger-rest-single-pod.yaml | sudo kubectl apply -f - #change the weights
        sleep 3
        sudo kubectl logs trigger-rest-deployment
        sleep 1
        sudo kubectl delete pod trigger-rest-deployment
        echo "As we can see, our model is still not outdated."
    else
        exit # if the user says "no more round" by typing 1 instead of 2, the terminal closes
    fi
    
done
