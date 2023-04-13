#!/bin/bash

# Variables
namespace="default"  
pod_label="app=redis"
service_name="redis"
service_port="6379"
iterations="100"
output_file="pod_recovery_times.txt"

# Function to wait for the pod to become ready
wait_for_pod_ready() {
  while true; do
    ready=$(sudo kubectl get pods -n $namespace -l $pod_label -o json | jq '.items[].status.containerStatuses[].ready')
    if [[ "$ready" == "true" ]]; then
      break
    fi
    sleep 1
  done
}

# Main loop
echo "Testing pod recovery times" > $output_file
for i in $(seq 1 $iterations); do
  echo "Iteration: $i" | tee -a $output_file

  # Wait for the pod to be ready before starting the test
  wait_for_pod_ready

  # Get the current pod name
  pod_name=$(sudo kubectl get pods -n $namespace -l $pod_label -o json | jq -r '.items[].metadata.name')

  # Delete the current pod
  echo "Deleting pod $pod_name" | tee -a $output_file
  sudo kubectl delete pod -n $namespace $pod_name

  # Start measuring time
  start_time=$(date +%s.%N)

  # Wait for the new pod to be ready
  wait_for_pod_ready

  # End measuring time
  end_time=$(date +%s.%N)

  # Calculate time elapsed
  time_elapsed=$(echo "$end_time - $start_time" | bc)

  # Print the result
  echo "Time elapsed for iteration $i: $time_elapsed seconds" | tee -a $output_file
  echo "=====================================" | tee -a $output_file
done
