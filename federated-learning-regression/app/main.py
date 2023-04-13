# Server code
from tensorflow.keras.models import load_model
from datetime import datetime
import uvicorn
from fastapi import FastAPI, Body
import redis
import json
import numpy as np
from io import BytesIO
import sys
import os

# ___________________________________ Helper functions______________________________________

def array_to_bytes(x: np.ndarray) -> bytes:
    np_bytes = BytesIO()
    np.save(np_bytes, x, allow_pickle=True)
    return np_bytes.getvalue()

def bytes_to_array(b: bytes) -> np.ndarray:
    np_bytes = BytesIO(b)
    return np.load(np_bytes, allow_pickle=True)

app = FastAPI()

service_ip = os.environ.get('POD_IP')


r = redis.Redis(
    host=service_ip,
    port=6379, 
    password='a-very-complex-password-here')

inital_master = os.environ.get('INITIAL_MASTER')

if inital_master == 'inital_master':
    init_model = load_model('./linear_regressor.h5')
    weights = init_model.get_weights()
    weights_np = np.array(weights)
    weights_bytes = array_to_bytes(weights_np)
    r.set('model', weights_bytes)
    r.set('gradients_received', 0)
    r.set('sum_gradients', array_to_bytes(np.zeros_like(weights_np)))

@app.get("/")
def index():
    return {"message": "Model is loaded into memory"}

@app.post("/send_gradients/")
async def send_gradients(gradients: list = Body(...)):
    gradients = [np.array(g) for g in gradients]

    gradients_received = int(r.get('gradients_received'))
    
    sum_gradients = bytes_to_array(r.get('sum_gradients'))

    sum_gradients += gradients
    gradients_received += 1
    print(f'{gradients_received} clients sent their model updates.')

    r.set('sum_gradients', array_to_bytes(sum_gradients))
    r.set('gradients_received', gradients_received)

    if gradients_received >= 2:
        
        #Applying Fed. Averaging
        avg_gradients = sum_gradients / gradients_received

        value = r.get('model')
        weights_np = bytes_to_array(value)

        # Update model weights
        weights_np += avg_gradients

        # Save the updated model
        weights_bytes = array_to_bytes(weights_np)
        r.set('model', weights_bytes)
        r.set('gradients_received', 0)
        r.set('sum_gradients', array_to_bytes(np.zeros_like(weights_np)))

        print("All model updates received. New model has the following weights:")
        print(weights_np)
        return {"message": "Received all necessary model updates."}

    return {"message": "Gradient updates received"}

@app.get("/get_model/")
async def get_model():
    value = r.get('model')

    weights_np = bytes_to_array(value)
    weights_list = [w.tolist() for w in weights_np]

    return {"message": weights_list}

if __name__ == "__main__":
    uvicorn.run("main:app", port=8000, reload=True)
