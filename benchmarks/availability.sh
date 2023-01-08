#!/bin/bash

# Create an array of pod names
pods=("redis-0" "redis-1" "redis-2")

# Iterate over the array of pod names
for pod in ${pods[@]}
do
  # Get the role of the current pod
  role=$(sudo kubectl exec $pod -- redis-cli -a a-very-complex-password-here info | grep "role")
  
  # Remove redundant spaces from the role string
  role=$(echo $role | tr -s ' ')
  
  # Check if the role of the current pod contains the word "master"
  if grep -q "master" <<< "$role"
  then
    # If the role contains "master", print the name of the pod and exit the loop
    echo "The current Redis master is: $pod"
	current_master=$pod
  fi
done




# Print the name of the current master pod
echo "The current Redis master is: $current_master"

# Capture the current time before the failover process starts
time_before_failover=$(date +%s)

# Delete the current master pod
sudo kubectl delete pod $current_master

# Wait for the new master pod to be up and running
while true
do
  # Find the new Redis master pod
  for pod in ${pods[@]}
  do
    # Get the role of the current pod
    role=$(sudo kubectl exec $pod -- redis-cli -a a-very-complex-password-here info | grep "role")

    # Remove redundant spaces from the role string
    role=$(echo $role | tr -s ' ')

    # Check if the role of the current pod contains the word "master"
    if grep -q "master" <<< "$role"
    then
      # If the role contains "master", save the name of the pod and exit the loop
      new_master=$pod
      break
    fi
  done

  # If a new master pod was found, exit the loop
  if [ -n "$new_master" ]
  then
    break
  fi

  # Sleep for 1 second before checking again
  sleep 1
done

# Capture the current time after the failover process is complete
time_after_failover=$(date +%s)

# Calculate the difference between the two times to get the failover time
failover_time=$((time_after_failover - time_before_failover))

# Print the name of the new master pod and the failover time in seconds
echo "The new Redis master is: $new_master"
echo "Failover time: $failover_time seconds"