from django.shortcuts import render
import cv2
import base64
import numpy as np
from django.http import StreamingHttpResponse, JsonResponse
from .consumers import VideoConsumer
from upload.models import Upload
from django.shortcuts import render, redirect
from upload.utils import predict_image, image_array_to_base64
from PIL import Image
from io import BytesIO
import json

def index(request):
    return render(request, 'index.html')

def upload_image(request):
    if request.method == 'POST':
        image_file = request.FILES['image']
        action = request.POST.get('action')  # assuming action is sent via form
        
        # Process the image
        pil_img = Image.open(image_file)
        cv_image = np.array(pil_img)
        predicted_label, accuracy = predict_image(cv_image, action)
        
        # Convert image to base64 to display in the template
        buffered = BytesIO()
        pil_img.save(buffered, format="PNG")
        img_str = base64.b64encode(buffered.getvalue()).decode("utf-8")
        
        # Return the label, accuracy, and image in the context
        context = {
            'predicted_label': predicted_label,
            'accuracy': accuracy,
            'image_base64': img_str,
        }
        return render(request, 'upload_image.html', context)
    
    return render(request, 'upload_image.html')


def camera(request):
    return render(request, 'camera.html')

def predict_camera(request):
    if request.method == 'POST':
        data = json.loads(request.body)
        image_data = data.get('image')
        action = data.get('action')
        
        # Decode the base64 image
        image_data = image_data.split(',')[1]
        image_bytes = base64.b64decode(image_data)
        pil_img = Image.open(BytesIO(image_bytes))
        cv_image = np.array(pil_img)

        # Predict the image
        predicted_label, accuracy = predict_image(cv_image, action)

        return JsonResponse({
            'success': True,
            'predicted_label': predicted_label,
            'accuracy': accuracy
        })
    
    return JsonResponse({'success': False, 'error': 'Invalid request method'})