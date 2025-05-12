import 'dart:io';
import 'package:equatable/equatable.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class LoadProfileEvent extends ProfileEvent {
  const LoadProfileEvent();
}

class UpdateProfileImageEvent extends ProfileEvent {
  final File imageFile;

  const UpdateProfileImageEvent({required this.imageFile});

  @override
  List<Object?> get props => [imageFile];
}
