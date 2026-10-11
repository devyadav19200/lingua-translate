import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/speech_provider.dart';
import '../core/app_colors.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SectionHeader('Appearance'),
          _SettingsCard(
            children: [
              Consumer<ThemeProvider>(
                builder: (context, themeProvider, _) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                        child: Text(
                          'Theme Mode',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      ...[
                        _ThemeOption(
                          icon: Icons.phone_android_rounded,
                          label: 'System Default',
                          selected: themeProvider.isSystem,
                          onTap: () =>
                              themeProvider.setThemeMode(ThemeMode.system),
                        ),
                        _ThemeOption(
                          icon: Icons.light_mode_rounded,
                          label: 'Light Mode',
                          selected: themeProvider.isLight,
                          onTap: () =>
                              themeProvider.setThemeMode(ThemeMode.light),
                        ),
                        _ThemeOption(
                          icon: Icons.dark_mode_rounded,
                          label: 'Dark Mode',
                          selected: themeProvider.isDark,
                          onTap: () =>
                              themeProvider.setThemeMode(ThemeMode.dark),
                        ),
                      ],
                    ],
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
          _SectionHeader('Voice & Speech'),
          _SettingsCard(
            children: [
              Consumer<SpeechProvider>(
                builder: (context, speechProvider, _) {
                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Speech Rate',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.slow_motion_video_rounded,
                                size: 16, color: AppColors.primary),
                            Expanded(
                              child: Slider(
                                value: speechProvider.speechRate,
                                min: 0.1,
                                max: 1.0,
                                divisions: 9,
                                label:
                                    speechProvider.speechRate.toStringAsFixed(1),
                                activeColor: AppColors.primary,
                                onChanged: (v) =>
                                    speechProvider.setSpeechRate(v),
                              ),
                            ),
                            const Icon(Icons.fast_forward_rounded,
                                size: 16, color: AppColors.primary),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
          _SectionHeader('About'),
          _SettingsCard(
            children: [
              _SettingsRow(
                icon: Icons.info_outline_rounded,
                title: 'Version',
                trailing: const Text(
                  '1.0.0',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    color: AppColors.primary,
                  ),
                ),
              ),
              _SettingsRow(
                icon: Icons.translate_rounded,
                title: 'Translation Engine',
                trailing: const Text(
                  'MyMemory API',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    color: AppColors.primary,
                  ),
                ),
              ),
              _SettingsRow(
                icon: Icons.language_rounded,
                title: 'Supported Languages',
                trailing: Text(
                  '60+',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    color: AppColors.primary,
                  ),
                ),
              ),
              _SettingsRow(
                icon: Icons.privacy_tip_outline_rounded,
                title: 'Privacy',
                subtitle:
                    'Text is sent to MyMemory API for translation. No data is stored on our servers.',
                trailing: const SizedBox.shrink(),
              ),
            ],
          ),
          const SizedBox(height: 40),
          Center(
            child: Text(
              'Made with ❤️ using Flutter',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                color: isDark
                    ? AppColors.textSecondaryLight
                    : AppColors.textSecondaryDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
          color: AppColors.primary,
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;
  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ThemeOption({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Icon(
        icon,
        color: selected ? AppColors.primary : null,
      ),
      title: Text(
        label,
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 14,
          fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
          color: selected ? AppColors.primary : null,
        ),
      ),
      trailing: selected
          ? const Icon(Icons.check_circle_rounded, color: AppColors.primary)
          : const Icon(Icons.circle_outlined, color: Colors.grey),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget trailing;

  const _SettingsRow({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary, size: 22),
      title: Text(
        title,
        style: const TextStyle(fontFamily: 'Poppins', fontSize: 14),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: const TextStyle(fontFamily: 'Poppins', fontSize: 11),
            )
          : null,
      trailing: trailing,
    );
  }
}
