from django.db import models
from PIL import Image
import numpy as np
from .utils import predict_image
from io import BytesIO
from django.core.files.base import ContentFile

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

        pil_img = Image.open(self.image.path)
        cv_image = np.array(pil_img)
        img = predict_image(cv_image, self.action)

        # Save the processed image back (if needed)
        processed_image = Image.fromarray(img)

        buffr = BytesIO()
        processed_image.save(buffr, format='PNG')
        image_png = buffr.getvalue()

        self.image.save(str(self.image), ContentFile(image_png), save=False)
        super().save(*args, **kwargs)