from django.shortcuts import render
from rest_framework.views import APIView
from rest_framework.response import Response
import pickle
import os

# Load the evaluation results from the pickle file
current_dir = os.path.dirname(os.path.abspath(__file__))
pickle_path = os.path.join(current_dir, '../static/models/evaluation_results.pkl')

with open(pickle_path, 'rb') as file:
    evaluation_results = pickle.load(file)

class CkData(APIView):
    authentication_classes = []
    permission_classes = []

    def get(self, request, format=None):
        # Use data from the pickle file
        labels = [
            'Loss', 'Accuracy'
        ]
        chartLabel = "CK+ Model Evaluation"
        chartdata = evaluation_results['ck_plus_model_on_ck_plus']
        
        data = {
            "labels": labels,
            "chartLabel": chartLabel,
            "chartdata": chartdata,
        }
        return Response(data)

class FerChartData(APIView):
    authentication_classes = []
    permission_classes = []

    def get(self, request, format=None):
        # Use data from the pickle file
        labels = [
            'Loss', 'Accuracy'
        ]
        chartLabel = "FER2013 Model Evaluation"
        chartdata = evaluation_results['fer2013_model_on_fer2013']
        
        data = {
            "labels": labels,
            "chartLabel": chartLabel,
            "chartdata": chartdata,
        }
        return Response(data)
