import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/datasources/local/app_database.dart';
import '../../../presentation/providers/player_provider.dart';

/// Settings screen with sync toggle and other configuration options.
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  UserPreference? _prefs;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    try {
      final repository = ref.read(userPreferenceRepositoryProvider);
      final prefs = await repository.getOrCreatePreferences();
      if (!mounted) return;
      setState(() {
        _prefs = prefs;
        _isLoading = false;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  Future<void> _updatePreference({
    required UserPreference Function(UserPreference) update,
  }) async {
    final current = _prefs;
    if (current == null) return;
    final updated = update(current);
    setState(() {
      _prefs = updated;
    });
    try {
      final repository = ref.read(userPreferenceRepositoryProvider);
      await repository.updatePreferences(updated);
    } catch (e) {
      if (!mounted) return;
      // Revert on failure
      setState(() {
        _prefs = current;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Settings')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Settings')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Failed to load settings', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Text(_error!, style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () {
                  setState(() {
                    _isLoading = true;
                    _error = null;
                  });
                  _loadPreferences();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
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
            onChanged: (value) => _updatePreference(
              update: (p) => p.copyWith(syncEnabled: value),
            ),
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
            onChanged: (value) => _updatePreference(
              update: (p) => p.copyWith(downloadOnlyOnWifi: value),
            ),
            secondary: const Icon(Icons.wifi),
          ),
          SwitchListTile(
            title: const Text('Auto-download'),
            subtitle: const Text('Automatically download new episodes'),
            value: prefs.autoDownload,
            onChanged: (value) => _updatePreference(
              update: (p) => p.copyWith(autoDownload: value),
            ),
            secondary: const Icon(Icons.download),
          ),
          const Divider(),

          // Appearance Section
          const _SectionHeader(title: 'Appearance'),
          SwitchListTile(
            title: const Text('Dark mode'),
            subtitle: const Text('Use dark theme'),
            value: prefs.darkMode,
            onChanged: (value) => _updatePreference(
              update: (p) => p.copyWith(darkMode: value),
            ),
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
