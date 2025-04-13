import os
import psutil
from typing import Callable, Any, Tuple
from Utils.MonitoringRecords import MonitoringRecords, MonitorRecordObject

class CloudMonitoringUtils:
    def __init__(self):
        """
        Initializes the CloudMonitoringUtils class.
        Sets up the process monitoring and loads existing monitoring data
        """
        self.process = psutil.Process()
        self.monitor = self.get_monitoring_data("monitoring.json")

    def get_monitoring_data(self, json_file: str) -> list:
        """
        Reads monitoring data from a JSON file
        
        :param json_file: Path to the JSON file.
        :return: List of monitoring records.
        """
        monitoring_records = MonitoringRecords()
        return monitoring_records.read_in_from_json(json_file)

    def find_monitoring_data(self, json_file: str, key: str, value: Any) -> list:
        """
        Finds monitoring data in the JSON file where the specified key matches the given value
        
        :param json_file: Path to the JSON file.
        :param key: Key to search for.
        :param value: Value to match.
        :return: List of matching monitoring records.
        """
        monitoring_records = MonitoringRecords()
        return monitoring_records.find_in_json(json_file, key, value)

    def write_monitoring_data(self, json_file: str, data: list) -> None:
        """
        Writes monitoring data to a JSON file
        
        :param json_file: Path to the JSON file.
        :param data: List of monitoring records to write.
        """
        monitoring_records = MonitoringRecords()
        monitoring_records.write_out_to_json(json_file, data)

    def dump_to_cloud(self):
        """
        Dumps the monitoring data to cloud storage if the environment is set to edge devices.
        Wipes the local monitoring data if the dump is successful
        
        :return: True if the data was successfully dumped to the cloud, False otherwise.
        """
        if(os.getenv("OPERATION_ENV") == "edge"):
            data = self.get_monitoring_data("monitoring.json").to_json()
            try:
                response = 400
                if(response == 200):
                    monitoring_records = MonitoringRecords()
                    monitoring_records.wipe_data(json_file)
                    return True
            except Exception as e:
                print(f"Error: {e}")

        return False
