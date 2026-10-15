import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/cat_sighting_model.dart';
import '../../providers/cat_sighting_providers.dart';
import '../widgets/cat_detail_sheet.dart';

class CatListScreen extends ConsumerWidget {
  const CatListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sightingsAsync = ref.watch(catSightingsListProvider);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Cats on the map')),
      body: sightingsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Could not load cats: $error',
              textAlign: TextAlign.center,
            ),
          ),
        ),
        data: (sightings) {
          if (sightings.isEmpty) {
            return const Center(child: Text('No cat sightings yet.'));
          }
          return RefreshIndicator(
            onRefresh: () =>
                ref.read(catSightingsListProvider.notifier).refresh(),
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              itemCount: sightings.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final sighting = sightings[index];
                return _CatListCard(
                  sighting: sighting,
                  scheme: scheme,
                  theme: theme,
                  onTap: () => CatDetailSheet.show(context, sighting),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _CatListCard extends StatelessWidget {
  final CatSighting sighting;
  final ColorScheme scheme;
  final ThemeData theme;
  final VoidCallback onTap;

  const _CatListCard({
    required this.sighting,
    required this.scheme,
    required this.theme,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final uploader = sighting.uploaderName?.isNotEmpty == true
        ? sighting.uploaderName!
        : 'Cat lover';
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: SizedBox(
                  width: 92,
                  height: 92,
                  child: CachedNetworkImage(
                    imageUrl: sighting.photoUrl,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => ColoredBox(
                      color: scheme.primaryContainer,
                      child: Icon(Icons.pets_rounded, color: scheme.secondary),
                    ),
                    errorWidget: (_, __, ___) => ColoredBox(
                      color: scheme.primaryContainer,
                      child: Icon(Icons.pets_rounded, color: scheme.secondary),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(sighting.name, style: theme.textTheme.titleMedium),
                    const SizedBox(height: 8),
                    _InfoRow(
                      icon: Icons.pets_rounded,
                      text: 'Breed: ${sighting.catType}',
                    ),
                    const SizedBox(height: 4),
                    _InfoRow(
                      icon: Icons.person_outline_rounded,
                      text: 'Uploaded by $uploader',
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: scheme.outline),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(icon, size: 16, color: scheme.secondary),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      ],
    );
  }
}
