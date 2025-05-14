import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wordpress_app/domain/blocs/auth/auth_bloc.dart';
import 'package:wordpress_app/domain/blocs/auth/auth_event.dart';
import 'package:wordpress_app/domain/blocs/auth/auth_state.dart';
import 'package:wordpress_app/domain/blocs/profile/profile_bloc.dart';
import 'package:wordpress_app/domain/blocs/profile/profile_event.dart';
import 'package:wordpress_app/domain/blocs/profile/profile_state.dart';
import 'package:wordpress_app/presentation/pages/category_posts_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ImagePicker _imagePicker = ImagePicker();

  Future<void> _pickImage(BuildContext context) async {
    // Store the theme color and get the bloc before the async gap
    final themeColor = Theme.of(context).primaryColor;
    final profileBloc = context.read<ProfileBloc>();

    final XFile? pickedFile = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
      requestFullMetadata: false, // Reduce metadata
    );

    if (!mounted) return; // Check if widget is still mounted

    if (pickedFile != null) {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        compressQuality: 90,
        maxWidth: 400,
        maxHeight: 400,
        cropStyle: CropStyle.circle,
        compressFormat:
            ImageCompressFormat.png, // Use PNG format for better compatibility
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Profile Image',
            toolbarColor: themeColor, // Use stored theme color
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: true,
          ),
          IOSUiSettings(
            title: 'Crop Profile Image',
            aspectRatioLockEnabled: true,
            minimumAspectRatio: 1.0,
          ),
        ],
      );

      if (!mounted) return; // Check if widget is still mounted

      if (croppedFile != null) {
        // Use the bloc reference we got before the async gap
        profileBloc.add(
          UpdateProfileImageEvent(imageFile: File(croppedFile.path)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WordPress App'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthBloc>().add(LogoutEvent());
            },
          ),
        ],
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is Authenticated) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Welcome to WordPress App',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Text(
                                  'Your Profile',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Spacer(),
                                BlocBuilder<ProfileBloc, ProfileState>(
                                  builder: (context, profileState) {
                                    String? avatarUrl = state.user.avatarUrl;
                                    if (profileState is ProfileImageUpdated) {
                                      avatarUrl = profileState.user.avatarUrl;
                                    }
                                    // DEBUG: Print the avatarUrl being used
                                    // print removed (was for debugging): '[HomePage] Displaying avatarUrl: $avatarUrl');
                                    return Stack(
                                      children: [
                                        CircleAvatar(
                                          key: ValueKey(avatarUrl ?? 'default'),
                                          radius: 40,
                                          backgroundImage: avatarUrl != null
                                              ? NetworkImage(avatarUrl)
                                              : const AssetImage('assets/images/default_profile.png') as ImageProvider,
                                        ),
                                        Positioned(
                                          right: 0,
                                          bottom: 0,
                                          child: Container(
                                            height: 30,
                                            width: 30,
                                            decoration: BoxDecoration(
                                              color: Theme.of(context).primaryColor,
                                              shape: BoxShape.circle,
                                            ),
                                            child: InkWell(
                                              onTap: () {
                                                if (profileState is ProfileImageUpdating) {
                                                  return;
                                                }
                                                _pickImage(context);
                                              },
                                              child: const Icon(
                                                Icons.camera_alt,
                                                color: Colors.white,
                                                size: 16,
                                              ),
                                            ),
                                          ),
                                        ),
                                        if (profileState is ProfileImageUpdating)
                                          Positioned.fill(
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: Colors.black.withAlpha(128),
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Center(
                                                child: CircularProgressIndicator(
                                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                                ),
                                              ),
                                            ),
                                          ),
                                      ],
                                    );
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            _buildProfileItem(
                              icon: Icons.person,
                              title: 'Username',
                              value: state.user.username.isNotEmpty ? state.user.username : '-',
                            ),
                            const Divider(),
                            _buildProfileItem(
                              icon: Icons.email,
                              title: 'Email',
                              value: (state.user.email.isNotEmpty) ? state.user.email : '-',
                            ),
                            const Divider(),
                            _buildProfileItem(
                              icon: Icons.badge,
                              title: 'First Name',
                              value: (state.user.firstName != null && state.user.firstName!.isNotEmpty) ? state.user.firstName! : '-',
                            ),
                            const Divider(),
                            _buildProfileItem(
                              icon: Icons.badge,
                              title: 'Last Name',
                              value: (state.user.lastName != null && state.user.lastName!.isNotEmpty) ? state.user.lastName! : '-',
                            ),
                            if (state.user.roles.isNotEmpty) ...[
                              const Divider(),
                              _buildProfileItem(
                                icon: Icons.security,
                                title: 'Roles',
                                value: state.user.roles.join(', '),
                              ),
                            ],
                            // If UserModel is extended (e.g. displayName, nickname, etc.), add more fields here.

                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Categories',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      elevation: 2,
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: const CircleAvatar(child: Text('FR')),
                        title: const Text('French'),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CategoryPostsPage(categoryName: 'French', categoryId: 6),
                            ),
                          );
                        },
                      ),
                    ),
                    Card(
                      elevation: 2,
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: const CircleAvatar(child: Text('EN')),
                        title: const Text('English'),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CategoryPostsPage(categoryName: 'English', categoryId: 4),
                            ),
                          );
                        },
                      ),
                    ),
                    Card(
                      elevation: 2,
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: const CircleAvatar(child: Text('SP')),
                        title: const Text('Spanish'),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CategoryPostsPage(categoryName: 'Spanish', categoryId: 5),
                            ),
                          );
                        },
                      ),
                    ),
                    Card(
                      elevation: 2,
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: const CircleAvatar(child: Text('GE')),
                        title: const Text('German'),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CategoryPostsPage(categoryName: 'German', categoryId: 3),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }

  Widget _buildProfileItem({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, color: Colors.blue),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
