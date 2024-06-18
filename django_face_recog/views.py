
from django.shortcuts import render
import cv2
import base64
from django.http import StreamingHttpResponse
from django.http import JsonResponse
from .consumers import VideoConsumer
 
def index(request):

    return render(request, 'index.html')

