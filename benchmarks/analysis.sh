#!/bin/bash
SERVER=10.244.1.3
PORT=6379
PASSWORD=a-very-complex-password-here



# _____________________________first benchmark___________________________
THREADS=1
CLIENTS=50
DURATION=30

# Run memtier pod
sudo kubectl run memtier --image=redislabs/memtier_benchmark --command -- sleep infinity

# Wait for memtier pod to be ready
sudo kubectl wait --for=condition=Ready pod/memtier

# Run memtier_benchmark and store output in RESULT variable
sudo kubectl exec -it memtier -- bash -c "memtier_benchmark --server=$SERVER --port=$PORT --protocol=redis --threads=$THREADS --clients=$CLIENTS --test-time=$DURATION --auth=$PASSWORD > result1.log"

sudo kubectl cp memtier:result1.log result1.log

sudo kubectl delete pod memtier

sleep 30

# _____________________________second benchmark___________________________
THREADS=2
CLIENTS=100
DURATION=30

# Run memtier pod
sudo kubectl run memtier --image=redislabs/memtier_benchmark --command -- sleep infinity

# Wait for memtier pod to be ready
sudo kubectl wait --for=condition=Ready pod/memtier

# Run memtier_benchmark and store output in RESULT variable
sudo kubectl exec -it memtier -- bash -c "memtier_benchmark --server=$SERVER --port=$PORT --protocol=redis --threads=$THREADS --clients=$CLIENTS --test-time=$DURATION --auth=$PASSWORD > result2.log"

sudo kubectl cp memtier:result2.log result2.log

sudo kubectl delete pod memtier

sleep 30

# _____________________________3thd benchmark___________________________
THREADS=8
CLIENTS=400
DURATION=60

# Run memtier pod
sudo kubectl run memtier --image=redislabs/memtier_benchmark --command -- sleep infinity

# Wait for memtier pod to be ready
sudo kubectl wait --for=condition=Ready pod/memtier

# Run memtier_benchmark and store output in RESULT variable
sudo kubectl exec -it memtier -- bash -c "memtier_benchmark --server=$SERVER --port=$PORT --protocol=redis --threads=$THREADS --clients=$CLIENTS --test-time=$DURATION --auth=$PASSWORD > result3.log"

sudo kubectl cp memtier:result3.log result3.log

sudo kubectl delete pod memtier
 

sleep 30