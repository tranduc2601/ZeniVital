import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/localization.dart';
import '../../domain/models/exercise.dart';

class ExerciseDetailScreen extends StatelessWidget {
  final Exercise exercise;
  final VoidCallback onBack;

  const ExerciseDetailScreen({
    super.key,
    required this.exercise,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: const Color(0xFF16213E),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: onBack,
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: (exercise.gifUrl != null && exercise.gifUrl!.isNotEmpty)
                  ? CachedNetworkImage(
                      imageUrl: exercise.gifUrl!,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Image.asset('assets/exercise_placeholder.png', fit: BoxFit.cover, cacheWidth: 800),
                      errorWidget: (context, url, error) => Image.asset('assets/exercise_placeholder.png', fit: BoxFit.cover, cacheWidth: 800),
                    )
                  : exercise.imageUrl.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: exercise.imageUrl,
                          memCacheWidth: 800,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Image.asset('assets/exercise_placeholder.png', fit: BoxFit.cover, cacheWidth: 800),
                          errorWidget: (context, url, error) => Image.asset('assets/exercise_placeholder.png', fit: BoxFit.cover, cacheWidth: 800),
                        )
                  : Container(
                      color: const Color(0xFF16213E),
                      child: const Center(
                        child: Icon(Icons.fitness_center, size: 80, color: Colors.white24),
                      ),
                    ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exercise.name.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _chip('${AppLocalizations.get('target')}: ${exercise.targetMuscle}', const Color(0xFFE94560)),
                      _chip('${AppLocalizations.get('equipment')}: ${exercise.equipment}', const Color(0xFF0F3460)),
                      _chip('${AppLocalizations.get('level')}: ${exercise.difficulty}', const Color(0xFF16213E)),
                    ],
                  ),

                  if (exercise.images.length > 1) ...[
                    const SizedBox(height: 24),
                    Text(
                      AppLocalizations.get('exercise_images'),
                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 180,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: exercise.images.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 12),
                        itemBuilder: (context, index) {
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: CachedNetworkImage(
                              imageUrl: exercise.images[index],
                              width: 240,
                              memCacheWidth: 480,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Image.asset('assets/exercise_placeholder.png', width: 240, fit: BoxFit.cover, cacheWidth: 480),
                              errorWidget: (context, url, error) => Image.asset('assets/exercise_placeholder.png', width: 240, fit: BoxFit.cover, cacheWidth: 480),
                            ),
                          );
                        },
                      ),
                    ),
                  ],

                  if (exercise.description.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Text(
                      AppLocalizations.get('description'),
                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      exercise.description,
                      style: const TextStyle(color: Colors.white70, fontSize: 15, height: 1.5),
                    ),
                  ],

                  if (exercise.steps.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Text(
                      AppLocalizations.get('how_to_perform'),
                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 16),
                    ...exercise.steps.asMap().entries.map(
                      (entry) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 28,
                              height: 28,
                              decoration: const BoxDecoration(
                                color: Color(0xFFE94560),
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                '${entry.key + 1}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  entry.value,
                                  style: const TextStyle(color: Colors.white70, fontSize: 15, height: 1.4),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white24),
      ),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
      ),
    );
  }
}
