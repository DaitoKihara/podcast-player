import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/datasources/local/app_database.dart';
import '../../../presentation/providers/player_provider.dart';

/// Settings screen with sync toggle and other configuration options.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefsAsync = ref.watch(userPreferenceProvider);

    return prefsAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('Settings')),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, stackTrace) => Scaffold(
        appBar: AppBar(title: const Text('Settings')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: Theme.of(context).colorScheme.error),
              const SizedBox(height: 16),
              Text('Failed to load settings', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Text(error.toString(), style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => ref.invalidate(userPreferenceProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
      data: (prefs) {
        return _SettingsContent(prefs: prefs);
      },
    );
  }
}

class _SettingsContent extends ConsumerWidget {
  const _SettingsContent({required this.prefs});

  final UserPreference prefs;

  Future<void> _updatePreference(
    WidgetRef ref, {
    required UserPreference Function(UserPreference) update,
  }) async {
    final updated = update(prefs);
    final messenger = ScaffoldMessenger.of(ref.context);
    final repository = ref.read(userPreferenceRepositoryProvider);
    try {
      await repository.updatePreferences(updated);
      ref.invalidate(userPreferenceProvider);
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Failed to save: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
              ref,
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
            onTap: () => _showSkipIntervalDialog(ref, isForward: true),
          ),
          ListTile(
            title: const Text('Skip backward'),
            subtitle: Text('${prefs.skipBackwardInterval} seconds'),
            leading: const Icon(Icons.skip_previous),
            onTap: () => _showSkipIntervalDialog(ref, isForward: false),
          ),
          ListTile(
            title: const Text('Playback speed'),
            subtitle: Text('${prefs.defaultPlaybackSpeed}x'),
            leading: const Icon(Icons.speed),
            onTap: () => _showPlaybackSpeedDialog(ref),
          ),
          const Divider(),

          // Download Section
          const _SectionHeader(title: 'Download'),
          SwitchListTile(
            title: const Text('Wi-Fi only download'),
            subtitle: const Text('Only download episodes when connected to Wi-Fi'),
            value: prefs.downloadOnlyOnWifi,
            onChanged: (value) => _updatePreference(
              ref,
              update: (p) => p.copyWith(downloadOnlyOnWifi: value),
            ),
            secondary: const Icon(Icons.wifi),
          ),
          SwitchListTile(
            title: const Text('Auto-download'),
            subtitle: const Text('Automatically download new episodes'),
            value: prefs.autoDownload,
            onChanged: (value) => _updatePreference(
              ref,
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
              ref,
              update: (p) => p.copyWith(darkMode: value),
            ),
            secondary: const Icon(Icons.dark_mode),
          ),
          ListTile(
            title: const Text('Font size'),
            subtitle: Text('${prefs.fontSize}x'),
            leading: const Icon(Icons.text_fields),
            onTap: () => _showFontSizeDialog(ref),
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

  Future<void> _showSkipIntervalDialog(WidgetRef ref, {required bool isForward}) async {
    final current = isForward ? prefs.skipForwardInterval : prefs.skipBackwardInterval;
    final options = [5, 10, 15, 30, 45, 60];

    final selected = await showDialog<int>(
      context: ref.context,
      builder: (context) => SimpleDialog(
        title: Text(isForward ? 'Skip forward interval' : 'Skip backward interval'),
        children: [
          RadioGroup<int>(
            groupValue: current,
            onChanged: (v) => Navigator.of(context).pop(v),
            child: Column(
              children: [
                for (final sec in options)
                  RadioListTile<int>(
                    title: Text('$sec seconds'),
                    value: sec,
                  ),
              ],
            ),
          ),
        ],
      ),
    );

    if (selected != null) {
      if (isForward) {
        await _updatePreference(ref, update: (p) => p.copyWith(skipForwardInterval: selected));
      } else {
        await _updatePreference(ref, update: (p) => p.copyWith(skipBackwardInterval: selected));
      }
    }
  }

  Future<void> _showPlaybackSpeedDialog(WidgetRef ref) async {
    final current = prefs.defaultPlaybackSpeed;
    final options = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0, 3.0];

    final selected = await showDialog<double>(
      context: ref.context,
      builder: (context) => SimpleDialog(
        title: const Text('Playback speed'),
        children: [
          RadioGroup<double>(
            groupValue: current,
            onChanged: (v) => Navigator.of(context).pop(v),
            child: Column(
              children: [
                for (final speed in options)
                  RadioListTile<double>(
                    title: Text('${speed}x${speed == current ? ' (current)' : ''}'),
                    value: speed,
                  ),
              ],
            ),
          ),
        ],
      ),
    );

    if (selected != null) {
      await _updatePreference(ref, update: (p) => p.copyWith(defaultPlaybackSpeed: selected));
    }
  }

  Future<void> _showFontSizeDialog(WidgetRef ref) async {
    final current = prefs.fontSize;
    final options = [0.8, 0.9, 1.0, 1.1, 1.2, 1.3, 1.5];

    final selected = await showDialog<double>(
      context: ref.context,
      builder: (context) => SimpleDialog(
        title: const Text('Font size'),
        children: [
          RadioGroup<double>(
            groupValue: current,
            onChanged: (v) => Navigator.of(context).pop(v),
            child: Column(
              children: [
                for (final size in options)
                  RadioListTile<double>(
                    title: Text('${size}x${size == current ? ' (current)' : ''}'),
                    value: size,
                  ),
              ],
            ),
          ),
        ],
      ),
    );

    if (selected != null) {
      await _updatePreference(ref, update: (p) => p.copyWith(fontSize: selected));
    }
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
