from tensorflow.keras.models import load_model
from datetime import datetime
import uvicorn
from fastapi import FastAPI
import redis
import json
import numpy as np
from io import BytesIO
import sys
import os

"""
    The following code describes a REST-API interface, used for interacting with Redis instances.
"""

# ___________________________________ Helper functions______________________________________

def array_to_bytes(x: np.ndarray) -> bytes:
    np_bytes = BytesIO()
    np.save(np_bytes, x, allow_pickle=True)
    return np_bytes.getvalue()


def bytes_to_array(b: bytes) -> np.ndarray:
    np_bytes = BytesIO(b)
    return np.load(np_bytes, allow_pickle=True)


app = FastAPI() # run the REST API

service_ip = os.environ.get('POD_IP')

r = redis.Redis(
    host=service_ip,
    port=6379, 
    password='a-very-complex-password-here')

inital_master = os.environ.get('INITIAL_MASTER')

if inital_master == 'inital_master':
    # put initial model into the database
    init_model = load_model('./model_simpel.h5')
    weights = init_model.get_weights()
    weights_np = np.array(weights)
    weights_bytes = array_to_bytes(weights_np)
    r.set('model', weights_bytes)

@app.get("/")
def index():
    #load the model
    return { "message": "Model is loaded into memory"}

@app.get("/update_model/")
async def update_model():
    value = r.get('model')

    weights_np = bytes_to_array(value).tolist()

    print("Weights before update..", datetime.now())
    print(weights_np)

    #updating model weights by simply adding scalar value to every single weight
    for i in range(0,len(weights_np)):
        weights_np[i] += 1

    print("Weights after update..", datetime.now())
    print(weights_np)

    #At the end, save the model
    weights_bytes = array_to_bytes(weights_np)

    #Update redis model version
    r.set('model', weights_bytes)

    return { "message": str(weights_np)}


@app.get("/get_model/")
async def get_model():
    value = r.get('model')

    weights_np = bytes_to_array(value).tolist()

    print("Weights before update..", datetime.now())
    print(weights_np)

    return { "message": str(weights_np)}


if __name__ == "__main__":
    uvicorn.run("main:app", port=8000, reload=True)




