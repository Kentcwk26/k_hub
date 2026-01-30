import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/language_provider.dart';
import '../services/language_service.dart';
import '../utils/snackbar_helper.dart';
import '../repositories/user_repository.dart';
import '../models/user.dart';
import '../utils/image_responsive.dart';
import '../widgets/color_picker.dart';
import 'about.dart';
import 'profile.dart';
import '../providers/theme_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {

  final UserRepository _userRepository = UserRepository();
  AppUsers? _user;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final u = await _userRepository.getCurrentUser();
    setState(() {
      _user = u;
      loading = false;
    });
  }

  void _showResetDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("resetAllData".tr()),
        content: Text(
          'This will delete all your creations and reset all settings. This action cannot be undone.'.tr(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'.tr()),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              SnackBarHelper.showError(context, 'All data has been reset'.tr());
            },
            child: Text(
              "resetAllData".tr(),
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("settings".tr()),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : _user == null
          ? Center(child: Text("User not found".tr()))
          : SafeArea(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 20),
                children: [
                  _buildProfileHeader(),
                  const SizedBox(height: 30),
                  _sectionTitle("account".tr()),
                  _item(
                    icon: Icons.person,
                    title: "profile".tr(),
                    onTap: () => _openEditProfile(),
                  ),

                  _buildSectionHeader("appearance".tr()),
                  _buildThemeSection(ref),
                  _buildLanguageSection(ref),

                  _buildSectionHeader("support".tr()),
                  _buildSettingItem(
                    "faq".tr(),
                    Icons.help,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => FAQScreen()),
                    ),
                  ),
                  _buildSettingItem(
                    "contactUs".tr(),
                    Icons.email,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => ContactScreen()),
                    ),
                  ),
                  _buildSettingItem(
                    "rateApp".tr(),
                    Icons.star,
                    onTap: () async {
                      const url = 'https://docs.google.com/forms/d/e/1FAIpQLSeCtyveoWlfjwtXbBwUufZLHqUlSgDCp-9QiPHIXR7lmb7uvQ/viewform?usp=header';
                      final uri = Uri.parse(url);

                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri);
                      } else {
                        if (context.mounted) {
                          SnackBarHelper.showError(
                            context,
                            "Cannot open the link".tr(),
                          );
                        }
                      }
                    },
                  ),
                  _buildSettingItem(
                    "shareApp".tr(),
                    Icons.share,
                    onTap: () {
                      _showShareDialog(context);
                    },
                  ),

                  _buildSectionHeader("about".tr()),
                  _buildSettingItem(
                    "aboutKHub".tr(),
                    Icons.info,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => AboutScreen()),
                      );
                    },
                  ),
                  _buildSettingItem(
                    "privacyPolicy".tr(),
                    Icons.privacy_tip,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => PrivacyPolicyScreen()),
                    ),
                  ),
                  _buildSettingItem(
                    "termsOfService".tr(),
                    Icons.description,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => TermsOfServiceScreen()),
                    ),
                  ),

                  _buildSectionHeader("dangerZone".tr()),
                  _buildDangerItem(
                    "resetAllData".tr(),
                    Icons.warning,
                    onTap: _showResetDialog,
                  ),
                  _buildDangerItem(
                    "deleteAccount".tr(),
                    Icons.delete_forever,
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text('${"deleteAccount".tr()}?'),
                          content: Text(
                            'This will permanently delete your account and all your data. This action cannot be undone.'.tr(),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: Text('cancel'.tr()),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                SnackBarHelper.showError(context, 'Account deletion requested'.tr());
                              },
                              child: Text(
                                "deleteAccount".tr(),
                                style: const TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 20),
                  Center(
                    child: Text(
                      '${"appVersion".tr()} v1.0.0',
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }

  Widget _buildProfileHeader() {
    return Column(
      children: [
        GestureDetector(
          onTap: () => showDialog(
            context: context,
            builder: (_) => Dialog(
              backgroundColor: Colors.black,
              child: ResponsiveZoomableImage(
                imagePath: _user!.photoUrl.isNotEmpty
                    ? _user!.photoUrl
                    : 'assets/images/defaultprofile.jpg',
                padding: EdgeInsets.zero,
              ),
            ),
          ),
          child: SafeAvatar(url: _user!.photoUrl, size: 100),
        ),
        const SizedBox(height: 12),
        Text(
          _user!.name,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _item({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: onTap,
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
    );
  }

  Future<void> _openEditProfile() async {
    final updated = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EditProfileScreen(user: _user!)),
    );

    if (updated == true) {
      _loadUser();
    }
  }

  void _showShareDialog(BuildContext context) {
    const shareUrl = 'https://test-92558.web.app/';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${"shareApp".tr()} K-Hub'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Share this app with your friends:'.tr(),
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      shareUrl,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.blue,
                        overflow: TextOverflow.ellipsis,
                      ),
                      maxLines: 1,
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () async {
                      await _copyToClipboard(shareUrl, context);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(
                        Icons.copy,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
        actions: [
          // Open URL button
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await launchUrl(Uri.parse(shareUrl));
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.open_in_browser, size: 18),
                const SizedBox(width: 4),
                Text('Open Page'.tr()),
              ],
            ),
          ),

          // Close button
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Close'.tr(),
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _copyToClipboard(String text, BuildContext context) async {
    try {
      await Clipboard.setData(ClipboardData(text: text));
      if (context.mounted) {
        SnackBarHelper.showSuccess(context, 'Copied to clipboard!'.tr());
      }
    } catch (e) {
      if (context.mounted) {
        SnackBarHelper.showError(context, 'Failed to copy to clipboard'.tr());
      }
    }
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildSettingItem(
    String title,
    IconData icon, {
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
    Color? textColor,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title, style: TextStyle(color: textColor)),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: trailing,
      onTap: onTap,
    );
  }

  Widget _buildDangerItem(String title, IconData icon, {VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: Colors.red),
      title: Text(
        title,
        style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
      ),
      onTap: onTap,
    );
  }

  Widget _buildLanguageSection(WidgetRef ref) {
    final languageState = ref.watch(languageProvider);

    return _buildSettingItem(
      "language".tr(),
      Icons.language,
      trailing: DropdownButton<String>(
        value: languageState.locale.languageCode,
        underline: const SizedBox(),
        onChanged: (value) async {
          if (value != null) {
            final newLocale = Locale(value);
            final languageNotifier = ref.read(languageProvider.notifier);
            await languageNotifier.changeLanguage(newLocale, context);
          }
        },
        items: LanguageService.supportedLanguages.entries.map((entry) {
          return DropdownMenuItem(value: entry.key, child: Text(entry.value));
        }).toList(),
      ),
    );
  }

  Widget _buildThemeSection(WidgetRef ref) {
    final themeState = ref.watch(themeProvider);
    final themeNotifier = ref.read(themeProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSettingItem(
          "theme".tr(),
          Icons.color_lens,
          trailing: DropdownButton<String>(
            value: themeState.themeName,
            onChanged: (value) {
              if (value != null) {
                themeNotifier.changeTheme(value);
              }
            },
            items: [
              DropdownMenuItem(
                value: 'Default',
                child: Text('defaultGold'.tr()),
              ),
              DropdownMenuItem(value: 'Pink', child: Text('pink'.tr())),
              DropdownMenuItem(value: 'Purple', child: Text('purple'.tr())),
              DropdownMenuItem(value: 'Blue', child: Text('blue'.tr())),
              DropdownMenuItem(value: 'Green', child: Text('green'.tr())),
              DropdownMenuItem(
                value: 'Custom',
                child: Text('Custom Colors'.tr()),
              ),
            ],
          ),
        ),

        if (themeState.themeName == 'Custom') ...[
          const SizedBox(height: 8),
          _buildSettingItem(
            'Primary Color'.tr(),
            Icons.palette,
            subtitle: 'Buttons, accents'.tr(),
            onTap: () {
              _showColorPickerDialog(context, themeState.primaryColor, (color) {
                themeNotifier.setCustomColors(
                  color,
                  themeState.secondaryColor,
                  themeState.scaffoldBackgroundColor,
                  themeState.appBarColor,
                );
              });
            },
            trailing: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: themeState.primaryColor,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey),
              ),
            ),
          ),
          _buildSettingItem(
            'Secondary Color'.tr(),
            Icons.palette_outlined,
            subtitle: 'Secondary elements'.tr(),
            onTap: () {
              _showColorPickerDialog(context, themeState.secondaryColor, (
                color,
              ) {
                themeNotifier.setCustomColors(
                  themeState.primaryColor,
                  color,
                  themeState.scaffoldBackgroundColor,
                  themeState.appBarColor,
                );
              });
            },
            trailing: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: themeState.secondaryColor,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey),
              ),
            ),
          ),
          _buildSettingItem(
            'App Bar Color'.tr(),
            Icons.vertical_split,
            subtitle: 'Top app bar background'.tr(),
            onTap: () {
              _showColorPickerDialog(context, themeState.appBarColor, (color) {
                themeNotifier.setCustomColors(
                  themeState.primaryColor,
                  themeState.secondaryColor,
                  themeState.scaffoldBackgroundColor,
                  color,
                );
              });
            },
            trailing: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: themeState.appBarColor,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey),
              ),
            ),
          ),
          _buildSettingItem(
            'Background Color'.tr(),
            Icons.format_paint,
            subtitle: 'Screen background'.tr(),
            onTap: () {
              _showColorPickerDialog(
                context,
                themeState.scaffoldBackgroundColor,
                (color) {
                  themeNotifier.setCustomColors(
                    themeState.primaryColor,
                    themeState.secondaryColor,
                    color,
                    themeState.appBarColor,
                  );
                },
              );
            },
            trailing: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: themeState.scaffoldBackgroundColor,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey),
              ),
            ),
          ),
        ],
      ],
    );
  }

  void _showColorPickerDialog(
    BuildContext context,
    Color currentColor,
    Function(Color) onColorSelected,
  ) {
    showDialog(
      context: context,
      builder: (context) => ColorPickerDialog(
        currentColor: currentColor,
        onColorSelected: onColorSelected,
      ),
    );
  }
}