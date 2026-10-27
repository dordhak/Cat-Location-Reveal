import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../auth/presentation/screens/auth_screen.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../data/models/cat_sighting_model.dart';
import '../../providers/cat_sighting_providers.dart';
import 'friendliness_rating_bar.dart';

class CatDetailSheet extends ConsumerWidget {
  final CatSighting sighting;

  const CatDetailSheet({super.key, required this.sighting});

  Future<void> _report(BuildContext context, WidgetRef ref) async {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) {
      final signedIn = await Navigator.of(context)
          .push<bool>(MaterialPageRoute(builder: (_) => const AuthScreen()));
      if (signedIn != true || !context.mounted) return;
    }

    if (!context.mounted) return;
    final result = await showDialog<({String reason, String? details})>(
      context: context,
      builder: (dialogContext) => const _ReportDialog(),
    );
    if (result == null || !context.mounted) return;

    try {
      await ref
          .read(catSightingRepositoryProvider)
          .submitReport(
            sightingId: sighting.id,
            reporterId: ref.read(currentUserIdProvider)!,
            reason: result.reason,
            details: result.details,
          );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Thanks. Your report was submitted.')),
        );
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.toString())));
      }
    }
  }

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete sighting?'),
        content: const Text('This removes your cat sighting permanently.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    try {
      await ref.read(catSightingRepositoryProvider).deleteSighting(sighting.id);
      ref.invalidate(catSightingsListProvider);
      if (context.mounted) Navigator.pop(context);
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.toString())));
      }
    }
  }

  static Future<void> show(BuildContext context, CatSighting sighting) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: false,
      backgroundColor: Colors.transparent,
      builder: (_) => CatDetailSheet(sighting: sighting),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: scheme.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: AspectRatio(
                  aspectRatio: 4 / 3,
                  child: CachedNetworkImage(
                    imageUrl: sighting.photoUrl,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => ColoredBox(
                      color: scheme.surface,
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                    errorWidget: (_, __, ___) => ColoredBox(
                      color: scheme.surface,
                      child: Icon(
                        Icons.pets_rounded,
                        size: 48,
                        color: scheme.outline,
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(6, 18, 6, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(sighting.name, style: theme.textTheme.headlineSmall),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _InfoPill(
                          icon: Icons.pets_rounded,
                          label: sighting.catType,
                        ),
                        _InfoPill(
                          icon: Icons.palette_outlined,
                          label: sighting.primaryColor,
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        FriendlinessRatingBar(
                          rating: sighting.friendlinessRating,
                          itemSize: 26,
                        ),
                        const SizedBox(width: 10),
                        Flexible(
                          child: Text(
                            friendlinessLabel(sighting.friendlinessRating),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: scheme.secondary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (sighting.description != null &&
                        sighting.description!.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: scheme.surface,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          sighting.description!,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: scheme.onSurface,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Icon(
                          Icons.schedule_rounded,
                          size: 18,
                          color: scheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _spottedLabel(sighting.createdAt),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: scheme.primaryContainer,
                          backgroundImage:
                              sighting.uploaderAvatarUrl != null &&
                                  sighting.uploaderAvatarUrl!.isNotEmpty
                              ? CachedNetworkImageProvider(
                                  sighting.uploaderAvatarUrl!,
                                )
                              : null,
                          child:
                              sighting.uploaderAvatarUrl == null ||
                                  sighting.uploaderAvatarUrl!.isEmpty
                              ? Icon(
                                  Icons.person_rounded,
                                  color: scheme.onPrimaryContainer,
                                )
                              : null,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Spotted by ${sighting.uploaderName?.isNotEmpty == true ? sighting.uploaderName : 'Cat lover'}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: scheme.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        OutlinedButton.icon(
                          onPressed: () => _report(context, ref),
                          icon: const Icon(Icons.flag_outlined),
                          label: const Text('Report'),
                        ),
                        if (ref.watch(currentUserIdProvider) ==
                            sighting.userId) ...[
                          const SizedBox(width: 10),
                          OutlinedButton.icon(
                            onPressed: () => _delete(context, ref),
                            icon: const Icon(Icons.delete_outline),
                            label: const Text('Delete'),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReportDialog extends StatefulWidget {
  const _ReportDialog();

  @override
  State<_ReportDialog> createState() => _ReportDialogState();
}

class _ReportDialogState extends State<_ReportDialog> {
  final _detailsController = TextEditingController();
  String _reason = 'inappropriate';

  @override
  void dispose() {
    _detailsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Report cat sighting'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Why are you reporting this posting?'),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _reason,
              decoration: const InputDecoration(labelText: 'Reason'),
              items: const [
                DropdownMenuItem(
                  value: 'inappropriate',
                  child: Text('Inappropriate content'),
                ),
                DropdownMenuItem(
                  value: 'harassment',
                  child: Text('Harassment'),
                ),
                DropdownMenuItem(value: 'bullying', child: Text('Bullying')),
              ],
              onChanged: (value) {
                if (value != null) setState(() => _reason = value);
              },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _detailsController,
              maxLines: 3,
              maxLength: 500,
              decoration: const InputDecoration(
                labelText: 'Additional details (optional)',
                alignLabelWithHint: true,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, (
            reason: _reason,
            details: _detailsController.text.trim().isEmpty
                ? null
                : _detailsController.text.trim(),
          )),
          child: const Text('Submit report'),
        ),
      ],
    );
  }
}

/// Supabase returns UTC timestamps, so convert to the phone's local time.
String _spottedLabel(DateTime createdAt) {
  final local = createdAt.toLocal();
  final diff = DateTime.now().difference(local);

  if (diff.inMinutes < 1) return 'Spotted just now';
  if (diff.inMinutes < 60) return 'Spotted ${diff.inMinutes} min ago';
  if (diff.inHours < 24) {
    final h = diff.inHours;
    return 'Spotted $h ${h == 1 ? 'hour' : 'hours'} ago';
  }
  if (diff.inDays < 7) {
    final d = diff.inDays;
    return 'Spotted $d ${d == 1 ? 'day' : 'days'} ago';
  }
  return 'Spotted on ${DateFormat('d MMM yyyy').format(local)}';
}

class _InfoPill extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoPill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: scheme.secondary),
            const SizedBox(width: 6),
            Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
