from rest_framework import status
from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework.permissions import IsAuthenticated
from apps.modules.models import Module, RoleModulePermission

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
    POST /api/roles/<id>/permissions/ - Update permissions for a role
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
            # Get permission for this role-module
            perm = RoleModulePermission.objects.filter(role=role, module=module).first()
            
            # Get children
            children_data = []
            children = module.children.filter(is_active=True).order_by('order')
            for child in children:
                child_perm = RoleModulePermission.objects.filter(role=role, module=child).first()
                children_data.append({
                    'module_id': child.id,
                    'module_name': child.name,
                    'can_view': child_perm.can_view if child_perm else False,
                    'can_add': child_perm.can_add if child_perm else False,
                    'can_edit': child_perm.can_edit if child_perm else False,
                    'can_delete': child_perm.can_delete if child_perm else False,
                })
            
            permissions_data.append({
                'module_id': module.id,
                'module_name': module.name,
                'can_view': perm.can_view if perm else False,
                'can_add': perm.can_add if perm else False,
                'can_edit': perm.can_edit if perm else False,
                'can_delete': perm.can_delete if perm else False,
                'children': children_data,
            })
        
        return Response(permissions_data)
    
    def post(self, request, pk):
        try:
            role = Role.objects.get(pk=pk)
        except Role.DoesNotExist:
            return Response({'error': 'Role not found'}, status=status.HTTP_404_NOT_FOUND)
        
        permissions = request.data.get('permissions', [])
        
        for perm_data in permissions:
            module_id = perm_data.get('module_id')
            try:
                module = Module.objects.get(pk=module_id)
            except Module.DoesNotExist:
                continue
            
            # Update or create permission
            RoleModulePermission.objects.update_or_create(
                role=role,
                module=module,
                defaults={
                    'can_view': perm_data.get('can_view', False),
                    'can_add': perm_data.get('can_add', False),
                    'can_edit': perm_data.get('can_edit', False),
                    'can_delete': perm_data.get('can_delete', False),
                }
            )
        
        return Response({'message': 'Permissions updated successfully'})