import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wordpress_app/core/di/service_locator.dart';
import 'package:wordpress_app/core/utils/logger_util.dart';
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
    on<ForgotPasswordEvent>(_onForgotPassword);
    on<RequestPasswordResetCodeEvent>(_onRequestPasswordResetCode);
    on<VerifyPasswordResetCodeEvent>(_onVerifyPasswordResetCode);
    on<ResetPasswordEvent>(_onResetPassword);
    on<RequestRegistrationCodeEvent>(_onRequestRegistrationCode);
    on<VerifyRegistrationEvent>(_onVerifyRegistration);
    on<RefreshUserEvent>(_onRefreshUser);
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

  Future<void> _onForgotPassword(
    ForgotPasswordEvent event,
    Emitter<AuthState> emit,
  ) async {
    // This is now just a wrapper around _onRequestPasswordResetCode for backward compatibility
    add(RequestPasswordResetCodeEvent(email: event.email));
  }

  Future<void> _onRequestPasswordResetCode(
    RequestPasswordResetCodeEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    // Get repository from service locator
    final repository = sl<AuthRepository>();
    final result = await repository.requestPasswordResetCode(event.email);

    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (_) => emit(PasswordResetCodeSent(email: event.email)),
    );
  }

  Future<void> _onVerifyPasswordResetCode(
    VerifyPasswordResetCodeEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    // Get repository from service locator
    final repository = sl<AuthRepository>();
    final result =
        await repository.verifyPasswordResetCode(event.email, event.code);

    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (resetToken) => emit(PasswordResetCodeVerified(
        email: event.email,
        resetToken: resetToken,
      )),
    );
  }

  Future<void> _onResetPassword(
    ResetPasswordEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    // Get repository from service locator
    final repository = sl<AuthRepository>();
    final result = await repository.resetPassword(
      event.email,
      event.resetToken,
      event.newPassword,
    );

    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (_) => emit(PasswordResetSuccess()),
    );
  }

  Future<void> _onRequestRegistrationCode(
    RequestRegistrationCodeEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    // Get repository from service locator
    final repository = sl<AuthRepository>();
    final result = await repository.requestRegistrationCode(event.email);

    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (_) => emit(RegistrationCodeSent(email: event.email)),
    );
  }

  Future<void> _onVerifyRegistration(
    VerifyRegistrationEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    // Get repository from service locator
    final repository = sl<AuthRepository>();
    final result = await repository.verifyRegistration(event.email, event.code);

    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (_) => emit(RegistrationVerified(email: event.email)),
    );
  }

  // Handle refreshing user data when profile is updated
  void _onRefreshUser(
    RefreshUserEvent event,
    Emitter<AuthState> emit,
  ) {
    LoggerUtil.d(
        'Refreshing user data with new avatar URL: ${event.user.avatarUrl}');

    // Get the current state
    final currentState = state;

    // Only update if we're already authenticated
    if (currentState is Authenticated) {
      LoggerUtil.d('Current avatar URL: ${currentState.user.avatarUrl}');
      LoggerUtil.d('New avatar URL: ${event.user.avatarUrl}');

      // Update the authenticated state with the new user data
      emit(Authenticated(user: event.user));
      LoggerUtil.d('Auth state updated with new user data');
    } else {
  
    }
  }
}
