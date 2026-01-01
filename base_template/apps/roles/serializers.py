from rest_framework import serializers
from .models import Role


class RoleSerializer(serializers.ModelSerializer):
    """
    Serializer for Role model.
    """

    department_name = serializers.CharField(source='department.name', read_only=True)
    
    class Meta:
        model = Role
        fields = ('id', 'name', 'description', 'department', 'department_name',  'is_active', 'created_at', 'updated_at')
        read_only_fields = ('id', 'created_at', 'updated_at')
