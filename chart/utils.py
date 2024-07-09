import numpy as np
import cv2
from keras.models import load_model

def predict_image(image, action):
    print(action)
    if action == 'ck':
        model_path = 'static/models/ck+_FaceExpNet_model.h5'
    elif action == 'fer':
        model_path = 'static/models/fer2013_resmasking_model.h5'
    else:
        raise ValueError("Invalid action choice")
    
    model = load_model(model_path)
    
    # Assuming the model expects a specific input shape, adjust image accordingly
    # Example: Resizing the image and normalizing it
    image_resized = cv2.resize(image, (224, 224))  # Adjust the size as per your model requirement
    image_normalized = image_resized / 255.0  # Normalize if required by the model
    image_batch = np.expand_dims(image_normalized, axis=0)  # Create batch dimension

    prediction = model.predict(image_batch)
    predicted_label = np.argmax(prediction, axis=1)
    
    # Convert prediction back to an image
