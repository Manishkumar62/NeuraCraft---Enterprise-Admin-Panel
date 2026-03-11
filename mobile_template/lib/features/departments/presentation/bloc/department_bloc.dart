import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/services/permission_service.dart';
import '../../domain/usecases/create_department.dart';
import '../../domain/usecases/delete_department.dart';
import '../../domain/usecases/update_department.dart';
import '../../domain/usecases/get_departments.dart';
import '../../domain/usecases/get_department_by_id.dart';
import 'department_event.dart';
import 'department_state.dart';

class DepartmentBloc extends Bloc<DepartmentEvent, DepartmentState> {
  final GetDepartmentsforDepart getDepartments;
  final GetDepartmentById getDepartmentById;
  final CreateDepartment createDepartment;
  final UpdateDepartment updateDepartment;
  final DeleteDepartment deleteDepartment;
  final PermissionService permissionService;

  DepartmentBloc({
    required this.getDepartments,
    required this.getDepartmentById,
    required this.createDepartment,
    required this.updateDepartment,
    required this.deleteDepartment,
    required this.permissionService,
  }) : super(DepartmentInitial()) {
    on<LoadDepartments>(_onLoadDepartments);
    on<LoadDepartmentById>(_onLoadDepartmentById);
    on<CreateDepartmentEvent>(_onCreateDepartment);
    on<UpdateDepartmentEvent>(_onUpdateDepartment);
    on<DeleteDepartmentEvent>(_onDeleteDepartment);
  }

  Future<void> _onLoadDepartments(LoadDepartments event, Emitter<DepartmentState> emit) async {
    if (!permissionService.canView('/departments')) {
      emit(DepartmentError('Permission denied'));
      return;
    }

    emit(DepartmentLoading());

    try {
      final departments = await getDepartments();
      emit(DepartmentsLoaded(departments));
    } catch (e) {
      emit(DepartmentError(e.toString()));
    }
  }

  Future<void> _onCreateDepartment(
    CreateDepartmentEvent event,
    Emitter<DepartmentState> emit,
  ) async {
    if (!permissionService.canAdd('/departments')) return;

    await createDepartment(event.data);
    add(LoadDepartments());
  }

  Future<void> _onUpdateDepartment(
    UpdateDepartmentEvent event,
    Emitter<DepartmentState> emit,
  ) async {
    if (!permissionService.canEdit('/departments')) return;

    await updateDepartment(event.id, event.data);
    add(LoadDepartments());
  }

  Future<void> _onDeleteDepartment(
    DeleteDepartmentEvent event,
    Emitter<DepartmentState> emit,
  ) async {
    if (!permissionService.canDelete('/departments')) return;

    await deleteDepartment(event.id);
    add(LoadDepartments());
  }

  Future<void> _onLoadDepartmentById(
    LoadDepartmentById event,
    Emitter<DepartmentState> emit,
  ) async {
    emit(DepartmentLoading());

    try {
      final department = await getDepartmentById(event.id);
      emit(SingleDepartmentLoaded(department));
    } catch (e) {
      emit(DepartmentError(e.toString()));
    }
  }
}
