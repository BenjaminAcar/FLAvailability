import requests
import time
import os

# This file is used to trigger the redis interfaces in order to make a model weight change.
POD_IP = os.environ.get('POD_IP')

r = requests.get(f'http://{POD_IP}:8000/get_model/')
print("Model before Update:")
print(r.content)

r = requests.get(f'http://{POD_IP}:8000/update_model/')
print("Model after Update:")
print(r.content)