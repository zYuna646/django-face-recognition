# myapp/consumers.py
import cv2
import base64
from channels.generic.websocket import AsyncWebsocketConsumer

class VideoConsumer(AsyncWebsocketConsumer):
    async def connect(self):
        await self.accept()

    async def disconnect(self, close_code):
        pass

    async def send_frame(self, frame):
        await self.send(text_data=frame)

    async def receive(self, text_data):
        pass
