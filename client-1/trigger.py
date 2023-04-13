# client1.py
import requests
import os
import numpy as np
import tensorflow as tf
from tensorflow.keras.models import Sequential, clone_model
from tensorflow.keras.layers import Dense
from tensorflow.keras.optimizers import Adam
from sklearn.datasets import make_regression

print("____________________________Client 1 ______________________________________")

# Generate a dataset for Client 1
X1, y1 = make_regression(n_samples=100, n_features=2, noise=0.1, random_state=1)

# Load the model for Client 1
class LinearRegressor:
    @staticmethod
    def build():
        model = Sequential()
        model.add(Dense(1, input_dim=2, activation="linear"))
        return model

# Build the model
model = LinearRegressor.build()

# Compile the model with mean squared error loss and Adam optimizer
model.compile(loss="mean_squared_error", optimizer=Adam(learning_rate=0.01))

POD_IP = os.environ.get('POD_IP')

# Get the model weights from the server
r = requests.get(f'http://{POD_IP}:8000/get_model/')
server_weights = r.json()["message"]
print("Client-1 received current model Current model weights:")
print(server_weights)
server_weights = [np.array(w) for w in server_weights]
# Update the model weights
model.set_weights(server_weights)

# Train the model for one epoch and compute gradients
with tf.GradientTape() as tape:
    y_pred = model(X1, training=True)
    loss = tf.reduce_mean(tf.losses.mean_squared_error(y1, y_pred))

# Calculate gradients
gradients = tape.gradient(loss, model.trainable_weights)

# Convert gradients to list of lists
gradients_list = [g.numpy().tolist() for g in gradients]

# Client 1 sends gradients
r = requests.post(f'http://{POD_IP}:8000/send_gradients/', json=gradients_list)

print(f"Client 1 sent gradients.")

