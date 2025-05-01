import tensorflow as tf
import os

# Define the directory where your model is located
dir = os.path.dirname(os.path.abspath(__file__))
keras_model_path = os.path.join(dir, 'fer2013_resmasking_model.keras')  # Adjust the path accordingly

# Load your existing model
model = tf.keras.models.load_model(keras_model_path)

# Save the model in H5 format
h5_model_path = os.path.join(dir, 'fer2013_resmasking_model.h5')
model.save(h5_model_path)

print(f"Model converted and saved to {h5_model_path}")
