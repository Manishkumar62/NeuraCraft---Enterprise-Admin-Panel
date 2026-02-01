from rest_framework import serializers
from .models import Module, ModulePermission, RoleModulePermission


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
        children = obj.children.filter(is_active=True).order_by('order')
        return ModuleSerializer(children, many=True).data


class ModulePermissionSerializer(serializers.ModelSerializer):
    """
    Serializer for ModulePermission model.
    Used when managing what permissions a module supports.
    """
    class Meta:
        model = ModulePermission
        fields = ('id', 'module', 'codename', 'label', 'category', 'order')
        read_only_fields = ('id',)


class ModuleWithPermissionsSerializer(serializers.ModelSerializer):
    """
    Module + its available permissions (for admin screens).
    Shows what permissions CAN be assigned for each module.
    """
    available_permissions = ModulePermissionSerializer(many=True, read_only=True)
    children = serializers.SerializerMethodField()
    
    class Meta:
        model = Module
        fields = ('id', 'name', 'icon', 'path', 'parent', 'order', 'is_active', 'available_permissions', 'children')
        read_only_fields = ('id',)
    
    def get_children(self, obj):
        children = obj.children.filter(is_active=True).order_by('order')
        return ModuleWithPermissionsSerializer(children, many=True).data


class RoleModulePermissionSerializer(serializers.ModelSerializer):
    """
    Serializer for RoleModulePermission model.
    """
    module_name = serializers.CharField(source='module.name', read_only=True)
    module_path = serializers.CharField(source='module.path', read_only=True)
    module_icon = serializers.CharField(source='module.icon', read_only=True)
    granted_permissions = serializers.SerializerMethodField()
    
    class Meta:
        model = RoleModulePermission
        fields = ('id', 'role', 'module', 'module_name', 'module_path', 'module_icon', 'granted_permissions')
    
    def get_granted_permissions(self, obj):
        return list(obj.granted_permissions.values_list('codename', flat=True))


class UserMenuSerializer(serializers.Serializer):
    """
    Serializer for user's accessible menu items.
    This is what frontend will use to build the sidebar.
    """
    id = serializers.IntegerField()
    module_name = serializers.CharField()
    icon = serializers.CharField()
    path = serializers.CharField()
    order = serializers.IntegerField()
    permissions = serializers.ListField(child=serializers.CharField())
    children = serializers.ListField(default=[])