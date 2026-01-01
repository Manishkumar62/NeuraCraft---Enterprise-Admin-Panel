from rest_framework import status
from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework.permissions import IsAuthenticated

from .models import Module, RoleModulePermission
from .serializers import ModuleSerializer, RoleModulePermissionSerializer


class ModuleListCreateView(APIView):
    """
    GET  /api/modules/        - List all modules
    POST /api/modules/        - Create new module
    """
    permission_classes = [IsAuthenticated]
    
    def get(self, request):
        # Get only parent modules (no parent), children come nested
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


class UserMenuView(APIView):
    """
    GET /api/modules/my-menu/  - Get logged-in user's accessible menu
    This is what frontend uses to build the sidebar dynamically.
    Now supports MULTIPLE ROLES with permission merging (OR logic).
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
        Returns: {module_id: {can_view, can_add, can_edit, can_delete, module}}
        """
        merged = {}
        
        # Get all permissions for all roles
        permissions = RoleModulePermission.objects.filter(
            role__in=roles,
            module__is_active=True
        ).select_related('module')
        
        for perm in permissions:
            module_id = perm.module.id
            
            if module_id not in merged:
                # First time seeing this module
                merged[module_id] = {
                    'module': perm.module,
                    'can_view': perm.can_view,
                    'can_add': perm.can_add,
                    'can_edit': perm.can_edit,
                    'can_delete': perm.can_delete,
                }
            else:
                # Merge with OR logic - if ANY role has permission, user has it
                merged[module_id]['can_view'] = merged[module_id]['can_view'] or perm.can_view
                merged[module_id]['can_add'] = merged[module_id]['can_add'] or perm.can_add
                merged[module_id]['can_edit'] = merged[module_id]['can_edit'] or perm.can_edit
                merged[module_id]['can_delete'] = merged[module_id]['can_delete'] or perm.can_delete
        
        return merged
    
    def _build_menu(self, merged_permissions):
        """
        Build hierarchical menu structure from merged permissions.
        Only includes modules where can_view is True.
        """
        menu = []
        
        # Get parent modules (modules with can_view=True and no parent)
        parent_modules = [
            data for module_id, data in merged_permissions.items()
            if data['can_view'] and data['module'].parent is None
        ]
        
        # Sort by order
        parent_modules.sort(key=lambda x: x['module'].order)
        
        for parent_data in parent_modules:
            parent_module = parent_data['module']
            
            # Get children for this parent
            children = []
            child_modules = [
                data for module_id, data in merged_permissions.items()
                if data['can_view'] and data['module'].parent_id == parent_module.id
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
                    'permissions': {
                        'can_view': child_data['can_view'],
                        'can_add': child_data['can_add'],
                        'can_edit': child_data['can_edit'],
                        'can_delete': child_data['can_delete'],
                    }
                })
            
            menu.append({
                'id': parent_module.id,
                'module_name': parent_module.name,
                'icon': parent_module.icon,
                'path': parent_module.path,
                'order': parent_module.order,
                'permissions': {
                    'can_view': parent_data['can_view'],
                    'can_add': parent_data['can_add'],
                    'can_edit': parent_data['can_edit'],
                    'can_delete': parent_data['can_delete'],
                },
                'children': children
            })
        
        return menu