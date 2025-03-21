from flask import Flask, request, g
from flask_restful import Api
import time
import tracemalloc
from Utils.CloudMonitoringUtils import CloudMonitoringUtils
from Utils.MonitoringRecords import MonitorRecordObject
# Import specific interfaces
from Controller.CloudDataMonitoringInterface import CloudDataMonitoringInterface
from Controller.EdgeMonitoringInterface import EdgeMonitoringInterface
from Controller.StreamHandlingInterface import StreamHandlingInterface
from Controller.GeneralUtilsInterface import GeneralUtilsInterface
from flask_cors import CORS
cloud_monitor = CloudMonitoringUtils()
app = Flask(__name__)
CORS(app)  # Enable CORS for all routes
api = Api(app)
@app.before_request
def before_request():
    g.start_time = time.time()
    g.start_memory = cloud_monitor.process.memory_info().rss
    tracemalloc.start()

@app.after_request
def after_request(response):
    end_time = time.time()
    end_memory = cloud_monitor.process.memory_info().rss
    current, peak = tracemalloc.get_traced_memory()
    tracemalloc.stop()

    execution_time = end_time - g.start_time
    memory_usage = (end_memory - g.start_memory) / (1024 * 1024)  # Convert to MB
    peak_memory_usage = peak / (1024 * 1024)  # Convert to MB

    # Create a monitoring record object
    record = MonitorRecordObject(
        time=time.strftime("%d/%b/%Y %H:%M:%S", time.gmtime()),
        data=request.path,
        execution_time=execution_time,
        memory_usage=memory_usage,
        processing_info={"peak_memory_usage": peak_memory_usage}
    )

    # Write the monitoring data using CloudMonitoringUtils
    cloud_monitor.write_monitoring_data("monitoring.json", [record])

    return response


# Register specific interfaces
api.add_resource(CloudDataMonitoringInterface, '/cloud-data-monitoring')
api.add_resource(EdgeMonitoringInterface, '/edge-monitoring')
api.add_resource(StreamHandlingInterface, '/stream-handling')
api.add_resource(GeneralUtilsInterface, '/utils')



if __name__ == '__main__':

    app.run(debug=True, use_reloader=False)