from rest_framework import serializers
from django.contrib.auth import get_user_model
from apps.roles.serializers import RoleSerializer
from apps.departments.serializers import DepartmentSerializer
from apps.roles.models import Role

User = get_user_model()


class UserRegistrationSerializer(serializers.ModelSerializer):
    """
    Serializer for user registration.
    """
    password = serializers.CharField(write_only=True, min_length=8)
    password_confirm = serializers.CharField(write_only=True, required=False)
    role_ids = serializers.ListField(
        child=serializers.IntegerField(),
        write_only=True,
        required=False,
        allow_empty=True
    )
    department_id = serializers.IntegerField(write_only=True, required=False, allow_null=True)
    
    class Meta:
        model = User
        fields = (
            'username', 'email', 'phone', 'password', 'password_confirm',
            'first_name', 'last_name', 'employee_id', 'role_ids', 'department_id'
        )
    
    def validate(self, data):
        if 'password_confirm' in data and data['password'] != data['password_confirm']:
            raise serializers.ValidationError({"password": "Passwords do not match."})
        return data
    
    def create(self, validated_data):
        validated_data.pop('password_confirm', None)
        role_ids = validated_data.pop('role_ids', [])
        department_id = validated_data.pop('department_id', None)
        
        user = User.objects.create_user(**validated_data)
        
        # Assign multiple roles
        if role_ids:
            roles = Role.objects.filter(id__in=role_ids)
            user.roles.set(roles)
        
        if department_id:
            user.department_id = department_id
            user.save()
        
        return user


class UserProfileSerializer(serializers.ModelSerializer):
    """
    Serializer for viewing/updating user profile.
    """
    roles = RoleSerializer(many=True, read_only=True)
    
    class Meta:
        model = User
        fields = ('id', 'username', 'email', 'phone', 'employee_id', 'roles', 'is_active', 'created_at')
        read_only_fields = ('id', 'created_at')


class UserSerializer(serializers.ModelSerializer):
    """
    Serializer for listing/updating users with role and department details.
    """
    roles = RoleSerializer(many=True, read_only=True)
    department = DepartmentSerializer(read_only=True)
    role_ids = serializers.ListField(
        child=serializers.IntegerField(),
        write_only=True,
        required=False,
        allow_empty=True
    )
    department_id = serializers.IntegerField(write_only=True, required=False, allow_null=True)
    
    class Meta:
        model = User
        fields = (
            'id', 'username', 'email', 'first_name', 'last_name',
            'phone', 'employee_id', 'roles', 'department',
            'role_ids', 'department_id', 'is_active', 'date_joined'
        )
        read_only_fields = ('id', 'date_joined')
    
    def update(self, instance, validated_data):
        # Handle role_ids (multiple roles)
        if 'role_ids' in validated_data:
            role_ids = validated_data.pop('role_ids')
            roles = Role.objects.filter(id__in=role_ids)
            instance.roles.set(roles)
        
        # Handle department_id
        if 'department_id' in validated_data:
            instance.department_id = validated_data.pop('department_id')
        
        # Update other fields
        for attr, value in validated_data.items():
            setattr(instance, attr, value)
        
        instance.save()
        return instance