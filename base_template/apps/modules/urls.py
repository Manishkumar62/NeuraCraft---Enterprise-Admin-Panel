from django.urls import path
from .views import (
    ModuleListCreateView,
    ModuleDetailView,
    ModulePermissionsView,
    ModulePermissionDetailView,
    ModulesWithPermissionsView,
    UserMenuView,
    ModuleCreateWithPermissionsView,
    ModuleUpdateWithPermissionsView,
    ModuleDetailWithPermissionsView,
)

urlpatterns = [
    # Module CRUD
    path('', ModuleListCreateView.as_view(), name='module-list-create'),
    path('<int:pk>/', ModuleDetailView.as_view(), name='module-detail'),
    
    # Dynamic menu for logged-in user
    path('my-menu/', UserMenuView.as_view(), name='user-menu'),
    
    # All modules with their available permissions (for role assignment screen)
    path('all-with-permissions/', ModulesWithPermissionsView.as_view(), name='modules-with-permissions'),
    
    # Module with permissions (create/update/get)
    path('create-with-permissions/', ModuleCreateWithPermissionsView.as_view(), name='module-create-with-permissions'),
    path('<int:pk>/with-permissions/', ModuleDetailWithPermissionsView.as_view(), name='module-detail-with-permissions'),
    path('<int:pk>/update-with-permissions/', ModuleUpdateWithPermissionsView.as_view(), name='module-update-with-permissions'),
    
    # Module-specific permission management
    path('<int:pk>/permissions/', ModulePermissionsView.as_view(), name='module-permissions'),
    path('permissions/<int:pk>/', ModulePermissionDetailView.as_view(), name='module-permission-detail'),
]