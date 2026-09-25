import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/datasources/group_remote_datasource.dart';
import '../../data/datasources/submission_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/group_repository_impl.dart';
import '../../data/repositories/submission_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/group_repository.dart';
import '../../domain/repositories/submission_repository.dart';
import '../../presentation/bloc/auth/auth_bloc.dart';
import '../../presentation/bloc/grading/grading_bloc.dart';
import '../../presentation/bloc/group/group_bloc.dart';
import '../../presentation/bloc/submission/submission_bloc.dart';
import '../network/api_client.dart';
import '../storage/session_storage.dart';

final GetIt sl = GetIt.instance;

void setupInjector() {
  sl.registerLazySingleton<FlutterSecureStorage>(() => const FlutterSecureStorage());
  sl.registerLazySingleton<SessionStorage>(() => SessionStorage(sl()));
  sl.registerLazySingleton<ApiClient>(() => ApiClient(sl()));

  sl.registerLazySingleton<AuthRemoteDatasource>(() => AuthRemoteDatasource(sl()));
  sl.registerLazySingleton<GroupRemoteDatasource>(() => GroupRemoteDatasource(sl()));
  sl.registerLazySingleton<SubmissionRemoteDatasource>(() => SubmissionRemoteDatasource(sl()));

  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(sl(), sl(), sl()));
  sl.registerLazySingleton<GroupRepository>(() => GroupRepositoryImpl(sl()));
  sl.registerLazySingleton<SubmissionRepository>(() => SubmissionRepositoryImpl(sl()));

  sl.registerFactory<AuthBloc>(() => AuthBloc(sl()));
  sl.registerFactory<GroupBloc>(() => GroupBloc(sl()));
  sl.registerFactory<SubmissionBloc>(() => SubmissionBloc(sl()));
  sl.registerFactory<GradingBloc>(() => GradingBloc(sl()));
}
