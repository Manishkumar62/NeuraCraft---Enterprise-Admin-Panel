from rest_framework import serializers
from .models import Module, RoleModulePermission


class ModuleSerializer(serializers.ModelSerializer):
    """
    Serializer for Module model.
    """
    children = serializers.SerializerMethodField()
    
    class Meta:
        model = Module
        fields = ('id', 'name', 'icon', 'path', 'parent', 'order', 'is_active', 'children')
        read_only_fields = ('id',)
    
    def get_children(self, obj):
        children = obj.children.all().order_by('order')
        return ModuleSerializer(children, many=True).data


class RoleModulePermissionSerializer(serializers.ModelSerializer):
    """
    Serializer for RoleModulePermission model.
    """
    module_name = serializers.CharField(source='module.name', read_only=True)
    module_path = serializers.CharField(source='module.path', read_only=True)
    module_icon = serializers.CharField(source='module.icon', read_only=True)
    
    class Meta:
        model = RoleModulePermission
        fields = ('id', 'role', 'module', 'module_name', 'module_path', 'module_icon', 
                  'can_view', 'can_add', 'can_edit', 'can_delete')


class UserMenuSerializer(serializers.Serializer):
    """
    Serializer for user's accessible menu items.
    This is what frontend will use to build the sidebar.
    """
    module_name = serializers.CharField()
    icon = serializers.CharField()
    path = serializers.CharField()
    permissions = serializers.DictField()
    children = serializers.ListField(default=[])
