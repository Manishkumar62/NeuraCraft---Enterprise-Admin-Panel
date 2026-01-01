from django.db import models


class Role(models.Model):
    """
    Role model for role-based access control.
    Examples: Admin, Manager, Employee, Viewer
    Now linked to Department for department-specific roles.
    """
    
    name = models.CharField(max_length=100)
    description = models.TextField(blank=True, null=True)
    is_active = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    # Link to Department (NEW)
    department = models.ForeignKey(
        'departments.Department',
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name='roles'
    )
    
    class Meta:
        db_table = 'roles'
        verbose_name = 'Role'
        verbose_name_plural = 'Roles'
        ordering = ['name']
        unique_together = ['name', 'department']
    
    def __str__(self):
        if self.department:
            return f"{self.name} ({self.department.name})"
        return self.name
