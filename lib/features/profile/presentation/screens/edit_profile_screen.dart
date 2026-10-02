import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../auth/providers/auth_provider.dart';
import '../../../cat_sightings/providers/cat_sighting_providers.dart';
import '../../providers/profile_providers.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _picker = ImagePicker();

  File? _avatarFile;
  bool _didPopulate = false;
  bool _isSaving = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    final image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 1200,
      maxHeight: 1200,
    );
    if (image != null && mounted) setState(() => _avatarFile = File(image.path));
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    setState(() => _isSaving = true);
    try {
      final repository = ref.read(profileRepositoryProvider);
      String? avatarUrl;
      if (_avatarFile != null) {
        avatarUrl = await repository.uploadAvatar(
          imageFile: _avatarFile!,
          userId: user.id,
        );
      }
      await repository.updateProfile(
        userId: user.id,
        username: _usernameController.text,
        avatarUrl: avatarUrl,
      );

      final email = _emailController.text.trim();
      final password = _passwordController.text;
      if (email != user.email || password.isNotEmpty) {
        await ref.read(authRepositoryProvider).updateAccount(
              email: email == user.email ? null : email,
              password: password.isEmpty ? null : password,
            );
      }
      ref.invalidate(currentUserProfileProvider);
      ref.invalidate(catSightingsListProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile saved.')),
      );
      Navigator.of(context).pop();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(currentUserProfileProvider);
    final user = ref.watch(currentUserProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Edit profile')),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text('Could not load profile: $error'),
          ),
        ),
        data: (profile) {
          if (!_didPopulate) {
            _didPopulate = true;
            _usernameController.text = profile?.username ?? '';
            _emailController.text = user?.email ?? '';
          }
          final avatarUrl = profile?.avatarUrl;
          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 52,
                            backgroundColor: theme.colorScheme.primaryContainer,
                            backgroundImage: _avatarFile != null
                                ? FileImage(_avatarFile!)
                                : avatarUrl != null && avatarUrl.isNotEmpty
                                    ? CachedNetworkImageProvider(avatarUrl)
                                    : null,
                            child: _avatarFile == null &&
                                    (avatarUrl == null || avatarUrl.isEmpty)
                                ? Icon(Icons.person_rounded,
                                    size: 52,
                                    color: theme.colorScheme.onPrimaryContainer)
                                : null,
                          ),
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: IconButton.filled(
                              tooltip: 'Choose profile photo',
                              onPressed: _isSaving ? null : _pickAvatar,
                              icon: const Icon(Icons.photo_camera_outlined),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                    TextFormField(
                      controller: _usernameController,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Username',
                        prefixIcon: Icon(Icons.alternate_email_rounded),
                      ),
                      validator: (value) {
                        final username = value?.trim() ?? '';
                        if (username.isEmpty) return 'Enter a username.';
                        if (username.length < 3) return 'Use at least 3 characters.';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.mail_outline_rounded),
                      ),
                      validator: (value) {
                        final email = value?.trim() ?? '';
                        if (email.isEmpty || !email.contains('@')) {
                          return 'Enter a valid email.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'New password (optional)',
                        prefixIcon: Icon(Icons.lock_outline_rounded),
                      ),
                      validator: (value) {
                        if ((value?.isNotEmpty ?? false) && value!.length < 6) {
                          return 'Use at least 6 characters.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Changing your email may require confirmation from Supabase.',
                      style: theme.textTheme.bodySmall,
                    ),
                    const SizedBox(height: 28),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _isSaving ? null : _save,
                        child: _isSaving
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Save changes'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}