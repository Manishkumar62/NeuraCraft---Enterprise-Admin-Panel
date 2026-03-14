import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/permission_service.dart';

import '../../domain/usecases/get_modules.dart';
import '../../domain/usecases/get_module_by_id.dart';
import '../../domain/usecases/create_module.dart';
import '../../domain/usecases/update_module.dart';
import '../../domain/usecases/delete_module.dart';

import 'module_event.dart';
import 'module_state.dart';

class ModuleBloc extends Bloc<ModuleEvent, ModuleState> {
  final GetModules getModules;
  final GetModuleById getModuleById;
  final CreateModule createModule;
  final UpdateModule updateModule;
  final DeleteModule deleteModule;
  final PermissionService permissionService;

  ModuleBloc({
    required this.getModules,
    required this.getModuleById,
    required this.createModule,
    required this.updateModule,
    required this.deleteModule,
    required this.permissionService,
  }) : super(ModuleInitial()) {
    on<LoadModules>((event, emit) async {
      if (!permissionService.canView('/modules')) {
        emit(ModuleError('Permission denied'));
        return;
      }

      emit(ModuleLoading());

      try {
        final modules = await getModules();
        emit(ModuleLoaded(modules));
      } catch (e) {
        emit(ModuleError(e.toString()));
      }
    });

    on<LoadModuleById>((event, emit) async {
      emit(ModuleLoading());

      try {
        final module = await getModuleById(event.id);
        emit(SingleModuleLoaded(module));
      } catch (e) {
        emit(ModuleError(e.toString()));
      }
    });

    on<CreateModuleEvent>((event, emit) async {
      if (!permissionService.canAdd('/modules')) return;

      emit(ModuleLoading());

      try {
        await createModule(event.data);
        emit(ModuleSaved());
      } catch (e) {
        emit(ModuleError(e.toString()));
      }
    });

    on<UpdateModuleEvent>((event, emit) async {
      if (!permissionService.canEdit('/modules')) return;

      emit(ModuleLoading());

      try {
        await updateModule(event.id, event.data);
        emit(ModuleSaved());
      } catch (e) {
        emit(ModuleError(e.toString()));
      }
    });

    on<DeleteModuleEvent>((event, emit) async {
      if (!permissionService.canDelete('/modules')) return;

      try {
        await deleteModule(event.id);
        add(LoadModules());
      } catch (e) {
        emit(ModuleError(e.toString()));
      }
    });
  }
}
