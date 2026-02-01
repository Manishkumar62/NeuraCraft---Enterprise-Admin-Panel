from django.contrib import admin
from .models import Module, ModulePermission, RoleModulePermission


@admin.register(Module)
class ModuleAdmin(admin.ModelAdmin):
    list_display = ('name', 'path', 'icon', 'parent', 'order', 'is_active')
    list_filter = ('is_active', 'parent')
    search_fields = ('name', 'path')
    ordering = ('order', 'name')


@admin.register(ModulePermission)
class ModulePermissionAdmin(admin.ModelAdmin):
    list_display = ('module', 'codename', 'label', 'category', 'order')
    list_filter = ('module', 'category')
    search_fields = ('codename', 'label', 'module__name')
    ordering = ('module__name', 'category', 'order')


@admin.register(RoleModulePermission)
class RoleModulePermissionAdmin(admin.ModelAdmin):
    list_display = ('role', 'module', 'get_permissions')
    list_filter = ('role', 'module')
    search_fields = ('role__name', 'module__name')
    filter_horizontal = ('granted_permissions',)  # Nice multi-select widget
    
    def get_permissions(self, obj):
        return ", ".join([p.codename for p in obj.granted_permissions.all()])
    get_permissions.short_description = 'Granted Permissions'