from rest_framework import status
from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework.permissions import IsAuthenticated
from apps.modules.models import Module, ModulePermission, RoleModulePermission

from .models import Role
from .serializers import RoleSerializer


class RoleListCreateView(APIView):
    """
    GET  /api/roles/        - List all roles
    POST /api/roles/        - Create new role
    """
    permission_classes = [IsAuthenticated]
    
    def get(self, request):
        roles = Role.objects.all()
        serializer = RoleSerializer(roles, many=True)
        return Response(serializer.data)
    
    def post(self, request):
        serializer = RoleSerializer(data=request.data)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


class RoleDetailView(APIView):
    """
    GET    /api/roles/<id>/  - Get single role
    PUT    /api/roles/<id>/  - Update role
    DELETE /api/roles/<id>/  - Delete role
    """
    permission_classes = [IsAuthenticated]
    
    def get_object(self, pk):
        try:
            return Role.objects.get(pk=pk)
        except Role.DoesNotExist:
            return None
    
    def get(self, request, pk):
        role = self.get_object(pk)
        if not role:
            return Response({'error': 'Role not found'}, status=status.HTTP_404_NOT_FOUND)
        serializer = RoleSerializer(role)
        return Response(serializer.data)
    
    def put(self, request, pk):
        role = self.get_object(pk)
        if not role:
            return Response({'error': 'Role not found'}, status=status.HTTP_404_NOT_FOUND)
        serializer = RoleSerializer(role, data=request.data, partial=True)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
    
    def delete(self, request, pk):
        role = self.get_object(pk)
        if not role:
            return Response({'error': 'Role not found'}, status=status.HTTP_404_NOT_FOUND)
        role.delete()
        return Response({'message': 'Role deleted successfully'}, status=status.HTTP_204_NO_CONTENT)


class RolePermissionsView(APIView):
    """
    GET  /api/roles/<id>/permissions/ - Get all module permissions for a role
    POST /api/roles/<id>/permissions/ - Update permissions for a role (dynamic)
    
    GET Response format:
    [
        {
            "module_id": 1,
            "module_name": "Users",
            "available_permissions": [
                {"id": 1, "codename": "view", "label": "Can View", "category": "crud"},
                {"id": 5, "codename": "view_email", "label": "View Email Column", "category": "column"},
                ...
            ],
            "granted_permissions": ["view", "add", "view_email"],
            "children": [...]
        }
    ]
    
    POST Request format:
    {
        "permissions": [
            {"module_id": 1, "granted": ["view", "add", "edit", "view_email"]},
            {"module_id": 2, "granted": ["view"]},
        ]
    }
    """
    permission_classes = [IsAuthenticated]
    
    def get(self, request, pk):
        try:
            role = Role.objects.get(pk=pk)
        except Role.DoesNotExist:
            return Response({'error': 'Role not found'}, status=status.HTTP_404_NOT_FOUND)
        
        # Get all active modules
        modules = Module.objects.filter(is_active=True, parent=None).order_by('order')
        
        permissions_data = []
        for module in modules:
            module_data = self._get_module_permission_data(role, module)
            
            # Get children
            children_data = []
            children = module.children.filter(is_active=True).order_by('order')
            for child in children:
                children_data.append(self._get_module_permission_data(role, child))
            
            module_data['children'] = children_data
            permissions_data.append(module_data)
        
        return Response(permissions_data)
    
    def _get_module_permission_data(self, role, module):
        """Build permission data for a single module."""
        # Get all available permissions for this module
        available = module.available_permissions.all().order_by('category', 'order')
        
        # Get granted permissions for this role-module
        rmp = RoleModulePermission.objects.filter(role=role, module=module).first()
        granted_codenames = []
        if rmp:
            granted_codenames = list(rmp.granted_permissions.values_list('codename', flat=True))
        
        return {
            'module_id': module.id,
            'module_name': module.name,
            'available_permissions': [
                {
                    'id': perm.id,
                    'codename': perm.codename,
                    'label': perm.label,
                    'category': perm.category,
                }
                for perm in available
            ],
            'granted_permissions': granted_codenames,
        }
    
    def post(self, request, pk):
        try:
            role = Role.objects.get(pk=pk)
        except Role.DoesNotExist:
            return Response({'error': 'Role not found'}, status=status.HTTP_404_NOT_FOUND)
        
        permissions = request.data.get('permissions', [])
        
        for perm_data in permissions:
            module_id = perm_data.get('module_id')
            granted_codenames = perm_data.get('granted', [])
            
            try:
                module = Module.objects.get(pk=module_id)
            except Module.DoesNotExist:
                continue
            
            # Get or create the RoleModulePermission link
            rmp, _ = RoleModulePermission.objects.get_or_create(
                role=role,
                module=module,
            )
            
            # Set the granted permissions by codename
            if granted_codenames:
                perms = ModulePermission.objects.filter(
                    module=module,
                    codename__in=granted_codenames,
                )
                rmp.granted_permissions.set(perms)
            else:
                rmp.granted_permissions.clear()
        
        return Response({'message': 'Permissions updated successfully'})