import json
import os
import string
import time
import random

import pandas as pd

class MonitoringRecords:
    def read_in_from_json(self, json_file):
        try:
            with open(json_file, 'r') as file:
                data = json.load(file)
            df = pd.DataFrame(data)
        except FileNotFoundError:
            df = pd.DataFrame()
            df.to_json(json_file, orient='records', indent=4)
        except PermissionError: # Makes sure that we don't read the file while it's being written to
            time.sleep(1)
            return self.read_in_from_json(json_file)
        return df

    def write_out_to_json(self, json_file, data):
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
        df = self.read_in_from_json(json_file)
        return df[df[key] == value].to_dict(orient='records')

    def wipe_data(self, json_file):
        #delete the file and create a new one
        try:
            os.remove(json_file)
            f = open(json_file, "w")
            f.close()
        except Exception as e:
            print(f"Error: {e}")

class MonitorRecordObject:
    def __init__(self, data, execution_time, memory_usage, processing_info, time):
        self.time_of_occurence= time
        self.execution_hash= ''.join(random.choices(string.ascii_letters + string.digits, k=16))
        self.data = data
        self.execution_time = execution_time
        self.memory_usage = memory_usage
        self.processing_info = processing_info