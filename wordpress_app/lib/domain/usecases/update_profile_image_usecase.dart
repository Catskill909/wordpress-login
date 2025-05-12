import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:wordpress_app/core/errors/failures.dart';
import 'package:wordpress_app/domain/entities/user.dart';
import 'package:wordpress_app/domain/repositories/profile_repository.dart';

class UpdateProfileImageUseCase {
  final ProfileRepository _repository;

  UpdateProfileImageUseCase({required ProfileRepository repository})
      : _repository = repository;

  Future<Either<Failure, User>> call(UpdateProfileImageParams params) async {
    return await _repository.updateProfileImage(params.imageFile);
  }
}

class UpdateProfileImageParams extends Equatable {
  final File imageFile;

  const UpdateProfileImageParams({required this.imageFile});

  @override
  List<Object> get props => [imageFile];
}
