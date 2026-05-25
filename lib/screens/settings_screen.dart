import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = true;
  bool _biometricEnabled = false;
  double _fontSize = 16.0;

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Settings', style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
      ),
      body: ListView(
        padding: EdgeInsets.all(AppConstants.defaultPadding),
        children: [
          // Account Section
          Text('ACCOUNT', style: TextStyle(color: AppColors.primary, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
          SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                _settingsTile(Icons.person_outline, 'Edit Profile', null, (){}),
                Divider(height: 1, color: Colors.white10, indent: 55),
                _settingsTile(Icons.lock_outline, 'Change Password', null, (){}),
                Divider(height: 1, color: Colors.white10, indent: 55),
                _settingsTile(Icons.email_outlined, 'Email Preferences', null, (){}),
              ],
            ),
          ),

          SizedBox(height: 25),

          // Appearance Section
          Text('APPEARANCE', style: TextStyle(color: AppColors.primary, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
          SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                _switchTile(Icons.dark_mode_outlined, 'Dark Mode', _darkModeEnabled, (val) {
                  setState(() => _darkModeEnabled = val);
                }),
                Divider(height: 1, color: Colors.white10, indent: 55),
                _sliderTile(Icons.text_fields, 'Font Size', _fontSize, (val) {
                  setState(() => _fontSize = val);
                }),
              ],
            ),
          ),

          SizedBox(height: 25),

          // Notifications Section
          Text('NOTIFICATIONS', style: TextStyle(color: AppColors.primary, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
          SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                _switchTile(Icons.notifications_active_outlined, 'Push Notifications', _notificationsEnabled, (val) {
                  setState(() => _notificationsEnabled = val);
                }),
                Divider(height: 1, color: Colors.white10, indent: 55),
                _switchTile(Icons.email_outlined, 'Email Notifications', true, (val){}),
                Divider(height: 1, color: Colors.white10, indent: 55),
                _switchTile(Icons.assignment_late_outlined, 'Reminder Alerts', true, (val){}),
              ],
            ),
          ),

          SizedBox(height: 25),

          // Security Section
          Text('SECURITY', style: TextStyle(color: AppColors.primary, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
          SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                _switchTile(Icons.fingerprint, 'Biometric Login', _biometricEnabled, (val) {
                  setState(() => _biometricEnabled = val);
                }),
                Divider(height: 1, color: Colors.white10, indent: 55),
                _settingsTile(Icons.privacy_tip_outlined, 'Privacy Policy', null, (){}),
                Divider(height: 1, color: Colors.white10, indent: 55),
                _settingsTile(Icons.description_outlined, 'Terms of Service', null, (){}),
              ],
            ),
          ),

          SizedBox(height: 25),

          // About Section
          Text('ABOUT', style: TextStyle(color: AppColors.primary, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
          SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                _settingsTile(Icons.info_outline, 'App Version', 'v1.0.0', (){}),
                Divider(height: 1, color: Colors.white10, indent: 55),
                _settingsTile(Icons.star_outline, 'Rate Us', null, (){}),
                Divider(height: 1, color: Colors.white10, indent: 55),
                _settingsTile(Icons.share_outlined, 'Share App', null, (){}),
              ],
            ),
          ),

          SizedBox(height: 30),

          // Danger Zone
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.error.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.error.withOpacity(0.3)),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: (){},
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.delete_forever, color: AppColors.error),
                  SizedBox(width: 10),
                  Text('Delete Account', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w600, fontSize: 15)),
                ],
              ),
            ),
          ),

          SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _settingsTile(IconData icon, String title, String? trailing, VoidCallback onTap) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      leading: Icon(icon, color: AppColors.textSecondary, size: 22),
      title: Text(title, style: TextStyle(color: AppColors.text, fontSize: 15)),
      trailing: trailing != null 
        ? Text(trailing, style: TextStyle(color: AppColors.textSecondary, fontSize: 14))
        : Icon(Icons.chevron_right, color: AppColors.textSecondary, size: 20),
      onTap: onTap,
    );
  }

  Widget _switchTile(IconData icon, String title, bool value, Function(bool) onChanged) {
    return SwitchListTile(
      secondary: Icon(icon, color: AppColors.textSecondary, size: 22),
      title: Text(title, style: TextStyle(color: AppColors.text, fontSize: 15)),
      subtitle: null,
      activeColor: AppColors.primary,
      value: value,
      onChanged: onChanged,
    );
  }

  Widget _sliderTile(IconData icon, String title, double value, Function(double) onChanged) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textSecondary, size: 22),
          SizedBox(width: 16),
          Expanded(child: Text(title, style: TextStyle(color: AppColors.text, fontSize: 15))),
          Text('${value.toInt()}px', style: TextStyle(color: AppColors.primary, fontSize: 13, fontWeight: FontWeight.w600),),
          SizedBox(width: 10),
          SizedBox(width: 120, child: SliderTheme(data: SliderThemeData(activeTrackColor: AppColors.primary, thumbColor: AppColors.primary, inactiveTrackColor: AppColors.card, overlayColor: AppColors.primary.withOpacity(0.2), trackHeight: 3,), child: Slider(min: 12, max: 24, divisions: 6, value: value, onChanged: onChanged))),
        ],
      ),
    );
  }
}