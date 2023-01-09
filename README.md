This repository is based on the work published in the following paper:
```
Title: Ensuring Federated Learning Availability for Autonomous Driving
Authors: Benjamin Acar, Marius Sterling, Fikret Sivrikaya, Sahin Albayrak
```
This repository is optimized for use on Linux systems. If you are running on a Windows machine, you may need to translate the bash code before running it. However, the code is well-documented with clear comments and terminal output commands, making it easy to troubleshoot any issues that may arise on your machine.
Required components before running the code:
```
- Kind
- Docker
```

Explanation of all files/folders:
- federated learning: This folder contains the interface used to interact with the redis instance, using simple REST APIs written in FastAPI. The model that is adjusted during the experiment is also provided there, even the script to create the model natively.
- trigger: in this folder the image is provided to trigger the interface of the redis interfaces, using simple HTTP calls
- deployment-interface-rest.yaml: file to deploy the interfaces in Kubernetes.
- deployment-trigger-rest-single-pod.yaml: file to deploy the pod that triggers the redis communication interface.
- multi-node.yaml: used to describe the Kind cluster that has to be created for the experiment.
- go.sh: this script performs the whole experiment, starting by creating all necessary ressources towards the concrecte model weight adjustments.
- clean.sh: this script cleans up the system after the experiment.
- statefulset-backend: includes the config files to create redis and sentinel instances.
- benchmarks: all benchmarkes to test the architecture performance are stored in this folder. The folder has it's own README.md. Just have a look.

To run the code, first we have to make the "go.sh" file exectuable by going to the project main folder, using the terminal and running:
```
chmod +x go.sh
```

Afterwards, we can easily run the code by typing:
```
./go.sh
```

If everything goes right, the output should be similar to this:
```
Let's first setup our cluster and all components (the deployment images etc.). This takes a few minutes.
[sudo] password for benjamin: 
Creating cluster "redis" ...
 ✓ Ensuring node image (kindest/node:v1.23.0) 🖼 
 ✓ Preparing nodes 📦 📦 📦  
 ✓ Writing configuration 📜 
 ✓ Starting control-plane 🕹️ 
 ✓ Installing CNI 🔌 
 ✓ Installing StorageClass 💾 
 ✓ Joining worker nodes 🚜 
Set kubectl context to "kind-redis"
You can now use your cluster with:

kubectl cluster-info --context kind-redis

Not sure what to do next? 😅  Check out https://kind.sigs.k8s.io/docs/user/quick-start/
configmap/redis-config created
statefulset.apps/redis created
service/redis created
statefulset.apps/sentinel created
service/sentinel created
[
  {
    "name": "redis-0",
    "ip": "10.244.1.3"
  },
  {
    "name": "redis-1",
    "ip": "10.244.2.3"
  },
  {
    "name": "redis-2",
    "ip": "10.244.1.5"
  },
  {
    "name": "sentinel-0",
    "ip": "10.244.2.5"
  },
  {
    "name": "sentinel-1",
    "ip": "10.244.1.7"
  },
  {
    "name": "sentinel-2",
    "ip": null
  }
]
redis-0
redis-1
redis-2
sentinel-0
sentinel-1
sentinel-2
Sending build context to Docker daemon  24.06kB
Step 1/8 : FROM python:3.9-slim
 ---> e40f8a7ee36b
Step 2/8 : COPY ./app /app
 ---> Using cache
 ---> bc339b2e8e8f
Step 3/8 : COPY ./requirements.txt /app
 ---> Using cache
 ---> f08ae3a4ea31
Step 4/8 : ENV PYTHONPATH "${PYTHONPATH}:/app/"
 ---> Using cache
 ---> 9ce5633244d3
Step 5/8 : WORKDIR /app
 ---> Using cache
 ---> a814113100d0
Step 6/8 : RUN pip3 install -r requirements.txt
 ---> Using cache
 ---> 709e8353774a
Step 7/8 : EXPOSE 8000
 ---> Using cache
 ---> dce377afaa8e
Step 8/8 : CMD ["uvicorn", "main:app", "--host=0.0.0.0", "--reload"]
 ---> Using cache
 ---> 2fedcede750e
Successfully built 2fedcede750e
Successfully tagged interface-rest:v1.1
Image: "interface-rest:v1.1" with ID "sha256:2fedcede750e8ff761c1c672d97e1bb7ada1a492b8f0f1f0eb7477da80f2b2c3" not yet present on node "redis-worker2", loading...
Image: "interface-rest:v1.1" with ID "sha256:2fedcede750e8ff761c1c672d97e1bb7ada1a492b8f0f1f0eb7477da80f2b2c3" not yet present on node "redis-control-plane", loading...
Image: "interface-rest:v1.1" with ID "sha256:2fedcede750e8ff761c1c672d97e1bb7ada1a492b8f0f1f0eb7477da80f2b2c3" not yet present on node "redis-worker", loading...
deployment.apps/interface-rest-deployment-0 created
deployment.apps/interface-rest-deployment-1 created
deployment.apps/interface-rest-deployment-2 created
Sending build context to Docker daemon  3.072kB
Step 1/7 : FROM python:3.9-slim
 ---> e40f8a7ee36b
Step 2/7 : ENV PYTHONPATH "${PYTHONPATH}:/app/"
 ---> Using cache
 ---> 3618d3ff017e
Step 3/7 : WORKDIR /usr/app
 ---> Using cache
 ---> 09a9e15d3e71
Step 4/7 : RUN pip3 install requests
 ---> Using cache
 ---> f2d10119fa86
Step 5/7 : COPY trigger.py ./
 ---> Using cache
 ---> 0761f13288b5
Step 6/7 : EXPOSE 8000
 ---> Using cache
 ---> d85d105bd000
Step 7/7 : CMD ["python", "./trigger.py"]
 ---> Using cache
 ---> 790bcf6552ee
Successfully built 790bcf6552ee
Successfully tagged trigger-rest:v1.2
Image: "trigger-rest:v1.2" with ID "sha256:790bcf6552ee9a6294a12c41d0998f4d7fc4f5893ee1b641fcc87db09e368744" not yet present on node "redis-worker2", loading...
Image: "trigger-rest:v1.2" with ID "sha256:790bcf6552ee9a6294a12c41d0998f4d7fc4f5893ee1b641fcc87db09e368744" not yet present on node "redis-control-plane", loading...
Image: "trigger-rest:v1.2" with ID "sha256:790bcf6552ee9a6294a12c41d0998f4d7fc4f5893ee1b641fcc87db09e368744" not yet present on node "redis-worker", loading...
[
  {
    "name": "interface-rest-deployment-0-d68bf668d-4g6b8",
    "ip": "10.244.2.8"
  },
  {
    "name": "interface-rest-deployment-1-6b9856dcd9-sdgs5",
    "ip": "10.244.1.8"
  },
  {
    "name": "interface-rest-deployment-2-c7c988464-p24lp",
    "ip": "10.244.1.9"
  },
  {
    "name": "redis-0",
    "ip": "10.244.1.3"
  },
  {
    "name": "redis-1",
    "ip": "10.244.2.3"
  },
  {
    "name": "redis-2",
    "ip": "10.244.1.5"
  },
  {
    "name": "sentinel-0",
    "ip": "10.244.2.5"
  },
  {
    "name": "sentinel-1",
    "ip": "10.244.1.7"
  },
  {
    "name": "sentinel-2",
    "ip": "10.244.2.7"
  }
]
interface-rest-deployment-0-d68bf668d-4g6b8
interface-rest-deployment-1-6b9856dcd9-sdgs5
interface-rest-deployment-2-c7c988464-p24lp
redis-0
redis-1
redis-2
sentinel-0
sentinel-1
sentinel-2
____________________________________________ Experiment _______________________________________________
Our setup is done. In the next step, we do our experiment.
The current master-instance is redis-0. Lets update the model.
pod/trigger-rest-deployment created
Model before Update:
b'{"message":"[array([[[10.17222 ],\\n        [ 8.774191]]], dtype=float32), array([11.], dtype=float32), array([[10.41784 ,  9.625709]], dtype=float32), array([10., 10.], dtype=float32)]"}'
Model after Update:
b'{"message":"[array([[[11.17222 ],\\n        [ 9.774191]]], dtype=float32), array([12.], dtype=float32), array([[11.41784 , 10.625709]], dtype=float32), array([11., 11.], dtype=float32)]"}'
pod "trigger-rest-deployment" deleted
We see the last state of our model and how the script is changing the model weights by adding +1 at every single weight. In reality here the Federated Averaging algorithm is applied, to aggregate a global model out of the model updates of several clients.
Now, lets delete the redis-0 pod so that another redis instance is selected as master.
pod "redis-0" deleted
Now the current master is removed and a new pod is scheduled. As a result, our master changes. Let's figure out, which redis instance is the new master:
Defaulted container "sentinel" out of: sentinel, config (init)
Our new master is redis-2. Let's update the model and see what happens.
pod/trigger-rest-deployment created
Model before Update:
b'{"message":"[array([[[11.17222 ],\\n        [ 9.774191]]], dtype=float32), array([12.], dtype=float32), array([[11.41784 , 10.625709]], dtype=float32), array([11., 11.], dtype=float32)]"}'
Model after Update:
b'{"message":"[array([[[12.17222 ],\\n        [10.774191]]], dtype=float32), array([13.], dtype=float32), array([[12.41784 , 11.625709]], dtype=float32), array([12., 12.], dtype=float32)]"}'
pod "trigger-rest-deployment" deleted
As we can see, our model is not outdated. How can we see that? If the data would be outdated, the section 'Model before Update' should be equal to the aforementioned one. By continuing with the values in the second 'Model before Update' section, it is well shown, that our stored model in the new redis master instance is already changed by our process before. 
Do you want another round? No = 1, Yes = 2
2
deployment.apps "interface-rest-deployment-0" deleted
deployment.apps "interface-rest-deployment-1" deleted
deployment.apps "interface-rest-deployment-2" deleted
pod "redis-2" deleted
interface-rest-deployment-0-d68bf668d-4g6b8
interface-rest-deployment-1-6b9856dcd9-sdgs5
interface-rest-deployment-2-c7c988464-p24lp
redis-0
redis-1
redis-2
sentinel-0
sentinel-1
sentinel-2
deployment.apps/interface-rest-deployment-0 created
deployment.apps/interface-rest-deployment-1 created
deployment.apps/interface-rest-deployment-2 created
[
  {
    "name": "interface-rest-deployment-0-68b9bcd9b-lkxdw",
    "ip": "10.244.2.11"
  },
  {
    "name": "interface-rest-deployment-1-6b9856dcd9-fc2qg",
    "ip": "10.244.1.12"
  },
  {
    "name": "interface-rest-deployment-2-7847d7c689-nnnsm",
    "ip": "10.244.2.12"
  },
  {
    "name": "redis-0",
    "ip": "10.244.1.10"
  },
  {
    "name": "redis-1",
    "ip": "10.244.2.3"
  },
  {
    "name": "redis-2",
    "ip": "10.244.1.11"
  },
  {
    "name": "sentinel-0",
    "ip": "10.244.2.5"
  },
  {
    "name": "sentinel-1",
    "ip": "10.244.1.7"
  },
  {
    "name": "sentinel-2",
    "ip": "10.244.2.7"
  }
]
interface-rest-deployment-0-68b9bcd9b-lkxdw
interface-rest-deployment-1-6b9856dcd9-fc2qg
interface-rest-deployment-2-7847d7c689-nnnsm
redis-0
redis-1
redis-2
sentinel-0
sentinel-1
sentinel-2
Defaulted container "sentinel" out of: sentinel, config (init)
Our current master is redis-1. Let's update the model and see what happens.
pod/trigger-rest-deployment created
Model before Update:
b'{"message":"[array([[[12.17222 ],\\n        [10.774191]]], dtype=float32), array([13.], dtype=float32), array([[12.41784 , 11.625709]], dtype=float32), array([12., 12.], dtype=float32)]"}'
Model after Update:
b'{"message":"[array([[[13.17222 ],\\n        [11.774191]]], dtype=float32), array([14.], dtype=float32), array([[13.41784 , 12.625709]], dtype=float32), array([13., 13.], dtype=float32)]"}'
pod "trigger-rest-deployment" deleted
As we can see, our model is still not outdated.
Do you want another round? No = 1, Yes = 2
```

To clean your system, first we have to make the "clean.sh" executable by running:
```
chmod +x clean.sh
```

Afterwards, we can easily run the code by typing:
```
./clean.sh
```

