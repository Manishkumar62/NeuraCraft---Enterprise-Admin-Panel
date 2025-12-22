from rest_framework import status
from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework.permissions import IsAuthenticated

from django.contrib.auth import get_user_model
from apps.roles.models import Role
from apps.departments.models import Department
from apps.modules.models import Module

User = get_user_model()


class DashboardStatsView(APIView):
    """
    GET /api/dashboard/stats/ - Get dashboard statistics
    """
    permission_classes = [IsAuthenticated]
    
    def get(self, request):
        stats = {
            'total_users': User.objects.count(),
            'active_users': User.objects.filter(is_active=True).count(),
            'inactive_users': User.objects.filter(is_active=False).count(),
            'total_roles': Role.objects.count(),
            'active_roles': Role.objects.filter(is_active=True).count(),
            'total_departments': Department.objects.count(),
            'active_departments': Department.objects.filter(is_active=True).count(),
            'total_modules': Module.objects.count(),
            'active_modules': Module.objects.filter(is_active=True).count(),
        }
        
        # Get recent users (last 5)
        recent_users = User.objects.order_by('-date_joined')[:5]
        stats['recent_users'] = [
            {
                'id': user.id,
                'username': user.username,
                'email': user.email,
                'first_name': user.first_name,
                'last_name': user.last_name,
                'date_joined': user.date_joined,
            }
            for user in recent_users
        ]
        
        return Response(stats)