import logging
import os

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
    Record CPU and memory usage at the start of the request lifecycle.
    """
    g.start_time = time.time()
    g.start_memory = cloud_monitor.process.memory_info().rss
    g.start_cpu_times = cloud_monitor.process.cpu_times()  # Record CPU times
    tracemalloc.start()

@app.after_request
def after_request(response):
    """
    Record CPU and memory usage at the end of the request lifecycle.
    """
    end_memory = cloud_monitor.process.memory_info().rss
    end_cpu_times = cloud_monitor.process.cpu_times()  # Record CPU times again
    end_time = time.time()

    _, peak = tracemalloc.get_traced_memory()
    tracemalloc.stop()

    execution_time = end_time - g.start_time
    memory_usage = (end_memory - g.start_memory) / (1024 * 1024)
    peak_memory_usage = peak / (1024 * 1024)

    # Calculate CPU usage
    cpu_usage = {
        "user_time": end_cpu_times.user - g.start_cpu_times.user,
        "system_time": end_cpu_times.system - g.start_cpu_times.system
    }

    record = MonitorRecordObject(
        time=time.strftime("%d/%b/%Y %H:%M:%S", time.gmtime()),
        data=request.path,
        execution_time=execution_time,
        memory_usage=abs(peak_memory_usage),
        processing_info={
            "cpu_usage": cpu_usage
        }
    )

    cloud_monitor.write_monitoring_data("monitoring.json", [record])
    return response;


if __name__ == '__main__':
    app.run(host= '0.0.0.0', debug=True, use_reloader=False)