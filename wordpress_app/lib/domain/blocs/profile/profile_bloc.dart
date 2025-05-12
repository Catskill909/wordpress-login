import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wordpress_app/core/utils/logger_util.dart';
import 'package:wordpress_app/domain/blocs/auth/auth_bloc.dart';
import 'package:wordpress_app/domain/blocs/auth/auth_event.dart';
import 'package:wordpress_app/domain/blocs/profile/profile_event.dart';
import 'package:wordpress_app/domain/blocs/profile/profile_state.dart';
import 'package:wordpress_app/domain/usecases/get_user_profile_usecase.dart';
import 'package:wordpress_app/domain/usecases/update_profile_image_usecase.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetUserProfileUseCase _getUserProfileUseCase;
  final UpdateProfileImageUseCase _updateProfileImageUseCase;
  final AuthBloc _authBloc;

  ProfileBloc({
    required GetUserProfileUseCase getUserProfileUseCase,
    required UpdateProfileImageUseCase updateProfileImageUseCase,
    required AuthBloc authBloc,
  })  : _getUserProfileUseCase = getUserProfileUseCase,
        _updateProfileImageUseCase = updateProfileImageUseCase,
        _authBloc = authBloc,
        super(const ProfileInitial()) {
    on<LoadProfileEvent>(_onLoadProfile);
    on<UpdateProfileImageEvent>(_onUpdateProfileImage);
  }

  Future<void> _onLoadProfile(
    LoadProfileEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileLoading());

    final result = await _getUserProfileUseCase();

    result.fold(
      (failure) => emit(ProfileError(message: failure.message)),
      (user) => emit(ProfileLoaded(user: user)),
    );
  }

  Future<void> _onUpdateProfileImage(
    UpdateProfileImageEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileImageUpdating());

    final result = await _updateProfileImageUseCase(
      UpdateProfileImageParams(imageFile: event.imageFile),
    );

    result.fold(
      (failure) {
        LoggerUtil.e('Profile image update failed: ${failure.message}');
        emit(ProfileError(message: failure.message));
      },
      (user) {
        LoggerUtil.i('Profile image updated successfully: ${user.avatarUrl}');
        // First update the auth state to ensure the user data is updated everywhere
        _authBloc.add(RefreshUserEvent(user: user));
        // Then update the profile state
        emit(ProfileImageUpdated(user: user));
      },
    );
  }
}
