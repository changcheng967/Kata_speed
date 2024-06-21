import os
from datetime import datetime

import numpy as np
import tensorflow as tf
from tensorflow.keras.models import Sequential
from tensorflow.keras.layers import Dense, Conv2D, Flatten
from tensorflow.keras.callbacks import ModelCheckpoint, TensorBoard

# Constants
BOARD_SIZE = 9
NUM_SAMPLES = 1000

# Set random seed for reproducibility
np.random.seed(42)
tf.random.set_seed(42)

def generate_synthetic_data(num_samples=NUM_SAMPLES, board_size=BOARD_SIZE):
    """
    Generates synthetic dataset for training.

    Parameters:
    - num_samples (int): Number of samples to generate.
    - board_size (int): Size of the board (square board).

    Returns:
    - X_train (np.ndarray): Input data (board states).
    - y_train (np.ndarray): Target labels (0 or 1).
    """
    X_train = np.random.randint(0, 3, size=(num_samples, board_size, board_size, 1))
    y_train = np.random.randint(0, 2, size=(num_samples,))
    return X_train, y_train

def load_data():
    """
    Loads and preprocesses data. Currently generates synthetic data.

    Returns:
    - X_train (np.ndarray): Input data (board states).
    - y_train (np.ndarray): Target labels (0 or 1).
    """
    return generate_synthetic_data()

def build_model(input_shape):
    """
    Defines the neural network architecture.

    Parameters:
    - input_shape (tuple): Shape of the input data (excluding batch size).

    Returns:
    - model (tf.keras.models.Sequential): Compiled Keras model.
    """
    model = Sequential([
        Conv2D(64, kernel_size=3, activation='relu', input_shape=input_shape),
        Conv2D(128, kernel_size=3, activation='relu'),
        Flatten(),
        Dense(256, activation='relu'),
        Dense(1, activation='sigmoid')
    ])
    return model

def compile_model(model):
    """
    Compiles the Keras model.

    Parameters:
    - model (tf.keras.models.Sequential): Keras model to compile.
    """
    model.compile(optimizer='adam', loss='binary_crossentropy', metrics=['accuracy'])

def get_tensorboard_callback():
    """
    Sets up TensorBoard callback for model training.

    Returns:
    - TensorBoard callback object.
    """
    log_dir = os.path.join("logs", datetime.now().strftime("%Y%m%d-%H%M%S"))
    return TensorBoard(log_dir=log_dir, histogram_freq=1)

def get_checkpoint_callback():
    """
    Sets up ModelCheckpoint callback for model training.

    Returns:
    - ModelCheckpoint callback object.
    """
    checkpoint_dir = 'checkpoints'
    os.makedirs(checkpoint_dir, exist_ok=True)
    checkpoint_path = os.path.join(checkpoint_dir, "model_epoch_{epoch:02d}_val_loss_{val_loss:.2f}.h5")
    return ModelCheckpoint(filepath=checkpoint_path, save_best_only=True, monitor='val_loss', verbose=1)

def train_model(model, X_train, y_train, batch_size=32, epochs=10):
    """
    Trains the Keras model.

    Parameters:
    - model (tf.keras.models.Sequential): Compiled Keras model.
    - X_train (np.ndarray): Input data (board states).
    - y_train (np.ndarray): Target labels (0 or 1).
    - batch_size (int): Number of samples per gradient update.
    - epochs (int): Number of epochs to train the model.

    """
    tensorboard_callback = get_tensorboard_callback()
    checkpoint_callback = get_checkpoint_callback()
    model.fit(X_train, y_train, batch_size=batch_size, epochs=epochs, 
              validation_split=0.2, callbacks=[tensorboard_callback, checkpoint_callback])

    # Save the model in .h5 format
    model_filename = os.path.join("models", f"model_{datetime.now().strftime('%Y%m%d%H%M%S')}.h5")
    model.save(model_filename)
    print(f"Model saved as {model_filename}")

def main():
    """
    Main function to run the script.
    """
    X_train, y_train = load_data()
    model = build_model(input_shape=(BOARD_SIZE, BOARD_SIZE, 1))
    compile_model(model)
    train_model(model, X_train, y_train)

if __name__ == "__main__":
    main()
