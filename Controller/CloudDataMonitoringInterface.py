from flask_restful import Resource
from Utils.CloudMonitoringUtils import CloudMonitoringUtils
class CloudDataMonitoringInterface(Resource):
    """
    Class handles all operations related to the cloud data monitoring interface.
    """
    def get(self):
        """
        Get the monitoring data from the cloud.
        :return: A JSON response containing the monitoring data.
        """
        util = CloudMonitoringUtils()
        return util.get_monitoring_data("monitoring.json").to_json(orient='records')
