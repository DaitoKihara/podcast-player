import 'package:flutter/material.dart';

import '../../../data/datasources/local/app_database.dart';
import '../../../data/repositories/user_preference_repository.dart';

/// Settings screen with sync toggle and other configuration options.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final UserPreferenceRepository _prefsRepository = UserPreferenceRepository();
  UserPreference? _prefs;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await _prefsRepository.getOrCreatePreferences();
    setState(() {
      _prefs = prefs;
      _isLoading = false;
    });
  }

  Future<void> _updateSyncEnabled(bool value) async {
    if (_prefs == null) return;
    setState(() {
      _prefs = _prefs!.copyWith(syncEnabled: value);
    });
    await _prefsRepository.updatePreferences(_prefs!);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Settings')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final prefs = _prefs!;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          // Sync Section
          const _SectionHeader(title: 'Sync'),
          SwitchListTile(
            title: const Text('Cross-device sync'),
            subtitle: const Text(
              'Sync subscriptions and playback positions across devices',
            ),
            value: prefs.syncEnabled,
            onChanged: _updateSyncEnabled,
            secondary: const Icon(Icons.sync),
          ),
          if (prefs.syncEnabled) ...[
            const ListTile(
              leading: Icon(Icons.info_outline),
              title: Text('Sync requires Google Sign-In'),
              subtitle: Text('v2 feature — coming soon'),
            ),
          ],
          const Divider(),

          // Playback Section
          const _SectionHeader(title: 'Playback'),
          ListTile(
            title: const Text('Skip forward'),
            subtitle: Text('${prefs.skipForwardInterval} seconds'),
            leading: const Icon(Icons.skip_next),
            onTap: () {
              // v2: Show dialog to adjust skip interval
            },
          ),
          ListTile(
            title: const Text('Skip backward'),
            subtitle: Text('${prefs.skipBackwardInterval} seconds'),
            leading: const Icon(Icons.skip_previous),
            onTap: () {
              // v2: Show dialog to adjust skip interval
            },
          ),
          ListTile(
            title: const Text('Playback speed'),
            subtitle: Text('${prefs.defaultPlaybackSpeed}x'),
            leading: const Icon(Icons.speed),
            onTap: () {
              // v2: Show speed picker dialog
            },
          ),
          const Divider(),

          // Download Section
          const _SectionHeader(title: 'Download'),
          SwitchListTile(
            title: const Text('Wi-Fi only download'),
            subtitle: const Text('Only download episodes when connected to Wi-Fi'),
            value: prefs.downloadOnlyOnWifi,
            onChanged: (value) {
              setState(() {
                _prefs = _prefs!.copyWith(downloadOnlyOnWifi: value);
              });
              _prefsRepository.updatePreferences(_prefs!);
            },
            secondary: const Icon(Icons.wifi),
          ),
          SwitchListTile(
            title: const Text('Auto-download'),
            subtitle: const Text('Automatically download new episodes'),
            value: prefs.autoDownload,
            onChanged: (value) {
              setState(() {
                _prefs = _prefs!.copyWith(autoDownload: value);
              });
              _prefsRepository.updatePreferences(_prefs!);
            },
            secondary: const Icon(Icons.download),
          ),
          const Divider(),

          // Appearance Section
          const _SectionHeader(title: 'Appearance'),
          SwitchListTile(
            title: const Text('Dark mode'),
            subtitle: const Text('Use dark theme'),
            value: prefs.darkMode,
            onChanged: (value) {
              setState(() {
                _prefs = _prefs!.copyWith(darkMode: value);
              });
              _prefsRepository.updatePreferences(_prefs!);
            },
            secondary: const Icon(Icons.dark_mode),
          ),
          ListTile(
            title: const Text('Font size'),
            subtitle: Text('${prefs.fontSize}x'),
            leading: const Icon(Icons.text_fields),
            onTap: () {
              // v2: Show font size slider dialog
            },
          ),
          const Divider(),

          // Auth Section
          const _SectionHeader(title: 'Account'),
          ListTile(
            title: const Text('Sign in'),
            subtitle: const Text('Sign in with Google to enable sync'),
            leading: const Icon(Icons.account_circle),
            onTap: () {
              // v2: Navigate to AuthScreen
            },
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}
