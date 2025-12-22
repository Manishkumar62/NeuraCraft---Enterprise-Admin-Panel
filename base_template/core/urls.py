from django.contrib import admin
from django.urls import path, include

urlpatterns = [
    path('admin/', admin.site.urls),
    path('api/users/', include('apps.users.urls')),
    path('api/roles/', include('apps.roles.urls')),
    path('api/departments/', include('apps.departments.urls')),
    path('api/modules/', include('apps.modules.urls')),
    path('api/dashboard/', include('apps.dashboard.urls')),
]