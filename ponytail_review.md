# Ponytail Review

pubspec.yaml:L16: native: cached_network_image dependency. FadeInImage.assetNetwork, 0 deps.

lib/data/models/exercise_model.dart:L1-33: yagni: ExerciseModel wrapper doing nothing but calling super. Delete file, use Exercise directly.

lib/domain/repositories/exercise_repository.dart:L1-6: yagni: AbstractRepository with one implementation. Inline it.

lib/data/repositories/exercise_repository_impl.dart:L6-30: yagni: Repository pattern for a single HTTP GET. One fetch function returning List<Exercise>.

lib/presentation/screens/main_tabs.dart:L121-128: native: CachedNetworkImage imported. FadeInImage.assetNetwork.

lib/presentation/screens/main_tabs.dart:L287-313: shrink: 25-line manual streak loop with complex Date matching. DateUtils.dateOnly and a simple while loop.

lib/presentation/screens/main_tabs.dart:L566-599: native: CustomPainter for bar chart. Row with Flexible Containers.

lib/presentation/screens/exercise_detail_screen.dart:L31-44: native: CachedNetworkImage imported. FadeInImage.assetNetwork.

lib/presentation/screens/exercise_detail_screen.dart:L94-101: native: CachedNetworkImage imported. FadeInImage.assetNetwork.

lib/presentation/screens/exercise_list_screen.dart:L1-166: delete: entire screen and remote fetching layers duplicate the local ExploreScreen + StaticData. Pick one source of truth.

net: -250 lines possible.
