from rest_framework import status
from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework.permissions import IsAuthenticated

from .models import Module, ModulePermission, RoleModulePermission
from .serializers import (
    ModuleSerializer,
    ModuleWithPermissionsSerializer,
    ModulePermissionSerializer,
    RoleModulePermissionSerializer,
)


class ModuleListCreateView(APIView):
    """
    GET  /api/modules/        - List all modules
    POST /api/modules/        - Create new module
    """
    permission_classes = [IsAuthenticated]
    
    def get(self, request):
        modules = Module.objects.filter(parent=None).order_by('order')
        serializer = ModuleSerializer(modules, many=True)
        return Response(serializer.data)
    
    def post(self, request):
        serializer = ModuleSerializer(data=request.data)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


class ModuleDetailView(APIView):
    """
    GET    /api/modules/<id>/  - Get single module
    PUT    /api/modules/<id>/  - Update module
    DELETE /api/modules/<id>/  - Delete module
    """
    permission_classes = [IsAuthenticated]
    
    def get_object(self, pk):
        try:
            return Module.objects.get(pk=pk)
        except Module.DoesNotExist:
            return None
    
    def get(self, request, pk):
        module = self.get_object(pk)
        if not module:
            return Response({'error': 'Module not found'}, status=status.HTTP_404_NOT_FOUND)
        serializer = ModuleSerializer(module)
        return Response(serializer.data)
    
    def put(self, request, pk):
        module = self.get_object(pk)
        if not module:
            return Response({'error': 'Module not found'}, status=status.HTTP_404_NOT_FOUND)
        serializer = ModuleSerializer(module, data=request.data, partial=True)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
    
    def delete(self, request, pk):
        module = self.get_object(pk)
        if not module:
            return Response({'error': 'Module not found'}, status=status.HTTP_404_NOT_FOUND)
        module.delete()
        return Response({'message': 'Module deleted successfully'}, status=status.HTTP_204_NO_CONTENT)


class ModulePermissionsView(APIView):
    """
    GET  /api/modules/<id>/permissions/  - Get all available permissions for a module
    POST /api/modules/<id>/permissions/  - Add a new permission to a module
    
    This manages what permissions a module SUPPORTS (not role assignments).
    Example: Adding "export_pdf" permission to the Users module.
    """
    permission_classes = [IsAuthenticated]
    
    def get(self, request, pk):
        try:
            module = Module.objects.get(pk=pk)
        except Module.DoesNotExist:
            return Response({'error': 'Module not found'}, status=status.HTTP_404_NOT_FOUND)
        
        permissions = module.available_permissions.all().order_by('category', 'order')
        serializer = ModulePermissionSerializer(permissions, many=True)
        return Response(serializer.data)
    
    def post(self, request, pk):
        try:
            module = Module.objects.get(pk=pk)
        except Module.DoesNotExist:
            return Response({'error': 'Module not found'}, status=status.HTTP_404_NOT_FOUND)
        
        data = request.data.copy()
        data['module'] = module.id
        
        serializer = ModulePermissionSerializer(data=data)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


class ModulePermissionDetailView(APIView):
    """
    PUT    /api/modules/permissions/<id>/  - Update a module permission
    DELETE /api/modules/permissions/<id>/  - Delete a module permission
    """
    permission_classes = [IsAuthenticated]
    
    def put(self, request, pk):
        try:
            perm = ModulePermission.objects.get(pk=pk)
        except ModulePermission.DoesNotExist:
            return Response({'error': 'Permission not found'}, status=status.HTTP_404_NOT_FOUND)
        
        serializer = ModulePermissionSerializer(perm, data=request.data, partial=True)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
    
    def delete(self, request, pk):
        try:
            perm = ModulePermission.objects.get(pk=pk)
        except ModulePermission.DoesNotExist:
            return Response({'error': 'Permission not found'}, status=status.HTTP_404_NOT_FOUND)
        perm.delete()
        return Response({'message': 'Permission deleted successfully'}, status=status.HTTP_204_NO_CONTENT)


class ModulesWithPermissionsView(APIView):
    """
    GET /api/modules/all-with-permissions/  - Get all modules with their available permissions
    
    Used by the Role Permissions assignment screen to show what can be toggled.
    Groups permissions by category for clean UI rendering.
    """
    permission_classes = [IsAuthenticated]
    
    def get(self, request):
        modules = Module.objects.filter(parent=None, is_active=True).order_by('order')
        serializer = ModuleWithPermissionsSerializer(modules, many=True)
        return Response(serializer.data)


class UserMenuView(APIView):
    """
    GET /api/modules/my-menu/  - Get logged-in user's accessible menu
    
    Returns DYNAMIC permissions as a flat list of codenames.
    Supports MULTIPLE ROLES with permission merging (OR logic).
    
    Response format (NEW):
    {
        "id": 1,
        "module_name": "Users",
        "permissions": ["view", "add", "edit", "view_email", "export_csv"]
    }
    """
    permission_classes = [IsAuthenticated]
    
    def get(self, request):
        user = request.user
        
        # Get all user's roles
        user_roles = user.roles.all()
        
        # If user has no roles, return empty menu
        if not user_roles.exists():
            return Response([])
        
        # Get all permissions for ALL user's roles and merge them
        merged_permissions = self._get_merged_permissions(user_roles)
        
        # Build menu from merged permissions
        menu = self._build_menu(merged_permissions)
        
        return Response(menu)
    
    def _get_merged_permissions(self, roles):
        """
        Get all permissions from all roles and merge using OR logic.
        Returns: {module_id: {'module': Module, 'permissions': set()}}
        """
        merged = {}
        
        # Get all RoleModulePermissions for all user roles, with related data
        role_module_perms = RoleModulePermission.objects.filter(
            role__in=roles,
            module__is_active=True
        ).select_related('module').prefetch_related('granted_permissions')
        
        for rmp in role_module_perms:
            module_id = rmp.module.id
            
            if module_id not in merged:
                merged[module_id] = {
                    'module': rmp.module,
                    'permissions': set(),
                }
            
            # OR logic: merge all granted permission codenames
            for perm in rmp.granted_permissions.all():
                merged[module_id]['permissions'].add(perm.codename)
        
        return merged
    
    def _build_menu(self, merged_permissions):
        """
        Build hierarchical menu structure from merged permissions.
        Only includes modules where 'view' permission is granted.
        """
        menu = []
        
        # Get parent modules that have 'view' permission
        parent_modules = [
            data for module_id, data in merged_permissions.items()
            if 'view' in data['permissions'] and data['module'].parent is None
        ]
        parent_modules.sort(key=lambda x: x['module'].order)
        
        for parent_data in parent_modules:
            parent_module = parent_data['module']
            
            # Get children
            children = []
            child_modules = [
                data for module_id, data in merged_permissions.items()
                if 'view' in data['permissions'] and data['module'].parent_id == parent_module.id
            ]
            
            # Sort children by order
            child_modules.sort(key=lambda x: x['module'].order)
            
            for child_data in child_modules:
                child_module = child_data['module']
                children.append({
                    'id': child_module.id,
                    'module_name': child_module.name,
                    'icon': child_module.icon,
                    'path': child_module.path,
                    'order': child_module.order,
                    'permissions': sorted(child_data['permissions']),
                })
            
            menu.append({
                'id': parent_module.id,
                'module_name': parent_module.name,
                'icon': parent_module.icon,
                'path': parent_module.path,
                'order': parent_module.order,
                'permissions': sorted(parent_data['permissions']),
                'children': children,
            })
        
        return menu
    
class ModuleCreateWithPermissionsView(APIView):
    """
    POST /api/modules/create-with-permissions/
    
    Creates a module along with its available permissions in one request.
    
    Request format:
    {
        "name": "Reports",
        "icon": "chart",
        "path": "/reports",
        "parent": null,
        "order": 6,
        "is_active": true,
        "permissions": [
            {"codename": "view", "label": "Can View", "category": "crud"},
            {"codename": "export_pdf", "label": "Export PDF", "category": "action"}
        ]
    }
    """
    permission_classes = [IsAuthenticated]
    
    def post(self, request):
        data = request.data
        permissions_data = data.pop('permissions', [])
        
        # Create module
        serializer = ModuleSerializer(data=data)
        if not serializer.is_valid():
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
        
        module = serializer.save()
        
        # Create permissions
        for idx, perm in enumerate(permissions_data):
            ModulePermission.objects.create(
                module=module,
                codename=perm.get('codename'),
                label=perm.get('label'),
                category=perm.get('category', 'crud'),
                order=perm.get('order', idx + 1),
            )
        
        # Return module with permissions
        return Response({
            'id': module.id,
            'name': module.name,
            'icon': module.icon,
            'path': module.path,
            'parent': module.parent_id,
            'order': module.order,
            'is_active': module.is_active,
            'permissions': list(module.available_permissions.values('id', 'codename', 'label', 'category', 'order')),
        }, status=status.HTTP_201_CREATED)


class ModuleUpdateWithPermissionsView(APIView):
    """
    PUT /api/modules/<id>/update-with-permissions/
    
    Updates a module along with its available permissions.
    Permissions not in the list will be removed.
    """
    permission_classes = [IsAuthenticated]
    
    def put(self, request, pk):
        try:
            module = Module.objects.get(pk=pk)
        except Module.DoesNotExist:
            return Response({'error': 'Module not found'}, status=status.HTTP_404_NOT_FOUND)
        
        data = request.data
        permissions_data = data.pop('permissions', None)
        
        # Update module
        serializer = ModuleSerializer(module, data=data, partial=True)
        if not serializer.is_valid():
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
        
        module = serializer.save()
        
        # Update permissions if provided
        if permissions_data is not None:
            # Get existing permission codenames
            existing_codenames = set(module.available_permissions.values_list('codename', flat=True))
            new_codenames = set(p.get('codename') for p in permissions_data)
            
            # Delete removed permissions
            to_delete = existing_codenames - new_codenames
            module.available_permissions.filter(codename__in=to_delete).delete()
            
            # Add/update permissions
            for idx, perm in enumerate(permissions_data):
                ModulePermission.objects.update_or_create(
                    module=module,
                    codename=perm.get('codename'),
                    defaults={
                        'label': perm.get('label'),
                        'category': perm.get('category', 'crud'),
                        'order': perm.get('order', idx + 1),
                    }
                )
        
        # Return module with permissions
        return Response({
            'id': module.id,
            'name': module.name,
            'icon': module.icon,
            'path': module.path,
            'parent': module.parent_id,
            'order': module.order,
            'is_active': module.is_active,
            'permissions': list(module.available_permissions.values('id', 'codename', 'label', 'category', 'order')),
        })


class ModuleDetailWithPermissionsView(APIView):
    """
    GET /api/modules/<id>/with-permissions/
    
    Get module details including its available permissions.
    """
    permission_classes = [IsAuthenticated]
    
    def get(self, request, pk):
        try:
            module = Module.objects.get(pk=pk)
        except Module.DoesNotExist:
            return Response({'error': 'Module not found'}, status=status.HTTP_404_NOT_FOUND)
        
        return Response({
            'id': module.id,
            'name': module.name,
            'icon': module.icon,
            'path': module.path,
            'parent': module.parent_id,
            'order': module.order,
            'is_active': module.is_active,
            'permissions': list(module.available_permissions.order_by('order').values('id', 'codename', 'label', 'category', 'order')),
        })