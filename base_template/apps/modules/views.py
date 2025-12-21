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
    """
    permission_classes = [IsAuthenticated]
    
    def get(self, request):
        user = request.user
        
        # If user has no role, return empty menu
        if not user.role:
            return Response([])
        
        # Get all module permissions for user's role
        permissions = RoleModulePermission.objects.filter(
            role=user.role,
            can_view=True,
            module__is_active=True,
            module__parent=None  # Only parent modules
        ).select_related('module').order_by('module__order')
        
        menu = []
        for perm in permissions:
            module = perm.module
            
            # Get children permissions
            child_permissions = RoleModulePermission.objects.filter(
                role=user.role,
                can_view=True,
                module__parent=module,
                module__is_active=True
            ).select_related('module').order_by('module__order')
            
            children = []
            for child_perm in child_permissions:
                children.append({
                    'id': child_perm.module.id,
                    'module_name': child_perm.module.name,
                    'icon': child_perm.module.icon,
                    'path': child_perm.module.path,
                    'order': child_perm.module.order,
                    'permissions': {
                        'can_view': child_perm.can_view,
                        'can_add': child_perm.can_add,
                        'can_edit': child_perm.can_edit,
                        'can_delete': child_perm.can_delete,
                    }
                })
            
            menu.append({
                'id': module.id,
                'module_name': module.name,
                'icon': module.icon,
                'path': module.path,
                'order': module.order,
                'permissions': {
                    'can_view': perm.can_view,
                    'can_add': perm.can_add,
                    'can_edit': perm.can_edit,
                    'can_delete': perm.can_delete,
                },
                'children': children
            })
        
        return Response(menu)