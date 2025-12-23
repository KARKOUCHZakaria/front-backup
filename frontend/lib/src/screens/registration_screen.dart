import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';
import '../providers/auth_provider.dart';
import '../services/file_picker_service.dart';

/// Registration/CIN Verification screen
class RegistrationScreen extends ConsumerStatefulWidget {
  const RegistrationScreen({super.key});

  @override
  ConsumerState<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends ConsumerState<RegistrationScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  
  File? _idCardImage;
  Uint8List? _idCardImageBytes; // For web
  String? _idCardImageName;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    // Pre-fill user data if available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(currentUserProvider);
      if (user != null) {
        _nameController.text = user.username;
        _emailController.text = user.email;
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _pickImage({bool fromCamera = true}) async {
    final result = await FilePickerService.pickImage(
      fromCamera: fromCamera,
      imageQuality: 80,
    );
    
    if (result != null && result.isValid) {
      setState(() {
        if (kIsWeb) {
          _idCardImageBytes = result.bytes;
          _idCardImageName = result.name;
        } else {
          _idCardImage = result.path != null ? File(result.path!) : null;
        }
      });
    }
  }

  Future<void> _verifyCin() async {
    if ((kIsWeb && _idCardImageBytes == null) || (!kIsWeb && _idCardImage == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please capture or select your CIN photo'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isProcessing = true);

    // For web, we need to create a temporary file or pass bytes directly
    final File? fileToUpload = kIsWeb 
        ? null // TODO: Handle web upload with bytes
        : _idCardImage;
    
    if (fileToUpload == null && kIsWeb) {
      // For now, skip CIN verification on web
      setState(() => _isProcessing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('CIN verification coming soon for web. Proceeding...'),
          backgroundColor: Colors.orange,
        ),
      );
      if (mounted) {
        context.go('/user/supplementary-info');
      }
      return;
    }

    final success = await ref.read(authProvider.notifier).verifyCin(fileToUpload!);

    setState(() => _isProcessing = false);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✓ Identity verified successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      // Navigate to supplementary info screen (phone number)
      context.go('/user/supplementary-info');
    } else if (mounted) {
      final error = ref.read(authProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? 'Verification failed. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _skipVerification() {
    // Navigate directly to supplementary info without CIN verification
    context.go('/user/supplementary-info');
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final user = authState.user;
    
    return Scaffold(
      backgroundColor: AppColors.darkBg,
      appBar: AppBar(
        backgroundColor: AppColors.darkBg,
        title: const Text('Identity Verification', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.go('/login'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User info display
            if (user != null) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primaryCyan.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: AppColors.primaryCyan,
                      child: Text(
                        user.username.isNotEmpty ? user.username[0].toUpperCase() : 'U',
                        style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.username,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                          ),
                          Text(
                            user.email,
                            style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      user.identityVerified ? Icons.verified : Icons.pending,
                      color: user.identityVerified ? Colors.green : Colors.orange,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
            
            Text(
              'Verify with CIN Photo',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Take a photo of your national ID card (CIN) to verify your identity',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 32),
            
            // ID Card Upload Section
            _buildIdCardUpload(),
            
            const SizedBox(height: 24),
            
            // Action buttons
            if (_idCardImage != null) ...[
              _buildVerifyButton(),
              const SizedBox(height: 16),
            ],
            
            _buildSkipButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildIdCardUpload() {
    final isLoading = ref.watch(authLoadingProvider);
    
    return Column(
      children: [
        GestureDetector(
          onTap: (_isProcessing || isLoading) ? null : () => _pickImage(fromCamera: true),
          child: Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _idCardImage != null ? AppColors.primaryCyan : AppColors.textSecondary.withOpacity(0.3),
                width: 2,
                strokeAlign: BorderSide.strokeAlignInside,
              ),
            ),
            child: (_isProcessing || isLoading)
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text(
                          'Processing...',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  )
                : _idCardImage == null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_a_photo, size: 48, color: AppColors.textSecondary),
                          const SizedBox(height: 12),
                          Text(
                            'Tap to capture CIN',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Front side of your national ID card',
                            style: TextStyle(
                              color: AppColors.textSecondary.withOpacity(0.6),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      )
                    : Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: kIsWeb && _idCardImageBytes != null
                                ? Image.memory(
                                    _idCardImageBytes!,
                                    width: double.infinity,
                                    height: double.infinity,
                                    fit: BoxFit.cover,
                                  )
                                : _idCardImage != null
                                    ? Image.file(
                                        _idCardImage!,
                                        width: double.infinity,
                                        height: double.infinity,
                                        fit: BoxFit.cover,
                                      )
                                    : Container(),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.primaryCyan,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.check_circle, color: Colors.black, size: 16),
                                  SizedBox(width: 4),
                                  Text(
                                    'Ready',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 8,
                            right: 8,
                            child: IconButton(
                              onPressed: () => _pickImage(fromCamera: true),
                              icon: const Icon(Icons.camera_alt),
                              color: Colors.white,
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.black54,
                              ),
                            ),
                          ),
                        ],
                      ),
          ),
        ),
        const SizedBox(height: 12),
        // Gallery option
        TextButton.icon(
          onPressed: (_isProcessing || ref.watch(authLoadingProvider)) 
              ? null 
              : () => _pickImage(fromCamera: false),
          icon: const Icon(Icons.photo_library, size: 20),
          label: const Text('Or choose from gallery'),
          style: TextButton.styleFrom(
            foregroundColor: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildVerifyButton() {
    final isLoading = ref.watch(authLoadingProvider);
    
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : _verifyCin,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: AppColors.primaryCyan,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.verified_user, size: 20, color: Colors.black),
                  SizedBox(width: 8),
                  Text(
                    'Verify Identity',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildSkipButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: _skipVerification,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          side: BorderSide(color: AppColors.textSecondary.withOpacity(0.3)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          'Skip for now',
          style: TextStyle(
            fontSize: 16,
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
