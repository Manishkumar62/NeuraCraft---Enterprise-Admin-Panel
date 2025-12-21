from django.urls import path
from rest_framework_simplejwt.views import TokenObtainPairView, TokenRefreshView

from .views import RegisterView, ProfileView, LogoutView, UserListView, UserDetailView

urlpatterns = [
    # JWT Authentication
    path('login/', TokenObtainPairView.as_view(), name='login'),
    path('token/refresh/', TokenRefreshView.as_view(), name='token_refresh'),
    
    # User endpoints
    path('register/', RegisterView.as_view(), name='register'),
    path('profile/', ProfileView.as_view(), name='profile'),
    path('logout/', LogoutView.as_view(), name='logout'),

    # User CRUD (add these 2 lines)
    path('', UserListView.as_view(), name='user-list'),
    path('<int:pk>/', UserDetailView.as_view(), name='user-detail'),
]

# | URL | Method | Purpose |
# |-----|--------|---------|
# | `/login/` | POST | Get access & refresh tokens |
# | `/token/refresh/` | POST | Get new access token |
# | `/register/` | POST | Create new user |
# | `/profile/` | GET | View logged-in user info |
# | `/logout/` | POST | Invalidate refresh token |