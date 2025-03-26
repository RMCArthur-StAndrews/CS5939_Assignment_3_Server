from flask_restful import Resource

class GeneralUtilsInterface(Resource):
    def get(self):
        return {"message": "Service running successfully"}, 200