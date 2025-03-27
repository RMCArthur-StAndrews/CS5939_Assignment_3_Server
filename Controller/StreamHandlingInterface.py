import base64
import json

from cryptography.fernet import Fernet
from flask_restful import Resource
from flask import request, jsonify

from Utils.VideoAnalyticsModelService import VideoAnalyticsModelService


class StreamHandlingInterface(Resource):

    def __init__(self):
        self.model_service = VideoAnalyticsModelService(model_path='yolo11n.pt')
        self.cloud_key = base64.urlsafe_b64encode(b"CLOUD_KEY".ljust(32, b'\0'))
        self.edge_key = base64.urlsafe_b64encode(b"EDGE_KEY".ljust(32, b'\0'))
        self.edge_to_cloud_decrypt = Fernet(self.edge_key)
        self.cloud_to_edge_encrypt = Fernet(self.cloud_key)
    def get(self):
        return {"message": "Stream Handling Interface"}

    def post(self):
        if 'image' not in request.files:
            return {"message": "No image part in the request"}, 400
        image = request.files['image']
        if image.filename == '':
            return {"message": "No selected image"}, 400
        image = self.edge_to_cloud_decrypt.decrypt(image.read())
        result = self.model_service.analyse_frame(image)
        json_data= json.dumps(result, indent=4).encode('utf-8')
        encrypted_data = self.cloud_to_edge_encrypt.encrypt(json_data)
        return jsonify({"data": encrypted_data.decode('utf-8')})