from rest_framework import status
from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework.permissions import IsAuthenticated

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