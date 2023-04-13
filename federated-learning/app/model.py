import tensorflow as tf
from tensorflow.keras.models import Sequential
from tensorflow.keras.layers import Conv2D, Conv1D
from tensorflow.keras.layers import MaxPooling2D
from tensorflow.keras.layers import Activation
from tensorflow.keras.layers import Flatten
from tensorflow.keras.layers import Dense
from tensorflow.keras import layers
from tensorflow.keras.models import load_model
from tensorflow.keras.optimizers import SGD
from tensorflow.keras import backend as K
import keras

import tensorflow as tf
import matplotlib.pyplot as pltfrom 
from tensorflow.keras import datasets, layers, models, losses

class SimpleConv:
    @staticmethod
    def build(classes):
        model = Sequential()
        model.add(layers.Conv1D(1, (1),input_shape=(2,2)))
        model.add(layers.Dense(classes, activation="softmax"))
        return model

init_model = SimpleConv()
init_model = init_model.build(2)
