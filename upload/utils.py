import numpy as np
import cv2
import tensorflow as tf
from tensorflow.keras.models import load_model

def predict_image(image, action):
    # Pilih model berdasarkan action
    if action == 'ck':
        model_path = 'static/models/ck+_FaceExpNet_model.keras'
        target_size = (48, 48)
        grayscale = True
    elif action == 'fer':
        model_path = 'static/models/fer2013_resmasking_model.keras'
        target_size = (48, 48)
        grayscale = False
    else:
        raise ValueError("Invalid action")

    # Load model (tanpa compile, lebih aman di TF 2.15)
    model = load_model(model_path, compile=False)

    # Konversi RGBA ke RGB jika perlu
    if image.shape[-1] == 4:
        image = cv2.cvtColor(image, cv2.COLOR_RGBA2RGB)

    # Resize
    image_resized = cv2.resize(image, target_size)

    # Jika perlu ubah ke grayscale
    if grayscale:
        image_resized = cv2.cvtColor(image_resized, cv2.COLOR_BGR2GRAY)
        image_resized = np.expand_dims(image_resized, axis=-1)

    # Normalisasi dan bentuk batch
    image_normalized = image_resized / 255.0
    image_batch = np.expand_dims(image_normalized, axis=0)

    # Prediksi
    prediction = model.predict(image_batch)
    predicted_label_index = np.argmax(prediction, axis=1)[0]
    accuracy = float(prediction[0][predicted_label_index] * 100)

    # Label emosi
    emotions = ["angry", "disgust", "fear", "happy", "neutral", "sad", "surprise"]
    predicted_label = emotions[predicted_label_index]

    return predicted_label, accuracy
import base64

def image_array_to_base64(image_array):
    if image_array.dtype != np.uint8:
        image_array = np.clip(image_array * 255, 0, 255).astype(np.uint8)

    _, buffer = cv2.imencode('.png', image_array)
    image_base64 = base64.b64encode(buffer).decode('utf-8')

    return image_base64
