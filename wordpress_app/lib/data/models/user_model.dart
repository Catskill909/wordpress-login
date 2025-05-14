import 'package:wordpress_app/core/utils/logger_util.dart';
import 'package:wordpress_app/domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.username,
    required super.email,
    super.firstName,
    super.lastName,
    super.avatarUrl,
    required super.roles,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Log the JSON for debugging
    LoggerUtil.d('UserModel.fromJson: $json');

    // Check for avatar_url in different locations
    String? avatarUrl = json['avatar_url'] as String?;

    // If avatar_url is not directly in the JSON, check in avatar_urls
    if (avatarUrl == null && json.containsKey('avatar_urls')) {
      final avatarUrls = json['avatar_urls'];
      if (avatarUrls is Map && avatarUrls.containsKey('96')) {
        // Use the largest avatar (96px)
        avatarUrl = avatarUrls['96'] as String?;
        LoggerUtil.d('Found avatar_url in avatar_urls: $avatarUrl');
      }
    }

    // If still not found, check in meta for custom_avatar_url
    if (json.containsKey('meta') && json['meta'] != null) {
      final meta = json['meta'];
      if (meta is Map) {
        if (meta.containsKey('custom_avatar_url') && (meta['custom_avatar_url'] as String?)?.isNotEmpty == true) {
          avatarUrl = meta['custom_avatar_url'] as String?;
          LoggerUtil.d('Found avatar_url in meta[custom_avatar_url]: $avatarUrl');
        } else if (avatarUrl == null && meta.containsKey('avatar_url')) {
          avatarUrl = meta['avatar_url'] as String?;
          LoggerUtil.d('Found avatar_url in meta[avatar_url]: $avatarUrl');
        }
      }
    }

    // Handle different field names in WordPress API
    String username = '';
    if (json.containsKey('username')) {
      username = json['username'] as String;
    } else if (json.containsKey('slug')) {
      username = json['slug'] as String;
    } else if (json.containsKey('name')) {
      username = json['name'] as String;
    }

    // Handle email field
    String email = '';
    if (json.containsKey('email')) {
      email = json['email'] as String;
    }

    // Handle roles field
    List<String> roles = [];
    if (json.containsKey('roles')) {
      roles = (json['roles'] as List<dynamic>).map((e) => e as String).toList();
    }

    return UserModel(
      id: json['id'] as int,
      username: username,
      email: email,
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      avatarUrl: avatarUrl,
      roles: roles,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'avatar_url': avatarUrl,
      'roles': roles,
    };
  }

  factory UserModel.fromEntity(User user) {
    return UserModel(
      id: user.id,
      username: user.username,
      email: user.email,
      firstName: user.firstName,
      lastName: user.lastName,
      avatarUrl: user.avatarUrl,
      roles: user.roles,
    );
  }
}
