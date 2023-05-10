This repository is based on the work published in the following paper:
```
Title: Ensuring Federated Learning Availability for Autonomous Driving
Authors: Benjamin Acar, Marius Sterling
Journal: Journal of Intelligent and Connected Vehicles | emerald
```
This repository is optimized for use on Linux systems. If you are running on a Windows machine, you may need to translate the bash code before running it. However, the code is well-documented with clear comments and terminal output commands, making it easy to troubleshoot any issues that may arise on your machine.
Required components before running the code:
```
- Kind
- Docker
```

Explanation of all files/folders:
- federated learning: This folder contains the interface used to interact with the redis instance, using simple REST APIs written in FastAPI. The model that is adjusted during the experiment is also provided there, even the script to create the model natively. This interface is used for the basic experiment (incrementing each weight by one).
- federated learning-regression: This folder contains the interface used to interact with the redis instance, using simple REST APIs written in FastAPI. The model that is adjusted during the experiment is also provided there, even the script to create the model natively. In comparsion to "federated-learning", this code provides a more sophisticated learning option for a simple linear regression.
- trigger: in this folder the image is provided to trigger the interface of the redis interfaces, using simple HTTP calls. This trigger application is used for the basic experiment (incrementing each weight by one).
- client-1: in this folder the image is provided to trigger the interface of the redis interfaces, using simple HTTP calls. In comparsion to "trigger", we use this as one client for the more-sophisticated learning round of the "federated-learning-regression" example.
- deployment-interface-rest.yaml: file to deploy the interfaces in Kubernetes.
- deployment-trigger-rest-single-pod.yaml: file to deploy the pod that triggers the redis communication interface.
- client-1.yaml: file to deploy the pod (client-1) that triggers the redis communication interface for the simple linear regression.
- client-2.yaml: file to deploy the pod (client-2) that triggers the redis communication interface for the simple linear regression.
- multi-node.yaml: used to describe the Kind cluster that has to be created for the experiment.
- go.sh: this script performs the whole basic experiment (incrementing each weight by one), starting by creating all necessary ressources towards the concrecte model weight adjustments.
- go.sh: this script performs the whole linear regression experiment, starting by creating all necessary ressources towards the concrecte model weight adjustments.
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

However, "go.sh" is used for the basic experiment. If you want to do the linear regression instead, use the "go-regression.sh". 

If everything goes right, the output should be similar to this (in case of basic experiment! For the linear regression, just have a look below.):
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


For the linear regession the output should be similar to this:
```
Let's first setup our cluster and all components (the deployment images etc.). This takes a few minutes.
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

Thanks for using kind! 😊
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
    "ip": null
  }
]
redis-0
redis-1
redis-2
sentinel-0
sentinel-1
DEPRECATED: The legacy builder is deprecated and will be removed in a future release.
            Install the buildx component to build images with BuildKit:
            https://docs.docker.com/go/buildx/

Sending build context to Docker daemon  27.14kB
Step 1/8 : FROM python:3.9-slim
 ---> e40f8a7ee36b
Step 2/8 : COPY ./app /app
 ---> Using cache
 ---> f63df1b9d6de
Step 3/8 : COPY ./requirements.txt /app
 ---> Using cache
 ---> 76c22252fd30
Step 4/8 : ENV PYTHONPATH "${PYTHONPATH}:/app/"
 ---> Using cache
 ---> 38b6caaec04b
Step 5/8 : WORKDIR /app
 ---> Using cache
 ---> 9549561c14db
Step 6/8 : RUN pip3 install -r requirements.txt
 ---> Using cache
 ---> df0ce31c17f7
Step 7/8 : EXPOSE 8000
 ---> Using cache
 ---> 7be1e2b6f053
Step 8/8 : CMD ["uvicorn", "main:app", "--host=0.0.0.0", "--reload"]
 ---> Using cache
 ---> 2c7a9442a8d4
Successfully built 2c7a9442a8d4
Successfully tagged interface-rest:v1.1
Image: "interface-rest:v1.1" with ID "sha256:2c7a9442a8d4bbfa2aa7d35a7a25603c68ae745abb8c51753b85c77ba19feb20" not yet present on node "redis-control-plane", loading...
Image: "interface-rest:v1.1" with ID "sha256:2c7a9442a8d4bbfa2aa7d35a7a25603c68ae745abb8c51753b85c77ba19feb20" not yet present on node "redis-worker2", loading...
Image: "interface-rest:v1.1" with ID "sha256:2c7a9442a8d4bbfa2aa7d35a7a25603c68ae745abb8c51753b85c77ba19feb20" not yet present on node "redis-worker", loading...
deployment.apps/interface-rest-deployment-0 created
deployment.apps/interface-rest-deployment-1 created
deployment.apps/interface-rest-deployment-2 created
DEPRECATED: The legacy builder is deprecated and will be removed in a future release.
            Install the buildx component to build images with BuildKit:
            https://docs.docker.com/go/buildx/

Sending build context to Docker daemon  4.608kB
Step 1/8 : FROM python:3.9-slim
 ---> e40f8a7ee36b
Step 2/8 : ENV PYTHONPATH "${PYTHONPATH}:/app/"
 ---> Using cache
 ---> 3618d3ff017e
Step 3/8 : WORKDIR /usr/app
 ---> Using cache
 ---> 09a9e15d3e71
Step 4/8 : RUN pip3 install requests scikit-learn tensorflow numpy
 ---> Using cache
 ---> 603b026c808e
Step 5/8 : RUN pip3 install setuptools --upgrade
 ---> Using cache
 ---> 02b07457acc8
Step 6/8 : COPY trigger.py ./
 ---> Using cache
 ---> d485845c866a
Step 7/8 : EXPOSE 8000
 ---> Using cache
 ---> 3beb50fd1d67
Step 8/8 : CMD ["python", "./trigger.py"]
 ---> Using cache
 ---> 023b6bbb4bf9
Successfully built 023b6bbb4bf9
Successfully tagged client-1:v1.2
DEPRECATED: The legacy builder is deprecated and will be removed in a future release.
            Install the buildx component to build images with BuildKit:
            https://docs.docker.com/go/buildx/

Sending build context to Docker daemon  4.608kB
Step 1/8 : FROM python:3.9-slim
 ---> e40f8a7ee36b
Step 2/8 : ENV PYTHONPATH "${PYTHONPATH}:/app/"
 ---> Using cache
 ---> 3618d3ff017e
Step 3/8 : WORKDIR /usr/app
 ---> Using cache
 ---> 09a9e15d3e71
Step 4/8 : RUN pip3 install requests scikit-learn tensorflow numpy
 ---> Using cache
 ---> 603b026c808e
Step 5/8 : RUN pip3 install setuptools --upgrade
 ---> Using cache
 ---> 02b07457acc8
Step 6/8 : COPY trigger.py ./
 ---> Using cache
 ---> c54b32627606
Step 7/8 : EXPOSE 8000
 ---> Using cache
 ---> ddf1ee98fe47
Step 8/8 : CMD ["python", "./trigger.py"]
 ---> Using cache
 ---> c3c4bb165164
Successfully built c3c4bb165164
Successfully tagged client-2:v1.2
Image: "client-1:v1.2" with ID "sha256:023b6bbb4bf978f8a5c43c6c8bd3f3e18246fa3106e6e8f1aa26ae79591955da" not yet present on node "redis-control-plane", loading...
Image: "client-1:v1.2" with ID "sha256:023b6bbb4bf978f8a5c43c6c8bd3f3e18246fa3106e6e8f1aa26ae79591955da" not yet present on node "redis-worker2", loading...
Image: "client-1:v1.2" with ID "sha256:023b6bbb4bf978f8a5c43c6c8bd3f3e18246fa3106e6e8f1aa26ae79591955da" not yet present on node "redis-worker", loading...
fImage: "client-2:v1.2" with ID "sha256:c3c4bb1651643eb186181fbac28734117532ba120036dde0817327a6bba781b8" not yet present on node "redis-control-plane", loading...
Image: "client-2:v1.2" with ID "sha256:c3c4bb1651643eb186181fbac28734117532ba120036dde0817327a6bba781b8" not yet present on node "redis-worker2", loading...
Image: "client-2:v1.2" with ID "sha256:c3c4bb1651643eb186181fbac28734117532ba120036dde0817327a6bba781b8" not yet present on node "redis-worker", loading...
[
  {
    "name": "interface-rest-deployment-0-d68bf668d-nrjp9",
    "ip": "10.244.1.8"
  },
  {
    "name": "interface-rest-deployment-1-6b9856dcd9-n5625",
    "ip": "10.244.2.8"
  },
  {
    "name": "interface-rest-deployment-2-c7c988464-qn9s5",
    "ip": "10.244.2.9"
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
interface-rest-deployment-0-d68bf668d-nrjp9
interface-rest-deployment-1-6b9856dcd9-n5625
interface-rest-deployment-2-c7c988464-qn9s5
redis-0
redis-1
redis-2
sentinel-0
sentinel-1
sentinel-2
____________________________________________ Experiment _______________________________________________
Our setup is done. In the next step, we do our experiment.
The current master-instance is redis-0. Lets update the model.
pod/client-1-deployment created
pod/client-2-deployment created
2023-04-13 15:28:02.931965: I tensorflow/tsl/cuda/cudart_stub.cc:28] Could not find cuda drivers on your machine, GPU will not be used.
2023-04-13 15:28:03.326771: I tensorflow/tsl/cuda/cudart_stub.cc:28] Could not find cuda drivers on your machine, GPU will not be used.
2023-04-13 15:28:03.327780: I tensorflow/core/platform/cpu_feature_guard.cc:182] This TensorFlow binary is optimized to use available CPU instructions in performance-critical operations.
To enable the following instructions: AVX2 FMA, in other operations, rebuild TensorFlow with the appropriate compiler flags.
2023-04-13 15:28:05.131552: W tensorflow/compiler/tf2tensorrt/utils/py_utils.cc:38] TF-TRT Warning: Could not find TensorRT
____________________________Client 1 ______________________________________
Client-1 received current model Current model weights:
[[[-1.0151317119598389], [1.2023080587387085]], [0.0]]
Client 1 sent gradients.
2023-04-13 15:28:02.906808: I tensorflow/tsl/cuda/cudart_stub.cc:28] Could not find cuda drivers on your machine, GPU will not be used.
2023-04-13 15:28:03.308994: I tensorflow/tsl/cuda/cudart_stub.cc:28] Could not find cuda drivers on your machine, GPU will not be used.
2023-04-13 15:28:03.310228: I tensorflow/core/platform/cpu_feature_guard.cc:182] This TensorFlow binary is optimized to use available CPU instructions in performance-critical operations.
To enable the following instructions: AVX2 FMA, in other operations, rebuild TensorFlow with the appropriate compiler flags.
2023-04-13 15:28:05.067872: W tensorflow/compiler/tf2tensorrt/utils/py_utils.cc:38] TF-TRT Warning: Could not find TensorRT
____________________________Client 2 ______________________________________
Client-2 received current model Current model weights:
[[[-1.0151317119598389], [1.2023080587387085]], [0.0]]
Client 2 sent gradients.
pod "client-1-deployment" deleted
pod "client-2-deployment" deleted
We see the last state of our model and how the script is changing the model weights by adding +1 at every single weight. In reality here the Federated Averaging algorithm is applied, to aggregate a global model out of the model updates of several clients.
Now, lets delete the redis-0 pod so that another redis instance is selected as master.
pod "redis-0" deleted
Now the current master is removed and a new pod is scheduled. As a result, our master changes. Let's figure out, which redis instance is the new master:
Defaulted container "sentinel" out of: sentinel, config (init)
Our new master is redis-2. Let's update the model and see what happens.
pod/client-1-deployment created
pod/client-2-deployment created
2023-04-13 15:28:32.284359: I tensorflow/tsl/cuda/cudart_stub.cc:28] Could not find cuda drivers on your machine, GPU will not be used.
2023-04-13 15:28:32.395712: I tensorflow/tsl/cuda/cudart_stub.cc:28] Could not find cuda drivers on your machine, GPU will not be used.
2023-04-13 15:28:32.396114: I tensorflow/core/platform/cpu_feature_guard.cc:182] This TensorFlow binary is optimized to use available CPU instructions in performance-critical operations.
To enable the following instructions: AVX2 FMA, in other operations, rebuild TensorFlow with the appropriate compiler flags.
2023-04-13 15:28:33.363757: W tensorflow/compiler/tf2tensorrt/utils/py_utils.cc:38] TF-TRT Warning: Could not find TensorRT
____________________________Client 1 ______________________________________
Client-1 received current model Current model weights:
[[[-2.5949167013168335], [-5.349349141120911]], [-37.76122283935547]]
Client 1 sent gradients.
2023-04-13 15:28:32.627924: I tensorflow/tsl/cuda/cudart_stub.cc:28] Could not find cuda drivers on your machine, GPU will not be used.
2023-04-13 15:28:32.700296: I tensorflow/tsl/cuda/cudart_stub.cc:28] Could not find cuda drivers on your machine, GPU will not be used.
2023-04-13 15:28:32.700755: I tensorflow/core/platform/cpu_feature_guard.cc:182] This TensorFlow binary is optimized to use available CPU instructions in performance-critical operations.
To enable the following instructions: AVX2 FMA, in other operations, rebuild TensorFlow with the appropriate compiler flags.
2023-04-13 15:28:34.038730: W tensorflow/compiler/tf2tensorrt/utils/py_utils.cc:38] TF-TRT Warning: Could not find TensorRT
____________________________Client 2 ______________________________________
Client-2 received current model Current model weights:
[[[-2.5949167013168335], [-5.349349141120911]], [-37.76122283935547]]
Client 2 sent gradients.
pod "client-1-deployment" deleted
pod "client-2-deployment" deleted
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

