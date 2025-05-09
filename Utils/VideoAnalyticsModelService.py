import time
import tracemalloc

import psutil
import cv2
import numpy as np
from ultralytics import YOLO
from Utils.CloudMonitoringUtils import CloudMonitoringUtils
from Utils.MonitoringRecords import MonitorRecordObject


class VideoAnalyticsModelService:
    """
    Class explicitly handles object detection using the provided model
    """
    def __init__(self, model_path='yolo11n.pt'):
        """
        Constructor for the VideoAnalyticsModelService class
        :param model_path: The model to use for object detection
        """
        self.color_map = {}
        self.thickness = 1
        self.model = YOLO(model_path)
        self.process = psutil.Process()
        self.cloud_monitor = CloudMonitoringUtils()

    def analyse_frame(self, frame: bytes) -> dict:
        """
        Method to analyse a single frame for object detection
        :param frame: The frame image to be analysed
        :return: List of detections as JSON
        """
        start_time = time.time()
        start_memory = self.process.memory_info().rss
        start_cpu_times = self.process.cpu_times()  # Record CPU times
        tracemalloc.start()

        np_frame = np.frombuffer(frame, np.uint8)
        img = cv2.imdecode(np_frame, cv2.IMREAD_COLOR)

        results = self.model(img)
        _, peak = tracemalloc.get_traced_memory()
        end_time = time.time()
        end_memory = self.process.memory_info().rss
        end_cpu_times = self.process.cpu_times()  # Record CPU times again

        execution_time = end_time - start_time
        memory_usage = (end_memory - start_memory) / (1024 * 1024)
        peak_memory_usage = peak / (1024 * 1024)

        # Calculate CPU usage
        cpu_usage = {
            "user_time": end_cpu_times.user - start_cpu_times.user,
            "system_time": end_cpu_times.system - start_cpu_times.system
        }

        detections = []
        for result in results:
            for box in result.boxes:
                detections.append({
                    'class': int(box.cls),
                    'name': result.names[int(box.cls)],
                    'confidence': float(box.conf),
                    'bbox': box.xyxy.tolist()
                })

        record = MonitorRecordObject(
            time=time.strftime("%d/%b/%Y %H:%M:%S", time.gmtime()),
            data='frame_analysis',
            execution_time=execution_time,
            memory_usage=abs(peak_memory_usage),
            processing_info={
                "cpu_usage": cpu_usage
            }
        )
        self.cloud_monitor.write_monitoring_data("monitoring.json", [record])
        return {'detections': detections}
