import 'package:flutter/material.dart';

/// A widget that displays an episode with management actions.
///
/// Features:
/// - Play indicator (icon when currently playing)
/// - Favorite toggle button (heart icon, filled/outline)
/// - Download button with progress indicator
/// - Long-press menu (mark played/unplayed)
/// - State indicators: isNew, isPlayed, isFavorite, isDownloaded
class EpisodeTile extends StatelessWidget {
  const EpisodeTile({
    super.key,
    required this.title,
    required this.duration,
    required this.publishDate,
    required this.isPlayed,
    required this.isFavorite,
    required this.isNew,
    required this.onTap,
    this.onFavoriteToggle,
    this.onMarkPlayed,
    this.onMarkUnplayed,
    this.onDownload,
    this.onDeleteDownload,
    this.isCurrentlyPlaying = false,
    this.localPath,
    this.downloadProgress,
  });

  final String title;
  final Duration duration;
  final DateTime publishDate;
  final bool isPlayed;
  final bool isFavorite;
  final bool isNew;
  final VoidCallback onTap;
  final VoidCallback? onFavoriteToggle;
  final VoidCallback? onMarkPlayed;
  final VoidCallback? onMarkUnplayed;
  final VoidCallback? onDownload;
  final VoidCallback? onDeleteDownload;
  final bool isCurrentlyPlaying;
  final String? localPath;
  final double? downloadProgress;

  bool get isDownloaded => localPath != null && localPath!.isNotEmpty;
  bool get isDownloading => downloadProgress != null;

  String get _formattedDuration {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }

  String get _formattedDate {
    final now = DateTime.now();
    final diff = now.difference(publishDate);
    if (diff.inDays == 0) {
      return 'Today';
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} days ago';
    } else {
      return '${publishDate.year}/${publishDate.month.toString().padLeft(2, '0')}/${publishDate.day.toString().padLeft(2, '0')}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isGreyedOut = isPlayed && !isCurrentlyPlaying;

    return ListTile(
      onTap: onTap,
      onLongPress: () => _showContextMenu(context),
      leading: _buildLeadingIcon(theme),
      title: Text(
        title,
        style: TextStyle(
          color: isGreyedOut ? theme.disabledColor : null,
          decoration: isGreyedOut ? TextDecoration.lineThrough : null,
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Row(
        children: [
          Text(_formattedDuration),
          const SizedBox(width: 8),
          Text(_formattedDate),
          if (isDownloading) ...[
            const SizedBox(width: 8),
            Expanded(
              child: LinearProgressIndicator(
                value: downloadProgress,
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
              ),
            ),
          ] else if (isNew && !isPlayed) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'NEW',
                style: TextStyle(
                  color: theme.colorScheme.onPrimary,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildDownloadButton(theme),
          if (onFavoriteToggle != null)
            IconButton(
              icon: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                color: isFavorite ? Colors.red : null,
              ),
              onPressed: onFavoriteToggle,
            ),
          if (isCurrentlyPlaying)
            Icon(
              Icons.graphic_eq,
              color: theme.colorScheme.primary,
            ),
        ],
      ),
    );
  }

  Widget _buildDownloadButton(ThemeData theme) {
    if (isDownloading) {
      return SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          value: downloadProgress,
          strokeWidth: 2,
        ),
      );
    }

    if (isDownloaded) {
      return IconButton(
        icon: Icon(
          Icons.download_done,
          color: theme.colorScheme.primary,
        ),
        onPressed: onDeleteDownload,
        tooltip: 'Delete download',
      );
    }

    if (onDownload != null) {
      return IconButton(
        icon: const Icon(Icons.download_outlined),
        onPressed: onDownload,
        tooltip: 'Download',
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildLeadingIcon(ThemeData theme) {
    if (isCurrentlyPlaying) {
      return Icon(
        Icons.play_circle_filled,
        color: theme.colorScheme.primary,
        size: 40,
      );
    }
    if (isPlayed) {
      return Icon(
        Icons.check_circle,
        color: theme.disabledColor,
        size: 40,
      );
    }
    return Icon(
      Icons.play_circle_outline,
      color: theme.colorScheme.primary,
      size: 40,
    );
  }

  void _showContextMenu(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (onMarkPlayed != null && !isPlayed)
              ListTile(
                leading: const Icon(Icons.check),
                title: const Text('Mark as Played'),
                onTap: () {
                  Navigator.pop(context);
                  onMarkPlayed!();
                },
              ),
            if (onMarkUnplayed != null && isPlayed)
              ListTile(
                leading: const Icon(Icons.undo),
                title: const Text('Mark as Unplayed'),
                onTap: () {
                  Navigator.pop(context);
                  onMarkUnplayed!();
                },
              ),
            if (onDownload != null && !isDownloaded && !isDownloading)
              ListTile(
                leading: const Icon(Icons.download),
                title: const Text('Download'),
                onTap: () {
                  Navigator.pop(context);
                  onDownload!();
                },
              ),
            if (onDeleteDownload != null && isDownloaded)
              ListTile(
                leading: const Icon(Icons.delete_outline),
                title: const Text('Delete Download'),
                onTap: () {
                  Navigator.pop(context);
                  onDeleteDownload!();
                },
              ),
          ],
        ),
      ),
    );
  }
}
