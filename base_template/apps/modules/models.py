from django.db import models


class Module(models.Model):
    """
    Module model for dynamic sidebar navigation.
    Each module represents a menu item in the frontend.
    """
    
    name = models.CharField(max_length=100)
    icon = models.CharField(max_length=50, blank=True, null=True)  # e.g., 'dashboard', 'users', 'settings'
    path = models.CharField(max_length=200)  # e.g., '/dashboard', '/users'
    parent = models.ForeignKey(
        'self',
        on_delete=models.CASCADE,
        null=True,
        blank=True,
        related_name='children'
    )
    order = models.IntegerField(default=0)  # For sorting menu items
    is_active = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        db_table = 'modules'
        verbose_name = 'Module'
        verbose_name_plural = 'Modules'
        ordering = ['order', 'name']
    
    def __str__(self):
        return self.name


class ModulePermission(models.Model):
    """
    Defines what permissions are AVAILABLE for each module.
    Each module can have its own unique set of permissions.
    
    Examples:
        Module: "User Management"
            - codename: "view",         label: "Can View",           category: "crud"
            - codename: "add",          label: "Can Add",            category: "crud"
            - codename: "edit",         label: "Can Edit",           category: "crud"
            - codename: "delete",       label: "Can Delete",         category: "crud"
            - codename: "view_email",   label: "View Email Column",  category: "column"
            - codename: "view_salary",  label: "View Salary Column", category: "column"
            - codename: "export_csv",   label: "Export CSV",         category: "action"
        
        Module: "Dashboard"
            - codename: "view",              label: "Can View",             category: "crud"
            - codename: "view_revenue_card", label: "View Revenue Card",    category: "component"
            - codename: "view_analytics",    label: "View Analytics Widget",category: "component"
    """
    
    CATEGORY_CHOICES = [
        ('crud', 'CRUD'),
        ('column', 'Column'),
        ('component', 'Component'),
        ('action', 'Action'),
        ('field', 'Field'),
    ]
    
    module = models.ForeignKey(
        Module,
        on_delete=models.CASCADE,
        related_name='available_permissions'
    )
    codename = models.CharField(max_length=100)   # "view", "add", "view_salary", etc.
    label = models.CharField(max_length=200)       # "Can View", "View Salary Column"
    category = models.CharField(
        max_length=50,
        choices=CATEGORY_CHOICES,
        default='crud'
    )
    order = models.IntegerField(default=0)
    
    class Meta:
        db_table = 'module_permissions'
        verbose_name = 'Module Permission'
        verbose_name_plural = 'Module Permissions'
        unique_together = ('module', 'codename')
        ordering = ['category', 'order', 'codename']
    
    def __str__(self):
        return f"{self.module.name} → {self.codename}"


class RoleModulePermission(models.Model):
    """
    Maps roles to modules with DYNAMIC permissions.
    
    Old: role=Admin, module=Users, can_view=True, can_add=True, can_edit=True, can_delete=False
    New: role=Admin, module=Users, granted_permissions=[view, add, edit, view_email, export_csv]
    """
    
    role = models.ForeignKey(
        'roles.Role',
        on_delete=models.CASCADE,
        related_name='module_permissions'
    )
    module = models.ForeignKey(
        Module,
        on_delete=models.CASCADE,
        related_name='role_permissions'
    )
    granted_permissions = models.ManyToManyField(
        ModulePermission,
        blank=True,
        related_name='role_grants'
    )
    
    class Meta:
        db_table = 'role_module_permissions'
        verbose_name = 'Role Module Permission'
        verbose_name_plural = 'Role Module Permissions'
        unique_together = ('role', 'module')
    
    def __str__(self):
        return f"{self.role.name} - {self.module.name}"