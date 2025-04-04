import json
import os
import string
import time
import random

import pandas as pd

class MonitoringRecords:
    def read_in_from_json(self, json_file):
        """
        Reads data from a JSON file and returns it as a pandas DataFrame.
        If the file does not exist, creates an empty DataFrame and writes it to the file.
        Handles JSON decoding errors and file permission errors
        
        :param json_file: Path to the JSON file.
        :return: DataFrame containing the data from the JSON file.
        """
        try:
            with open(json_file, 'r') as file:
                try:
                    data = json.load(file)
                except json.JSONDecodeError:
                    data = []
            df = pd.DataFrame(data)
        except FileNotFoundError:
            df = pd.DataFrame()
            df.to_json(json_file, orient='records', indent=4)
        except PermissionError: # Makes sure that we don't read the file while it's being written to
            time.sleep(1)
            return self.read_in_from_json(json_file)
        return df

    def write_out_to_json(self, json_file, data):
        """
        Writes data to a JSON file. If the file already exists, appends the new data to it.
        Handles file not found and permission errors
        
        :param json_file: Path to the JSON file.
        :param data: List of objects to write to the JSON file.
        """
        try:
            existing_data = self.read_in_from_json(json_file)
            new_data = pd.DataFrame([obj.__dict__ for obj in data])
            combined_data = pd.concat([existing_data, new_data], ignore_index=True)
        except FileNotFoundError:
            combined_data = pd.DataFrame([obj.__dict__ for obj in data])
        except PermissionError: # Makes sure that we don't read the file while it's being read to
            time.sleep(1)
            return self.write_out_to_json(json_file, data)
        combined_data.to_json(json_file, orient='records', indent=4)

    def find_in_json(self, json_file, key, value):
        """
        Finds records in the JSON file where the specified key matches the given value
        
        :param json_file: Path to the JSON file.
        :param key: Key to search for.
        :param value: Value to match.
        :return: List of matching records as dictionaries.
        """
        df = self.read_in_from_json(json_file)
        return df[df[key] == value].to_dict(orient='records')

    def wipe_data(self, json_file):
        """
        Deletes the JSON file and creates a new empty one
        
        :param json_file: Path to the JSON file.
        """
        try:
            os.remove(json_file)
            f = open(json_file, "w")
            f.close()
        except Exception as e:
            print(f"Error: {e}")

class MonitorRecordObject:
    def __init__(self, data, execution_time, memory_usage, processing_info, time):
        """
        Initializes a new monitoring record object
        
        :param data: Data related to the monitoring record.
        :param execution_time: Execution time of the monitored process.
        :param memory_usage: Memory usage of the monitored process.
        :param processing_info: Additional processing information.
        :param time: Time of occurrence of the monitoring record.
        """
        self.time_of_occurence= time
        self.execution_hash= ''.join(random.choices(string.ascii_letters + string.digits, k=16))
        self.data = data
        self.execution_time = execution_time
        self.memory_usage = memory_usage
        self.processing_info = processing_info
