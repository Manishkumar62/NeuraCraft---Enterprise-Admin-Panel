from django.urls import path
from .views import RoleListCreateView, RoleDetailView, RolePermissionsView

urlpatterns = [
    path('', RoleListCreateView.as_view(), name='role_list_create'),
    path('<int:pk>/', RoleDetailView.as_view(), name='role_detail'),
    path('<int:pk>/permissions/', RolePermissionsView.as_view(), name='role-permissions'),
]