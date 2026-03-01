import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_dashboard_stats.dart';
import '../../../../core/services/permission_service.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final GetDashboardStats getDashboardStats;
  final PermissionService permissionService;

  DashboardBloc({
    required this.getDashboardStats,
    required this.permissionService,
  }) : super(DashboardInitial()) {
    on<LoadDashboard>(_onLoadDashboard);
    on<RefreshDashboard>(_onLoadDashboard);
  }

  Future<void> _onLoadDashboard(
    DashboardEvent event,
    Emitter<DashboardState> emit,
  ) async {

    // 🔐 Check permission first
    if (!permissionService.canView('/dashboard')) {
      emit(DashboardError("No permission to view dashboard"));
      return;
    }

    emit(DashboardLoading());

    try {
      final data = await getDashboardStats();
      emit(DashboardLoaded(data));
    } catch (e) {
      emit(DashboardError(e.toString()));
    }
  }
}