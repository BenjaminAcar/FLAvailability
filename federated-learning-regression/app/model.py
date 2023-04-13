import tensorflow as tf
from tensorflow.keras.models import Sequential
from tensorflow.keras.layers import Dense
from tensorflow.keras.optimizers import Adam

class LinearRegressor:
    @staticmethod
    def build():
        model = Sequential()
        model.add(Dense(1, input_dim=2, activation="linear"))
        return model

# Build the model
model = LinearRegressor.build()

# Compile the model with mean squared error loss and Adam optimizer
model.compile(loss="mean_squared_error", optimizer=Adam(lr=0.01))

# Save the model
model.save("./linear_regressor.h5")