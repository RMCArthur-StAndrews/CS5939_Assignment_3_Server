from flask import request
from flask_restful import Resource

from Utils.MonitoringRecords import MonitorRecordObject


class EdgeMonitoringInterface(Resource):
    def get(self):
        json_data = request.get_json()
        return json_data

    def post(self):
        json_data = request.get_json()
        required_keys = ["data", "execution_time", "memory_usage", "processing_info", "time"]

        if isinstance(json_data, list):
            valid_data = []
            errors = []
            for item in json_data:
                if all(key in item for key in required_keys):
                    monitor_record = MonitorRecordObject(
                        data=item["data"],
                        execution_time=item["execution_time"],
                        memory_usage=item["memory_usage"],
                        processing_info=item["processing_info"],
                        time=item["time"]
                    )
                    valid_data.append(monitor_record.__dict__)
                else:
                    errors.append({"item": item, "error": "Missing required fields"})

            if errors:
                return {"message": "Some data is invalid", "valid_data": valid_data, "errors": errors}, 400
            else:
                return {"message": "All data is valid", "data": valid_data}
        else:
            return {"message": "Invalid data format, expected a JSON array of items"}, 400