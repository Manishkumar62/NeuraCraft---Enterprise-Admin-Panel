from django.contrib import admin
from django.contrib.auth.admin import UserAdmin as BaseUserAdmin
from .models import User


@admin.register(User)
class UserAdmin(BaseUserAdmin):
    """
    Custom User Admin configuration.
    """
    
    list_display = ('username', 'email', 'get_roles', 'department', 'phone', 'is_active', 'is_staff', 'created_at')
    list_filter = ('is_active', 'is_staff', 'roles', 'department', 'created_at')
    search_fields = ('username', 'email', 'phone', 'employee_id')
    ordering = ('-created_at',)
    filter_horizontal = ('roles', 'groups', 'user_permissions')
    
    # Fields shown when viewing/editing a user
    fieldsets = (
        (None, {'fields': ('username', 'password')}),
        ('Personal Info', {'fields': ('email', 'phone', 'employee_id', 'department',)}),
        ('Roles', {'fields': ('roles',)}),
        ('Permissions', {'fields': ('is_active', 'is_staff', 'is_superuser', 'groups', 'user_permissions')}),
        ('Important Dates', {'fields': ('last_login', 'date_joined')}),
    )
    
    # Fields shown when creating a new user
    add_fieldsets = (
        (None, {
            'classes': ('wide',),
            'fields': ('username', 'email', 'password1', 'password2', 'department', 'is_staff', 'is_active'),
        }),
    )

     # Custom method to display roles in list
    def get_roles(self, obj):
        return ", ".join([role.name for role in obj.roles.all()])
    
    get_roles.short_description = 'Roles'