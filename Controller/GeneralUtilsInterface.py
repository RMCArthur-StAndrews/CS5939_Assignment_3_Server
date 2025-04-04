from flask_restful import Resource

class GeneralUtilsInterface(Resource):
    """
    Class handles all operations related to the general utilities interface.
    Used for service checking.

    """
    def get(self):
        """
        Get the status of the service.
        :return: 200 OK response with a message.
        """
        return {"message": "Service running successfully"}, 200