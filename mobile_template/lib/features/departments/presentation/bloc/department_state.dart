import '../../domain/entities/department_entity.dart';

abstract class DepartmentState {}

class DepartmentInitial extends DepartmentState {}

class DepartmentLoading extends DepartmentState {}

class DepartmentsLoaded extends DepartmentState {
  final List<DepartmentEntity> departments;

  DepartmentsLoaded(this.departments);
}

class SingleDepartmentLoaded extends DepartmentState {
  final DepartmentEntity department;

  SingleDepartmentLoaded(this.department);
}

class DepartmentError extends DepartmentState {
  final String message;

  DepartmentError(this.message);
}