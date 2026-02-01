from django.core.management.base import BaseCommand
from django.contrib.auth import get_user_model
from apps.departments.models import Department
from apps.roles.models import Role
from apps.modules.models import Module, ModulePermission, RoleModulePermission

User = get_user_model()


# ═══════════════════════════════════════════════════════════════
#  SEED DATA DEFINITIONS
#  Edit these lists to change what gets seeded.
# ═══════════════════════════════════════════════════════════════

DEPARTMENTS = [
    {'name': 'IT',      'code': 'IT',    'description': 'Information Technology'},
    {'name': 'HR',      'code': 'HR',    'description': 'Human Resources'},
    {'name': 'Sales',   'code': 'SALES', 'description': 'Sales Department'},
    {'name': 'Finance', 'code': 'FIN',   'description': 'Finance Department'},
]

ROLES = [
    # Global roles (no department)
    {'name': 'Super Admin',   'description': 'Full system access — all modules, all permissions', 'department': None},
    {'name': 'Viewer',        'description': 'Read-only access to permitted modules',             'department': None},
    # Department-specific roles
    {'name': 'IT Manager',    'description': 'IT department manager',    'department': 'IT'},
    {'name': 'IT Developer',  'description': 'IT department developer',  'department': 'IT'},
    {'name': 'HR Manager',    'description': 'HR department manager',    'department': 'HR'},
    {'name': 'HR Staff',      'description': 'HR department staff',      'department': 'HR'},
    {'name': 'Sales Manager', 'description': 'Sales department manager', 'department': 'SALES'},
]

MODULES = [
    {'name': 'Dashboard',   'icon': 'dashboard', 'path': '/dashboard',   'order': 1, 'parent': None},
    {'name': 'Users',       'icon': 'user',      'path': '/users',       'order': 2, 'parent': None},
    {'name': 'Roles',       'icon': 'shield',    'path': '/roles',       'order': 3, 'parent': None},
    {'name': 'Departments', 'icon': 'building',  'path': '/departments', 'order': 4, 'parent': None},
    {'name': 'Modules',     'icon': 'modules',   'path': '/modules',     'order': 5, 'parent': None},
]

# Default CRUD permissions — applied to ALL modules automatically
DEFAULT_CRUD = [
    {'codename': 'view',   'label': 'Can View',   'category': 'crud', 'order': 1},
    {'codename': 'add',    'label': 'Can Add',    'category': 'crud', 'order': 2},
    {'codename': 'edit',   'label': 'Can Edit',   'category': 'crud', 'order': 3},
    {'codename': 'delete', 'label': 'Can Delete', 'category': 'crud', 'order': 4},
]

# Extra per-module permissions — this is the DYNAMIC part!
# Add custom permissions for each module as needed.
EXTRA_MODULE_PERMISSIONS = {
    'Dashboard': [
        {'codename': 'view_revenue_card',   'label': 'View Revenue Card',     'category': 'component', 'order': 10},
        {'codename': 'view_analytics',      'label': 'View Analytics Widget',  'category': 'component', 'order': 11},
        {'codename': 'view_user_stats',     'label': 'View User Stats Card',   'category': 'component', 'order': 12},
        {'codename': 'view_recent_activity','label': 'View Recent Activity',   'category': 'component', 'order': 13},
    ],
    'Users': [
        {'codename': 'view_email',     'label': 'View Email Column',   'category': 'column', 'order': 10},
        {'codename': 'view_phone',     'label': 'View Phone Column',   'category': 'column', 'order': 11},
        {'codename': 'view_salary',    'label': 'View Salary Column',  'category': 'column', 'order': 12},
        {'codename': 'export_csv',     'label': 'Export CSV',          'category': 'action', 'order': 20},
        {'codename': 'export_pdf',     'label': 'Export PDF',          'category': 'action', 'order': 21},
        {'codename': 'reset_password', 'label': 'Reset User Password', 'category': 'action', 'order': 22},
    ],
    'Roles': [
        {'codename': 'assign_permissions', 'label': 'Assign Permissions', 'category': 'action', 'order': 10},
    ],
    'Departments': [],
    'Modules': [
        {'codename': 'manage_permissions', 'label': 'Manage Module Permissions', 'category': 'action', 'order': 10},
    ],
}

# Role → Module → Permissions mapping
# '__all__' means grant every permission that module has (CRUD + extras)
# List of codenames means grant only those specific permissions
ROLE_PERMISSION_MAPPING = {
    'Super Admin': {
        'Dashboard':   '__all__',
        'Users':       '__all__',
        'Roles':       '__all__',
        'Departments': '__all__',
        'Modules':     '__all__',
    },
    'IT Manager': {
        'Dashboard':   ['view', 'view_revenue_card', 'view_analytics', 'view_user_stats', 'view_recent_activity'],
        'Users':       ['view', 'add', 'edit', 'delete', 'view_email', 'view_phone', 'export_csv'],
        'Roles':       ['view', 'add', 'edit', 'assign_permissions'],
        'Modules':     ['view', 'add', 'edit', 'manage_permissions'],
    },
    'IT Developer': {
        'Dashboard':   ['view', 'view_analytics', 'view_recent_activity'],
        'Users':       ['view', 'view_email'],
        'Modules':     ['view'],
    },
    'HR Manager': {
        'Dashboard':   ['view', 'view_user_stats', 'view_recent_activity'],
        'Users':       ['view', 'add', 'edit', 'view_email', 'view_phone', 'view_salary', 'export_csv', 'export_pdf', 'reset_password'],
        'Departments': ['view', 'add', 'edit'],
    },
    'HR Staff': {
        'Dashboard':   ['view', 'view_user_stats'],
        'Users':       ['view', 'view_email', 'view_phone'],
        'Departments': ['view'],
    },
    'Sales Manager': {
        'Dashboard':   ['view', 'view_revenue_card', 'view_recent_activity'],
        'Users':       ['view', 'add', 'edit', 'view_email', 'view_phone'],
    },
    'Viewer': {
        'Dashboard':   ['view'],
        'Users':       ['view'],
        'Roles':       ['view'],
        'Departments': ['view'],
    },
}

# Default password for all seeded users
DEFAULT_PASSWORD = 'Test@1234'

USERS = [
    {
        'username':    'superadmin',
        'email':       'superadmin@neuracraft.com',
        'first_name':  'Super',
        'last_name':   'Admin',
        'employee_id': 'EMP001',
        'department':  'IT',
        'roles':       ['Super Admin'],
        'is_staff':    True,
        'is_superuser': True,
    },
    {
        'username':    'john_it',
        'email':       'john@neuracraft.com',
        'first_name':  'John',
        'last_name':   'Sharma',
        'employee_id': 'EMP002',
        'department':  'IT',
        'roles':       ['IT Manager'],
        'is_staff':    False,
        'is_superuser': False,
    },
    {
        'username':    'mike_dev',
        'email':       'mike@neuracraft.com',
        'first_name':  'Mike',
        'last_name':   'Patel',
        'employee_id': 'EMP003',
        'department':  'IT',
        'roles':       ['IT Developer'],
        'is_staff':    False,
        'is_superuser': False,
    },
    {
        'username':    'sarah_hr',
        'email':       'sarah@neuracraft.com',
        'first_name':  'Sarah',
        'last_name':   'Verma',
        'employee_id': 'EMP004',
        'department':  'HR',
        'roles':       ['HR Manager'],
        'is_staff':    False,
        'is_superuser': False,
    },
    {
        'username':    'lisa_hr',
        'email':       'lisa@neuracraft.com',
        'first_name':  'Lisa',
        'last_name':   'Singh',
        'employee_id': 'EMP005',
        'department':  'HR',
        'roles':       ['HR Staff'],
        'is_staff':    False,
        'is_superuser': False,
    },
    {
        'username':    'tom_sales',
        'email':       'tom@neuracraft.com',
        'first_name':  'Tom',
        'last_name':   'Gupta',
        'employee_id': 'EMP006',
        'department':  'SALES',
        'roles':       ['Sales Manager'],
        'is_staff':    False,
        'is_superuser': False,
    },
    {
        'username':    'viewer1',
        'email':       'viewer@neuracraft.com',
        'first_name':  'Guest',
        'last_name':   'Viewer',
        'employee_id': 'EMP007',
        'department':  'FIN',
        'roles':       ['Viewer'],
        'is_staff':    False,
        'is_superuser': False,
    },
    {
        'username':    'multi_role',
        'email':       'multi@neuracraft.com',
        'first_name':  'Arjun',
        'last_name':   'Mehta',
        'employee_id': 'EMP008',
        'department':  'IT',
        'roles':       ['IT Developer', 'HR Staff'],    # Tests OR-logic merging
        'is_staff':    False,
        'is_superuser': False,
    },
    {
        'username':    'manager_combo',
        'email':       'combo@neuracraft.com',
        'first_name':  'Ravi',
        'last_name':   'Kumar',
        'employee_id': 'EMP009',
        'department':  'IT',
        'roles':       ['IT Manager', 'Sales Manager'],  # Tests cross-department roles
        'is_staff':    False,
        'is_superuser': False,
    },
]


# ═══════════════════════════════════════════════════════════════
#  AVAILABLE SEED TARGETS
# ═══════════════════════════════════════════════════════════════

SEED_TARGETS = [
    'departments',
    'roles',
    'modules',
    'permissions',
    'mappings',
    'users',
]


# ═══════════════════════════════════════════════════════════════
#  COMMAND
# ═══════════════════════════════════════════════════════════════

class Command(BaseCommand):
    help = (
        'Seed the database with base project data for testing.\n\n'
        'Usage:\n'
        '  python manage.py seed_data                     → Seed everything\n'
        '  python manage.py seed_data --only departments  → Seed only departments\n'
        '  python manage.py seed_data --only users roles  → Seed only users and roles\n'
        '  python manage.py seed_data --flush             → Delete all data and re-seed\n'
        '  python manage.py seed_data --flush --only users→ Delete only users and re-seed them\n'
        '  python manage.py seed_data --list              → Show available seed targets\n'
    )

    def add_arguments(self, parser):
        parser.add_argument(
            '--only',
            nargs='+',
            choices=SEED_TARGETS,
            help=f'Seed only specific targets. Choices: {", ".join(SEED_TARGETS)}',
        )
        parser.add_argument(
            '--flush',
            action='store_true',
            help='Delete existing data before seeding. Combines with --only for targeted flush.',
        )
        parser.add_argument(
            '--list',
            action='store_true',
            help='List all available seed targets with descriptions.',
        )

    def handle(self, *args, **options):
        # --list: just show targets and exit
        if options['list']:
            self._print_targets()
            return

        targets = options['only'] or SEED_TARGETS  # default = seed everything

        if options['flush']:
            self.stdout.write(self.style.WARNING(f'\n⚠  Flushing: {", ".join(targets)}'))
            self._flush(targets)

        self.stdout.write(self.style.MIGRATE_HEADING(f'\n🌱 Seeding: {", ".join(targets)}\n'))

        # Stores for cross-referencing
        departments = {}
        roles = {}
        modules = {}

        # Execute in dependency order
        if 'departments' in targets:
            departments = self._seed_departments()
        else:
            departments = {d.code: d for d in Department.objects.all()}

        if 'roles' in targets:
            roles = self._seed_roles(departments)
        else:
            roles = {r.name: r for r in Role.objects.all()}

        if 'modules' in targets:
            modules = self._seed_modules()
        else:
            modules = {m.name: m for m in Module.objects.all()}

        if 'permissions' in targets:
            self._seed_module_permissions(modules)

        if 'mappings' in targets:
            self._seed_role_module_permissions(roles, modules)

        if 'users' in targets:
            users = self._seed_users(departments, roles)

        self.stdout.write(self.style.SUCCESS('\n✅ Seed complete!'))

        # Print summary only if users were seeded
        if 'users' in targets:
            self._print_summary()

    # ──────────────────────────────────────────────
    # LIST TARGETS
    # ──────────────────────────────────────────────
    def _print_targets(self):
        descriptions = {
            'departments': f'Departments ({len(DEPARTMENTS)} records)',
            'roles':       f'Roles ({len(ROLES)} records)',
            'modules':     f'Modules ({len(MODULES)} records)',
            'permissions': f'Module Permissions (CRUD + custom per module)',
            'mappings':    f'Role ↔ Module permission mappings ({len(ROLE_PERMISSION_MAPPING)} roles)',
            'users':       f'Test users ({len(USERS)} records)',
        }
        self.stdout.write(self.style.MIGRATE_HEADING('\n📋 Available Seed Targets:\n'))
        for target in SEED_TARGETS:
            self.stdout.write(f'  • {target:<15} → {descriptions[target]}')

        self.stdout.write(self.style.HTTP_INFO(
            '\n  Dependencies: departments → roles → modules → permissions → mappings → users'
        ))
        self.stdout.write(
            '  Tip: If seeding "users", make sure "departments" and "roles" exist already.\n'
        )

    # ──────────────────────────────────────────────
    # FLUSH
    # ──────────────────────────────────────────────
    def _flush(self, targets):
        """Delete data in reverse dependency order."""
        if 'mappings' in targets or 'permissions' in targets:
            count = RoleModulePermission.objects.all().delete()[0]
            self.stdout.write(f'  Deleted {count} role-module permission mappings')

        if 'permissions' in targets:
            count = ModulePermission.objects.all().delete()[0]
            self.stdout.write(f'  Deleted {count} module permissions')

        if 'users' in targets:
            count = User.objects.filter(is_superuser=False).delete()[0]
            self.stdout.write(f'  Deleted {count} non-superuser records')
            # Also reset superuser roles if exists
            for su in User.objects.filter(is_superuser=True):
                su.roles.clear()

        if 'modules' in targets:
            count = Module.objects.all().delete()[0]
            self.stdout.write(f'  Deleted {count} modules')

        if 'roles' in targets:
            count = Role.objects.all().delete()[0]
            self.stdout.write(f'  Deleted {count} roles')

        if 'departments' in targets:
            count = Department.objects.all().delete()[0]
            self.stdout.write(f'  Deleted {count} departments')

    # ──────────────────────────────────────────────
    # DEPARTMENTS
    # ──────────────────────────────────────────────
    def _seed_departments(self):
        self.stdout.write(self.style.HTTP_INFO('📁 Seeding Departments...'))
        departments = {}
        for item in DEPARTMENTS:
            obj, created = Department.objects.get_or_create(
                code=item['code'],
                defaults={'name': item['name'], 'description': item['description']}
            )
            departments[item['code']] = obj
            tag = 'Created' if created else 'Exists '
            self.stdout.write(f'  {tag}: {obj.name} ({obj.code})')
        return departments

    # ──────────────────────────────────────────────
    # ROLES
    # ──────────────────────────────────────────────
    def _seed_roles(self, departments):
        self.stdout.write(self.style.HTTP_INFO('\n🛡  Seeding Roles...'))
        roles = {}
        for item in ROLES:
            dept = departments.get(item['department']) if item['department'] else None
            obj, created = Role.objects.get_or_create(
                name=item['name'],
                department=dept,
                defaults={'description': item['description']}
            )
            roles[item['name']] = obj
            tag = 'Created' if created else 'Exists '
            dept_label = dept.code if dept else 'Global'
            self.stdout.write(f'  {tag}: {obj.name} [{dept_label}]')
        return roles

    # ──────────────────────────────────────────────
    # MODULES
    # ──────────────────────────────────────────────
    def _seed_modules(self):
        self.stdout.write(self.style.HTTP_INFO('\n📦 Seeding Modules...'))
        modules = {}
        for item in MODULES:
            parent = modules.get(item['parent']) if item['parent'] else None
            obj, created = Module.objects.get_or_create(
                name=item['name'],
                defaults={
                    'icon': item['icon'],
                    'path': item['path'],
                    'order': item['order'],
                    'parent': parent,
                }
            )
            modules[item['name']] = obj
            tag = 'Created' if created else 'Exists '
            self.stdout.write(f'  {tag}: {obj.name} ({obj.path})')
        return modules

    # ──────────────────────────────────────────────
    # MODULE PERMISSIONS
    # ──────────────────────────────────────────────
    def _seed_module_permissions(self, modules):
        self.stdout.write(self.style.HTTP_INFO('\n🔑 Seeding Module Permissions...'))
        total_created = 0

        for module_name, module_obj in modules.items():
            perms_to_seed = DEFAULT_CRUD + EXTRA_MODULE_PERMISSIONS.get(module_name, [])
            created_for_module = 0

            for perm in perms_to_seed:
                _, created = ModulePermission.objects.get_or_create(
                    module=module_obj,
                    codename=perm['codename'],
                    defaults={
                        'label': perm['label'],
                        'category': perm['category'],
                        'order': perm['order'],
                    }
                )
                if created:
                    created_for_module += 1
                    total_created += 1

            count = ModulePermission.objects.filter(module=module_obj).count()
            self.stdout.write(f'  {module_name}: {count} permissions ({created_for_module} new)')

        self.stdout.write(f'  Total new: {total_created}')

    # ──────────────────────────────────────────────
    # ROLE ↔ MODULE PERMISSION MAPPING
    # ──────────────────────────────────────────────
    def _seed_role_module_permissions(self, roles, modules):
        self.stdout.write(self.style.HTTP_INFO('\n🔗 Seeding Role-Module Permission Mappings...'))

        for role_name, module_perms in ROLE_PERMISSION_MAPPING.items():
            role = roles.get(role_name)
            if not role:
                self.stdout.write(self.style.WARNING(f'  ⚠ Role "{role_name}" not found, skipping'))
                continue

            modules_granted = 0
            for module_name, perm_codenames in module_perms.items():
                module = modules.get(module_name)
                if not module:
                    continue

                rmp, _ = RoleModulePermission.objects.get_or_create(
                    role=role,
                    module=module,
                )

                if perm_codenames == '__all__':
                    perms = ModulePermission.objects.filter(module=module)
                else:
                    perms = ModulePermission.objects.filter(
                        module=module,
                        codename__in=perm_codenames,
                    )

                rmp.granted_permissions.set(perms)
                modules_granted += 1

            self.stdout.write(f'  {role_name}: {modules_granted} modules configured')

    # ──────────────────────────────────────────────
    # USERS
    # ──────────────────────────────────────────────
    def _seed_users(self, departments, roles):
        self.stdout.write(self.style.HTTP_INFO('\n👤 Seeding Users...'))
        users = {}

        for item in USERS:
            user, created = User.objects.get_or_create(
                username=item['username'],
                defaults={
                    'email': item['email'],
                    'first_name': item['first_name'],
                    'last_name': item['last_name'],
                    'employee_id': item.get('employee_id', ''),
                    'is_staff': item.get('is_staff', False),
                    'is_superuser': item.get('is_superuser', False),
                }
            )

            if created:
                user.set_password(DEFAULT_PASSWORD)
                dept_code = item.get('department')
                if dept_code and dept_code in departments:
                    user.department = departments[dept_code]
                user.save()

            # Assign roles (always update, even if user exists)
            role_objects = [roles[r] for r in item['roles'] if r in roles]
            user.roles.set(role_objects)

            users[item['username']] = user
            tag = 'Created' if created else 'Exists '
            role_names = ', '.join(item['roles'])
            self.stdout.write(f'  {tag}: {item["username"]} [{role_names}]')

        return users

    # ──────────────────────────────────────────────
    # SUMMARY TABLE
    # ──────────────────────────────────────────────
    def _print_summary(self):
        self.stdout.write(self.style.MIGRATE_HEADING('\n📋 Test Accounts:'))
        self.stdout.write('  ┌──────────────────┬──────────────┬────────────────────────────────────────┐')
        self.stdout.write('  │ Username         │ Password     │ Roles                                  │')
        self.stdout.write('  ├──────────────────┼──────────────┼────────────────────────────────────────┤')

        for item in USERS:
            role_names = ', '.join(item['roles'])
            self.stdout.write(
                f'  │ {item["username"]:<16} │ {DEFAULT_PASSWORD:<12} │ {role_names:<38} │'
            )

        self.stdout.write('  └──────────────────┴──────────────┴────────────────────────────────────────┘')
        self.stdout.write(self.style.WARNING('\n  ⚠  Change all passwords before deploying to production!'))
        self.stdout.write(self.style.HTTP_INFO('  💡 Run with --list to see all available targets'))
        self.stdout.write(self.style.HTTP_INFO('  💡 Run with --flush to reset data: python manage.py seed_data --flush'))
        self.stdout.write(self.style.HTTP_INFO('  💡 Run specific: python manage.py seed_data --only departments roles\n'))