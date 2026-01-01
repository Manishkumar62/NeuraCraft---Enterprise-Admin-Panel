from django.contrib import admin
from .models import Role


@admin.register(Role)
class RoleAdmin(admin.ModelAdmin):
    list_display = ('name','department', 'is_active', 'created_at')
    list_filter = ('is_active','department')
    search_fields = ('name', 'description')
    ordering = ('name',)
