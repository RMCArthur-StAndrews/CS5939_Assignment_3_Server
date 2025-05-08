import logging
import os
import psutil
from flask import Flask, request, g, abort
from flask_restful import Api
import time
import tracemalloc
from Utils.CloudMonitoringUtils import CloudMonitoringUtils
from Utils.MonitoringRecords import MonitorRecordObject
from Controller.CloudDataMonitoringInterface import CloudDataMonitoringInterface
from Controller.StreamHandlingInterface import StreamHandlingInterface
from Controller.GeneralUtilsInterface import GeneralUtilsInterface
from flask_cors import CORS

"""
Run config setup and initialisation of API 
"""

state = os.getenv('state', 'dev')

if state == 'prod':
    logging.info('Running in Production mode')
    print('Running in Production mode')
    EDGE_IP = ['10.0.0.1']
else:
    logging.info('Running in Development mode')
    print('Running in Development mode')
    EDGE_IP = ['', '127.0.0.1']

CLOUD_IP = ['127.0.0.1']# For DEV and PROD

cloud_monitor = CloudMonitoringUtils()
app = Flask(__name__)
CORS(app)
api = Api(app)


api.add_resource(CloudDataMonitoringInterface, '/cloud-data-monitoring')
api.add_resource(StreamHandlingInterface, '/stream-handling')
api.add_resource(GeneralUtilsInterface, '/utils')



"""
End of config setup and initialisation of API
"""

@app.before_request
def before_request():
    """
    This method is called before each call request to the Flask application.
    Performs (start of) monitoring and restrictions by IP address of receiver.
    """
    if request.path != '/utils':
        if request.path == '/stream-handling' and request.remote_addr not in EDGE_IP:
            abort(403)

        if request.path == '/cloud-monitoring' and request.remote_addr not in CLOUD_IP:
            abort(403)

    g.start_time = time.time()
    process = psutil.Process()  # Explicitly get the current process
    g.start_memory = process.memory_info().rss  # Start memory usage in bytes

@app.after_request
def after_request(response):
    """
    This method is called after each request to the Flask application.
    It performs the end of performance monitoring and writes the data to a JSON file.
    :param response: Carrier of the response data
    :return: The response data to be sent out
    """
    if response.status_code == 403:
        return response

    end_time = time.time()
    process = psutil.Process()  # Explicitly get the current process
    end_memory = process.memory_info().rss  # End memory usage in bytes
    peak_memory = process.memory_info().vms  # Peak memory usage (virtual memory size)

    execution_time = end_time - g.start_time
    memory_usage = max(0, abs(end_memory - g.start_memory)) / (1024 * 1024)  # Ensure non-negative memory usage
    peak_memory_usage = peak_memory / (1024 * 1024)  # Convert peak memory usage to MB

    record = MonitorRecordObject(
        time=time.strftime("%d/%b/%Y %H:%M:%S", time.gmtime()),
        data=request.path,
        execution_time=execution_time,
        memory_usage=memory_usage,
        processing_info={"peak_memory_usage": peak_memory_usage}  # Record peak memory usage
    )

    cloud_monitor.write_monitoring_data("monitoring.json", [record])

    return response

if __name__ == '__main__':
    app.run(host= '0.0.0.0', debug=True, use_reloader=False)