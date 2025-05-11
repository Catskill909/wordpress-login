import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wordpress_app/core/di/service_locator.dart';
import 'package:wordpress_app/domain/blocs/auth/auth_event.dart';
import 'package:wordpress_app/domain/blocs/auth/auth_state.dart';
import 'package:wordpress_app/domain/repositories/auth_repository.dart';
import 'package:wordpress_app/domain/usecases/login_usecase.dart';
import 'package:wordpress_app/domain/usecases/logout_usecase.dart';
import 'package:wordpress_app/domain/usecases/register_usecase.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase _loginUseCase;
  final LogoutUseCase _logoutUseCase;
  final RegisterUseCase _registerUseCase;

  AuthBloc({
    required LoginUseCase loginUseCase,
    required LogoutUseCase logoutUseCase,
    required RegisterUseCase registerUseCase,
  })  : _loginUseCase = loginUseCase,
        _logoutUseCase = logoutUseCase,
        _registerUseCase = registerUseCase,
        super(AuthInitial()) {
    on<CheckAuthStatusEvent>(_onCheckAuthStatus);
    on<LoginEvent>(_onLogin);
    on<RegisterEvent>(_onRegister);
    on<LogoutEvent>(_onLogout);
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatusEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    // Get repository from service locator instead
    final repository = sl<AuthRepository>();
    final isLoggedIn = await repository.isLoggedIn();

    if (isLoggedIn) {
      final userResult = await repository.getCurrentUser();
      userResult.fold(
        (failure) => emit(Unauthenticated()),
        (user) => emit(Authenticated(user: user)),
      );
    } else {
      emit(Unauthenticated());
    }
  }

  Future<void> _onLogin(
    LoginEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await _loginUseCase(
      LoginParams(
        username: event.username,
        password: event.password,
      ),
    );

    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (user) => emit(Authenticated(user: user)),
    );
  }

  Future<void> _onRegister(
    RegisterEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await _registerUseCase(
      RegisterParams(
        username: event.username,
        email: event.email,
        password: event.password,
      ),
    );

    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (user) => emit(Authenticated(user: user)),
    );
  }

  Future<void> _onLogout(
    LogoutEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await _logoutUseCase();

    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (_) => emit(Unauthenticated()),
    );
  }
}
