// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'data_store.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool notificationsEnabled = true;
  bool emailNotifications = false;
  bool soundEnabled = true;
  String privacyLevel = 'Friends';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.green,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 12),
              // User Profile Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: TextEditingController(text: DataStore.currentUserUsername ?? 'Unknown'),
                      readOnly: true,
                      decoration: InputDecoration(
                        label: const Text('Full Name'),
                        prefixIcon: const Icon(Icons.person),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        fillColor: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
                        filled: true,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: TextEditingController(text: DataStore.currentUserEmail ?? 'Unknown'),
                      readOnly: true,
                      decoration: InputDecoration(
                        label: const Text('Email Address'),
                        prefixIcon: const Icon(Icons.email),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        fillColor: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
                        filled: true,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Notifications Settings
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Notifications',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
                    ),
                    const SizedBox(height: 12),
                    Card(
                      color: isDark ? Colors.grey.shade800 : Colors.white,
                      child: Column(
                        children: [
                          SwitchListTile(
                            secondary: Icon(Icons.notifications),
                            title: const Text('Push Notifications'),
                            subtitle: const Text('Receive task reminders'),
                            value: notificationsEnabled,
                            onChanged: (value) {
                              setState(() => notificationsEnabled = value);
                            },
                          ),
                          Divider(height: 1),
                          SwitchListTile(
                            secondary: Icon(Icons.email),
                            title: const Text('Email Notifications'),
                            subtitle: const Text('Receive email updates'),
                            value: emailNotifications,
                            onChanged: (value) {
                              setState(() => emailNotifications = value);
                            },
                          ),
                          Divider(height: 1),
                          SwitchListTile(
                            secondary: Icon(Icons.volume_up),
                            title: const Text('Sound'),
                            subtitle: const Text('Enable notification sounds'),
                            value: soundEnabled,
                            onChanged: (value) {
                              setState(() => soundEnabled = value);
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Privacy Settings
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Privacy & Security',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
                    ),
                    const SizedBox(height: 12),
                    Card(
                      color: isDark ? Colors.grey.shade800 : Colors.white,
                      child: Column(
                        children: [
                          ListTile(
                            leading: Icon(Icons.lock),
                            title: const Text('Privacy Level'),
                            trailing: DropdownButton<String>(
                              value: privacyLevel,
                              items: ['Public', 'Friends', 'Private']
                                  .map((level) => DropdownMenuItem(value: level, child: Text(level)))
                                  .toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() => privacyLevel = value);
                                }
                              },
                            ),
                          ),
                          Divider(height: 1),
                          ListTile(
                            leading: Icon(Icons.security),
                            title: const Text('Change Password'),
                            trailing: Icon(Icons.arrow_forward_ios, size: 18),
                            onTap: () {
                              _showChangePasswordDialog();
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // About & Support
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'About & Support',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
                    ),
                    const SizedBox(height: 12),
                    Card(
                      color: isDark ? Colors.grey.shade800 : Colors.white,
                      child: Column(
                        children: [
                          ListTile(
                            leading: Icon(Icons.info),
                            title: const Text('App Version'),
                            trailing: const Text('1.0.0', style: TextStyle(color: Colors.grey)),
                          ),
                          Divider(height: 1),
                          ListTile(
                            leading: Icon(Icons.help),
                            title: const Text('Help & Feedback'),
                            trailing: Icon(Icons.arrow_forward_ios, size: 18),
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Help & Feedback'),
                                  content: SingleChildScrollView(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Text('FAQ:', style: TextStyle(fontWeight: FontWeight.bold)),
                                        const SizedBox(height: 8),
                                        const Text('• How do I add a task?\nTap the + button and fill in the details.\n\n• How do I mark a task complete?\nTap on any task to mark it complete.\n\n• How do I change my profile?\nGo to Profile → Edit Profile.'),
                                        const SizedBox(height: 16),
                                        const Text('Contact us:', style: TextStyle(fontWeight: FontWeight.bold)),
                                        const SizedBox(height: 8),
                                        const Text('Email: support@habitapp.com\nPhone: 1-800-HABITS-1'),
                                      ],
                                    ),
                                  ),
                                  actions: [
                                    ElevatedButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('Close'),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                          Divider(height: 1),
                          ListTile(
                            leading: Icon(Icons.description),
                            title: const Text('Terms of Service'),
                            trailing: Icon(Icons.arrow_forward_ios, size: 18),
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Terms of Service'),
                                  content: SingleChildScrollView(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Text('Terms of Service', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                        const SizedBox(height: 12),
                                        const Text(
                                          'Last Updated: December 1, 2025\n\n'
                                          '1. Acceptance of Terms\nBy using this app, you agree to these terms.\n\n'
                                          '2. User Responsibilities\nYou are responsible for maintaining confidentiality of your account.\n\n'
                                          '3. Limitation of Liability\nWe are not liable for any indirect or consequential damages.\n\n'
                                          '4. Changes to Terms\nWe may update these terms at any time.',
                                          style: TextStyle(fontSize: 13),
                                        ),
                                      ],
                                    ),
                                  ),
                                  actions: [
                                    ElevatedButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('Accept'),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                          Divider(height: 1),
                          ListTile(
                            leading: Icon(Icons.privacy_tip),
                            title: const Text('Privacy Policy'),
                            trailing: Icon(Icons.arrow_forward_ios, size: 18),
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Privacy Policy'),
                                  content: SingleChildScrollView(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Text('Privacy Policy', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                        const SizedBox(height: 12),
                                        const Text(
                                          'Last Updated: December 1, 2025\n\n'
                                          '1. Information We Collect\nWe collect name, email, and task data.\n\n'
                                          '2. How We Use Information\nWe use your data to improve the app experience.\n\n'
                                          '3. Data Security\nYour data is encrypted and stored securely.\n\n'
                                          '4. Third-Party Sharing\nWe do not share your data with third parties.',
                                          style: TextStyle(fontSize: 13),
                                        ),
                                      ],
                                    ),
                                  ),
                                  actions: [
                                    ElevatedButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('Understood'),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  void _showChangePasswordDialog() {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    bool showPassword = false;
    bool validateForm = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Change Password'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Enter your current password and new password:'),
                const SizedBox(height: 16),
                TextField(
                  controller: currentPasswordController,
                  obscureText: !showPassword,
                  decoration: InputDecoration(
                    labelText: 'Current Password',
                    prefixIcon: Icon(Icons.lock),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    errorText: validateForm && currentPasswordController.text.isEmpty ? 'Required' : null,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: newPasswordController,
                  obscureText: !showPassword,
                  decoration: InputDecoration(
                    labelText: 'New Password',
                    prefixIcon: Icon(Icons.lock_outline),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    errorText: validateForm && newPasswordController.text.isEmpty ? 'Required' : 
                               (validateForm && newPasswordController.text.length < 8 ? 'Min 8 characters' : null),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: confirmPasswordController,
                  obscureText: !showPassword,
                  decoration: InputDecoration(
                    labelText: 'Confirm New Password',
                    prefixIcon: Icon(Icons.lock_outline),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    errorText: validateForm && confirmPasswordController.text.isEmpty ? 'Required' :
                               (validateForm && newPasswordController.text != confirmPasswordController.text ? 'Passwords don\'t match' : null),
                  ),
                ),
                const SizedBox(height: 12),
                CheckboxListTile(
                  value: showPassword,
                  onChanged: (value) {
                    setState(() => showPassword = value ?? false);
                  },
                  title: const Text('Show Password'),
                  controlAffinity: ListTileControlAffinity.leading,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                // Capture context before any async operations
                final scaffoldContext = context;
                
                setState(() => validateForm = true);
                
                if (currentPasswordController.text.isEmpty ||
                    newPasswordController.text.isEmpty ||
                    confirmPasswordController.text.isEmpty) {
                  return;
                }
                
                if (newPasswordController.text.length < 8) {
                  ScaffoldMessenger.of(scaffoldContext).showSnackBar(
                    const SnackBar(content: Text('Password must be at least 8 characters!')),
                  );
                  return;
                }
                
                if (newPasswordController.text != confirmPasswordController.text) {
                  ScaffoldMessenger.of(scaffoldContext).showSnackBar(
                    const SnackBar(content: Text('Passwords don\'t match!')),
                  );
                  return;
                }
                
                // Update password in Firebase
                try {
                  final user = FirebaseAuth.instance.currentUser;
                  if (user != null) {
                    // Reauthenticate user with current password
                    final credential = EmailAuthProvider.credential(
                      email: user.email ?? '',
                      password: currentPasswordController.text,
                    );
                    
                    await user.reauthenticateWithCredential(credential);
                    
                    // Update password
                    await user.updatePassword(newPasswordController.text);
                    
                    if (mounted) {
                      Navigator.pop(scaffoldContext);
                      ScaffoldMessenger.of(scaffoldContext).showSnackBar(
                        const SnackBar(
                          content: Row(
                            children: [
                              Icon(Icons.check_circle, color: Colors.white),
                              SizedBox(width: 8),
                              Expanded(child: Text('Password changed successfully!')),
                            ],
                          ),
                          backgroundColor: Colors.green,
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  }
                } on FirebaseAuthException catch (e) {
                  if (mounted) {
                    String errorMessage = 'An error occurred';
                    if (e.code == 'wrong-password') {
                      errorMessage = 'Current password is incorrect!';
                    } else if (e.code == 'weak-password') {
                      errorMessage = 'New password is too weak!';
                    }
                    ScaffoldMessenger.of(scaffoldContext).showSnackBar(
                      SnackBar(content: Text(errorMessage)),
                    );
                  }
                }
              },
              child: const Text('Update Password'),
            ),
          ],
        ),
      ),
    );
  }
}

