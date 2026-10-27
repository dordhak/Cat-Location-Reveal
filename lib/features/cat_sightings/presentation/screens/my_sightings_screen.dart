import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/providers/auth_provider.dart';
import '../../data/models/cat_sighting_model.dart';
import '../../providers/cat_sighting_providers.dart';
import '../widgets/cat_detail_sheet.dart';

class MySightingsScreen extends ConsumerStatefulWidget {
  const MySightingsScreen({super.key});

  @override
  ConsumerState<MySightingsScreen> createState() => _MySightingsScreenState();
}

class _MySightingsScreenState extends ConsumerState<MySightingsScreen> {
  late Future<List<CatSighting>> _sightings;

  @override
  void initState() {
    super.initState();
    _sightings = _load();
  }

  Future<List<CatSighting>> _load() {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) return Future.value(const []);
    return ref.read(catSightingRepositoryProvider).fetchUserSightings(userId);
  }

  Future<void> _refresh() async {
    setState(() => _sightings = _load());
    await _sightings;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My postings')),
      body: FutureBuilder<List<CatSighting>>(
        future: _sightings,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Could not load your postings: ${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          final sightings = snapshot.data ?? const <CatSighting>[];
          if (sightings.isEmpty) {
            return RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(
                children: const [
                  SizedBox(height: 180),
                  Center(child: Text('You have not posted any sightings yet.')),
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: sightings.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final sighting = sightings[index];
                return Card(
                  clipBehavior: Clip.antiAlias,
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(10),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: CachedNetworkImage(
                        imageUrl: sighting.photoUrl,
                        width: 64,
                        height: 64,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) =>
                            const Icon(Icons.pets_rounded),
                      ),
                    ),
                    title: Text(sighting.name),
                    subtitle: Text(
                      '${sighting.catType} • ${sighting.primaryColor}',
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () async {
                      await CatDetailSheet.show(context, sighting);
                      if (mounted) _refresh();
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
