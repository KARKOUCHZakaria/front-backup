import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';
import '../providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark;

    return Scaffold(
      backgroundColor: AppColors.darkBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Settings',
          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSection(context, 'APPEARANCE', [
                  _buildSwitchTile(context, Icons.dark_mode, 'Dark Mode', 'Use dark theme', isDark, (value) {
                    ref.read(themeModeProvider.notifier).state = value ? ThemeMode.dark : ThemeMode.light;
                  }),
                ]),
                const SizedBox(height: 24),
                _buildSection(context, 'NOTIFICATIONS', [
                  _buildSwitchTile(context, Icons.notifications_active, 'Push Notifications', 'Receive push notifications', true, (value) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Notification settings updated')));
                  }),
                  _buildSwitchTile(context, Icons.email, 'Email Notifications', 'Receive email updates', true, (value) {}),
                ]),
                const SizedBox(height: 24),
                _buildSection(context, 'PRIVACY & SECURITY', [
                  _buildTile(context, Icons.lock, 'Change Password', 'Update your password', () => _showChangePasswordDialog(context)),
                  _buildSwitchTile(context, Icons.fingerprint, 'Biometric Login', 'Use fingerprint or face ID', false, (value) {}),
                  _buildTile(context, Icons.privacy_tip, 'Privacy Policy', 'View our privacy policy', () => context.push('/privacy-policy')),
                ]),
                const SizedBox(height: 24),
                _buildSection(context, 'SUPPORT', [
                  _buildTile(context, Icons.help, 'Help & Support', 'Get help with your account', () => context.push('/help-support')),
                  _buildTile(context, Icons.info, 'About', 'App version and info', () => context.push('/about')),
                ]),
                const SizedBox(height: 24),
                _buildSection(context, 'ACCOUNT', [
                  _buildTile(context, Icons.logout, 'Log Out', 'Sign out of your account', () => _showLogoutDialog(context), Colors.redAccent),
                  _buildTile(context, Icons.delete_forever, 'Delete Account', 'Permanently delete your account', () => _showDeleteAccountDialog(context), Colors.red),
                ]),
                const SizedBox(height: 32),
                Center(child: Text('Version 1.0.0', style: TextStyle(color: AppColors.textMuted, fontSize: 14))),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(title, style: TextStyle(color: AppColors.primaryCyan, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
        ),
        Container(
          decoration: BoxDecoration(color: AppColors.darkTeal, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withOpacity(0.05))),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildTile(BuildContext context, IconData icon, String title, String subtitle, VoidCallback onTap, [Color? textColor]) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: (textColor ?? AppColors.primaryCyan).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, color: textColor ?? AppColors.primaryCyan, size: 20),
      ),
      title: Text(title, style: TextStyle(color: textColor ?? Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle, style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
      trailing: Icon(Icons.arrow_forward_ios, color: AppColors.textMuted, size: 16),
    );
  }

  Widget _buildSwitchTile(BuildContext context, IconData icon, String title, String subtitle, bool value, ValueChanged<bool> onChanged) {
    return SwitchListTile(
      secondary: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: AppColors.primaryCyan.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, color: AppColors.primaryCyan, size: 20),
      ),
      title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle, style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
      value: value,
      onChanged: onChanged,
      activeColor: AppColors.primaryCyan,
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.darkTeal,
        title: const Text('Log Out', style: TextStyle(color: Colors.white)),
        content: const Text('Are you sure you want to log out?', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(onPressed: () { Navigator.pop(ctx); context.go('/login'); }, child: const Text('Log Out', style: TextStyle(color: Colors.redAccent))),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.darkTeal,
        title: const Text('Delete Account', style: TextStyle(color: Colors.red)),
        content: const Text('This action cannot be undone. All your data will be permanently deleted.', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(onPressed: () { Navigator.pop(ctx); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Account deletion requested'))); }, child: const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.darkTeal,
        title: const Text('Change Password', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(obscureText: true, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Current Password', labelStyle: TextStyle(color: Colors.white70))),
            const SizedBox(height: 16),
            TextField(obscureText: true, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'New Password', labelStyle: TextStyle(color: Colors.white70))),
            const SizedBox(height: 16),
            TextField(obscureText: true, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Confirm Password', labelStyle: TextStyle(color: Colors.white70))),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(onPressed: () { Navigator.pop(ctx); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password updated successfully'))); }, child: const Text('Update')),
        ],
      ),
    );
  }
}
