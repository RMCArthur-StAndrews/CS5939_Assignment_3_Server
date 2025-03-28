import os
import psutil
from typing import Callable, Any, Tuple
from Utils.MonitoringRecords import MonitoringRecords, MonitorRecordObject

class CloudMonitoringUtils:
    def __init__(self):
        self.process = psutil.Process()
        self.monitor = self.get_monitoring_data("monitoring.json")

    def get_monitoring_data(self, json_file: str) -> list:
        monitoring_records = MonitoringRecords()
        return monitoring_records.read_in_from_json(json_file)

    def find_monitoring_data(self, json_file: str, key: str, value: Any) -> list:
        monitoring_records = MonitoringRecords()
        return monitoring_records.find_in_json(json_file, key, value)

    def write_monitoring_data(self, json_file: str, data: list) -> None:
        monitoring_records = MonitoringRecords()
        monitoring_records.write_out_to_json(json_file, data)

    def dump_to_cloud(self):
        if(os.getenv("OPERATION_ENV")== "edge"):
            data = self.get_monitoring_data("monitoring.json").to_json()
            # Dump to cloud storage
            try:
                #Attempt to dump data to cloud
                response = 400
                if(response == 200):
                    monitoring_records = MonitoringRecords()
                    monitoring_records.wipe_data(json_file)
                    return True
            except Exception as e:
                print(f"Error: {e}")

        return False

