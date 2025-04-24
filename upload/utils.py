import numpy as np
import cv2
from tensorflow.keras.models import load_model

def predict_image(image, action):
    if action == 'ck':
        model_path = 'static/models/ck+_FaceExpNet_model.h5'
        target_size = (48, 48)  # Assuming CK+ model expects 48x48 grayscale images
        grayscale = True
    elif action == 'fer':
        model_path = 'static/models/fer2013_resmasking_model.h5'
        target_size = (48, 48)  # Assuming FER2013 model expects 48x48 RGB images
        grayscale = False
    else:
        raise ValueError("Invalid action choice")
    
    model = load_model(model_path)
    
    # Check if image has 4 channels (RGBA) and convert to RGB
    if len(image.shape) == 3 and image.shape[2] == 4:
        image = cv2.cvtColor(image, cv2.COLOR_RGBA2RGB)
    
    # Resize the image
    image_resized = cv2.resize(image, target_size)
    
    # Convert to grayscale if needed
    if grayscale and len(image_resized.shape) == 3:
        image_resized = cv2.cvtColor(image_resized, cv2.COLOR_BGR2GRAY)
    
    # Add channel dimension if grayscale
    if grayscale:
        image_resized = np.expand_dims(image_resized, axis=-1)
    
    # Normalize the image
    image_normalized = image_resized / 255.0
    
    # Expand dimensions to match the model input
    image_batch = np.expand_dims(image_normalized, axis=0)
    
    # Perform prediction
    prediction = model.predict(image_batch)
    predicted_label_index = np.argmax(prediction, axis=1)[0]
    
    # Convert numpy.float32 to Python float for JSON serialization
    accuracy = float(prediction[0][predicted_label_index] * 100)
    
    # Mapping of label indices to emotion strings
    emotions = ["angry", "disgust", "fear", "happy", "neutral", "sad", "surprise"]
    predicted_label = emotions[predicted_label_index]
    
    return predicted_label, accuracy

import numpy as np
import base64

# Example function to convert image array to base64 string
def image_array_to_base64(image_array):
    # Ensure image_array is in uint8 format and not float (convert if necessary)
    if image_array.dtype == np.float32:
        image_array = (image_array * 255).astype(np.uint8)
    
    # Encode image array to base64 string
    _, buffer = cv2.imencode('.png', image_array)
    image_base64 = base64.b64encode(buffer).decode('utf-8')
    
    return image_base64