# urls.py
from django.contrib import admin
from django.urls import path
from django.conf import settings
from django.conf.urls.static import static
from .views import index
from . import views
from upload.views import upload_image  # Import the Upload model from the correct location
from chart import views as chartViews
urlpatterns = [
    path('admin/', admin.site.urls),
    path('', index, name='index'),
    path('upload/', upload_image, name='upload_image'), 
    path('upload_image/', views.upload_image, name='upload_image'),
    path('predict_camera/', views.predict_camera, name='predict_camera'),
    path('camera/', views.camera, name='camera'), # Assuming Upload is a view, not a model
     path('api/ck_data', chartViews.CkData.as_view(),name='ck_data' ),
    path('api/fer_chart_data', chartViews.FerChartData.as_view(), name='fer_chart_data'),
]

urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)
