import keras
from keras.models import Sequential
from keras.layers import Dense, Conv2D, Flatten
import gzip
import pickle

# Define the neural network architecture
model = Sequential([
    Conv2D(64, kernel_size=3, activation='relu', input_shape=(19, 19, 1)),
    Conv2D(128, kernel_size=3, activation='relu'),
    Flatten(),
    Dense(256, activation='relu'),
    Dense(1, activation='sigmoid')
])

# Compile the model
model.compile(optimizer='adam', loss='binary_crossentropy', metrics=['accuracy'])

# Train the model (replace X_train and y_train with your training data)
# model.fit(X_train, y_train, epochs=10, batch_size=32)

# Save the trained model in .bin.gz format
model.save('go_ai_model.h5')
with open('go_ai_model.bin.gz', 'wb') as f_out, open('go_ai_model.h5', 'rb') as f_in:
    f_out.write(gzip.compress(f_in.read()))

# Delete the original .h5 file
import os
os.remove('go_ai_model.h5')
