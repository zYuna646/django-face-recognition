from django.db import models
from PIL import Image
import numpy as np
from io import BytesIO
from django.core.files.base import ContentFile
from .utils import predict_image

ACTION_CHOICES = (
    ('ck', 'ck+'),
    ('fer', 'fer2013'),
)

class Upload(models.Model):
    image = models.ImageField(upload_to='images/')
    action = models.CharField(max_length=50, choices=ACTION_CHOICES)
    updated = models.DateTimeField(auto_now=True)
    created = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return str(self.id)
    
    def save(self, *args, **kwargs):
        super().save(*args, **kwargs)  # Save the instance first to get the image path

        # Open and process the image
        pil_img = Image.open(self.image.path)
        cv_image = np.array(pil_img)
        processed_image = predict_image(cv_image, self.action)

        # Convert processed image array to PIL image
        processed_pil_img = Image.fromarray(processed_image.astype('uint8'))

        # Save the processed image back to the model instance's image field
        buffered = BytesIO()
        processed_pil_img.save(buffered, format='PNG')
        img_str = buffered.getvalue()

        self.image.save(f'{self.id}.png', ContentFile(img_str), save=False)
        super().save(*args, **kwargs)
