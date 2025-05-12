import 'dart:io';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:wordpress_app/core/constants/app_constants.dart';
import 'package:wordpress_app/core/errors/exceptions.dart';
import 'package:wordpress_app/core/network/dio_client.dart';
import 'package:wordpress_app/core/utils/logger_util.dart';
import 'package:wordpress_app/data/models/user_model.dart';

abstract class ProfileRemoteDataSource {
  /// Uploads a profile image to WordPress media library
  /// Returns the URL of the uploaded image
  Future<String> uploadProfileImage(File imageFile);

  /// Updates the user's profile with the new avatar URL
  Future<UserModel> updateUserAvatar(int userId, String avatarUrl);

  /// Gets the current user's profile
  Future<UserModel> getUserProfile();
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final DioClient _dioClient;

  ProfileRemoteDataSourceImpl({required DioClient dioClient})
      : _dioClient = dioClient;

  @override
  Future<String> uploadProfileImage(File imageFile) async {
    try {
      LoggerUtil.i('Uploading profile image');

      // Get file extension and ensure it's a supported format
      String fileExtension = imageFile.path.split('.').last.toLowerCase();

      // Force PNG if not a supported format
      if (fileExtension != 'jpg' &&
          fileExtension != 'jpeg' &&
          fileExtension != 'png') {
        fileExtension = 'png';
      }

      final mimeType = 'image/$fileExtension';

      // Create form data
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          imageFile.path,
          filename:
              'profile_image.png', // Always use .png extension for filename
          contentType: MediaType.parse(mimeType),
        ),
      });

      // Upload to WordPress media library
      final response = await _dioClient.post(
        AppConstants.mediaEndpoint,
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      // Extract image URL from response
      String imageUrl = '';
      if (response.containsKey('source_url')) {
        imageUrl = response['source_url'] as String;
      } else if (response.containsKey('guid') &&
          response['guid'] is Map &&
          response['guid'].containsKey('rendered')) {
        imageUrl = response['guid']['rendered'] as String;
      } else if (response.containsKey('url')) {
        imageUrl = response['url'] as String;
      }

      LoggerUtil.i('Profile image uploaded successfully: $imageUrl');

      return imageUrl;
    } catch (e) {
      LoggerUtil.e('Failed to upload profile image: ${e.toString()}', e);
      throw ApiException(
          message: 'Failed to upload profile image: ${e.toString()}');
    }
  }

  @override
  Future<UserModel> updateUserAvatar(int userId, String avatarUrl) async {
    try {
      LoggerUtil.i(
          'Updating user avatar for user ID: $userId with URL: $avatarUrl');

      // Update user meta for avatar
      final response = await _dioClient.post(
        '${AppConstants.usersEndpoint}/$userId',
        data: {
          'meta': {
            'avatar_url': avatarUrl,
          },
        },
      );

      LoggerUtil.i('Update response: $response');

      // Create a modified response with the avatar URL if it's not in the response
      final Map<String, dynamic> userJson = Map<String, dynamic>.from(response);

      // Ensure the avatar_url is set in the response
      if (!userJson.containsKey('avatar_url') ||
          userJson['avatar_url'] == null) {
        userJson['avatar_url'] = avatarUrl;
        LoggerUtil.i('Added avatar_url to response: $avatarUrl');
      }

      final updatedUser = UserModel.fromJson(userJson);
      LoggerUtil.i(
          'User avatar updated successfully: ${updatedUser.avatarUrl}');

      return updatedUser;
    } catch (e) {
      LoggerUtil.e('Failed to update user avatar: ${e.toString()}', e);
      throw ApiException(
          message: 'Failed to update user avatar: ${e.toString()}');
    }
  }

  @override
  Future<UserModel> getUserProfile() async {
    try {
      final response = await _dioClient.get(AppConstants.userEndpoint);
      return UserModel.fromJson(response);
    } catch (e) {
      throw ApiException(
          message: 'Failed to get user profile: ${e.toString()}');
    }
  }
}
