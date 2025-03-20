from flask_restful import Resource
from Utils.CloudMonitoringUtils import CloudMonitoringUtils
class CloudDataMonitoringInterface(Resource):
    def get(self):
        util = CloudMonitoringUtils()
        return util.get_monitoring_data("monitoring.json").to_json(orient='records')

    def post(self):
        return {"message": "Cloud Data Monitoring Interface - POST"}
