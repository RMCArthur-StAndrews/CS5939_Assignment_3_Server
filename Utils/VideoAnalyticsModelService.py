from random import random

import cv2
import numpy as np
from ultralytics import YOLO

class VideoAnalyticsModelService:
    def __init__(self, model_path='yolo11n.pt'):
        self.color_map = {}
        self.thickness = 1
        self.model = YOLO(model_path)  # Load the YOLO model

    def analyze_frame(self, frame: bytes) -> dict:
        np_frame = np.frombuffer(frame, np.uint8)
        img = cv2.imdecode(np_frame, cv2.IMREAD_COLOR)

        results = self.model(img)  # Perform object detection
        detections = []
        for result in results:

            for box in result.boxes:
                detections.append({
                    'class': int(box.cls),
                    'name': result.names[int(box.cls)],
                    'confidence': float(box.conf),
                    'bbox': box.xyxy.tolist()
                })

        return {'detections': detections}
