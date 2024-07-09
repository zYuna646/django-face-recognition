from django.shortcuts import render
from django.http import JsonResponse
from .models import Upload  # Import your Upload model

def upload_image(request):
    if request.method == 'POST':
        # Handle file upload and processing here
        # Example: Save the uploaded image using the Upload model
        image_file = request.FILES.get('image')  # Assuming your form uploads an image with name 'image'
        action = request.POST.get('action')  # Assuming you also receive 'action' parameter
        
        # Save uploaded image to Upload model
        upload_instance = Upload(image=image_file, action=action)
        upload_instance.save()
        
        # Perform any additional processing here (e.g., image prediction)
        # Example: Fetch processed image path or data to return in JSON response
        
        # Return JSON response with success message or processed data
        return JsonResponse({'message': 'Image uploaded successfully.'})
    
    # Handle GET request (if needed)
    return render(request, 'index.html')  # Replace 'index.html' with your actual template name
