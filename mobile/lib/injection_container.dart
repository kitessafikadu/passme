import 'package:get_it/get_it.dart';
import 'package:mobile/core/network/api_client.dart';
import 'package:mobile/core/service/local_storage_service.dart';
import 'package:mobile/features/auth/domain/usecases/sign_up_usecase.dart';
import 'package:mobile/features/auth/presentation/blocs/sign_up_bloc.dart';
import 'package:mobile/features/flight_info/data/datasources/flight_remote_datasource.dart';
import 'package:mobile/features/flight_info/data/datasources/flight_remote_datasource_impl.dart';
import 'package:mobile/features/flight_info/data/repositories/flight_repository_impl.dart';
import 'package:mobile/features/flight_info/domain/repositories/flight_repository.dart';
import 'package:mobile/features/flight_info/domain/usecases/delete_flight.dart';
import 'package:mobile/features/flight_info/domain/usecases/get_all_flights.dart';
import 'package:mobile/features/flight_info/presentation/blocs/flight_bloc.dart';
import 'package:mobile/features/form/data/datasource/question_remote_datasource.dart';
import 'package:mobile/features/form/data/repositories/question_repository_impl.dart';
import 'package:mobile/features/form/domain/repositories/question_repository.dart';
import 'package:mobile/features/form/domain/usecases/get_questions.dart';
import 'package:mobile/features/form/domain/usecases/submit_Answer.dart';
import 'package:mobile/features/form/presentation/blocs/form_bloc.dart';
import 'package:mobile/features/onboarding/presentation/bloc/onboarding_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'features/auth/domain/usecases/login_user.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/data/datasources/auth_remote_datasource_impl.dart';
import 'features/auth/presentation/blocs/login_cubit.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:mobile/features/profile/data/datasources/profile_remote_datasource.dart';
import 'package:mobile/features/profile/presentation/bloc/profile_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Initialize core dependencies first
  await _initCore();

  // Then initialize feature-specific dependencies
  _initAuth();
  _initForm();
  _initFlight();
  _initProfile();
}

void _initProfile() {
  sl.registerLazySingleton<ProfileRemoteDataSource>(
    () =>
        ProfileRemoteDataSourceImpl(sl<ApiClient>(), sl<LocalStorageService>()),
  );
  sl.registerFactory(() => ProfileBloc(sl<ProfileRemoteDataSource>()));
}

Future<void> _initCore() async {
  // 1. Load environment variables
  await dotenv.load(fileName: ".env");

  // 2. Initialize SharedPreferences
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerSingleton<SharedPreferences>(sharedPreferences);

  // 3. Register LocalStorageService
  sl.registerSingleton<LocalStorageService>(
    LocalStorageService(sl()),
  );

  // 4. Register ApiClient (depends on LocalStorageService)
  sl.registerLazySingleton<ApiClient>(() => ApiClient(
        baseUrl: dotenv.env['API_URL']!,
        localStorage: sl(),
        debugMode: true,
      ));
}

void _initAuth() {
  // Auth Data Source
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(sl(), sl()),
  );

  // Auth Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl()),
  );

  // Auth Use Cases
  sl.registerLazySingleton(() => LoginUser(sl()));
  sl.registerLazySingleton(() => SignUpUseCase(sl()));

  // Auth BLoCs/Cubits
  sl.registerFactory(() => LoginCubit(
        loginUser: sl<LoginUser>(),
        localStorageService: sl<LocalStorageService>(),
      ));
  sl.registerFactory(() => SignUpBloc(sl()));
  sl.registerFactory(() => OnboardingBloc());
}

void _initForm() {
  // Form Data Source
  sl.registerLazySingleton<QuestionRemoteDataSource>(
    () => QuestionRemoteDataSourceImpl(sl(), sl()),
  );

  // Form Repository
  sl.registerLazySingleton<QuestionRepository>(
    () => QuestionRepositoryImpl(sl()),
  );

  // Form Use Cases
  sl.registerLazySingleton(() => GetQuestionsUseCase(sl()));
  sl.registerLazySingleton(() => SubmitAnswersUseCase(sl()));

  // Form BLoC
  sl.registerFactory(() => FormBloc(questionRepository: sl()));
}

void _initFlight() {
  // Flight Data Source
  sl.registerLazySingleton<FlightRemoteDatasource>(
    () => FlightRemoteDatasourceImpl(sl()),
  );

  // Flight Repository
  sl.registerLazySingleton<FlightRepository>(() => FlightRepositoryImpl(
      remoteDatasource:
          sl())); // You'll need to add NetworkInfo if not already present),);

  // Flight Use Cases
  sl.registerLazySingleton(() => GetAllFlights(sl()));

  sl.registerLazySingleton(() => DeleteFlight(sl()));

  // Flight BLoC
  sl.registerFactory(
    () => FlightBloc(
      getFlights: sl(),
      deleteFlight: sl(),
    ),
  );
}
