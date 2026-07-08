import 'package:flutter/material.dart';
import '../../core/localization.dart';
import '../../domain/models/exercise.dart';
import '../../domain/models/routine.dart';
import '../../data/api/local_database.dart';
import '../../data/api/static_data.dart';

class RoutineBuilderScreen extends StatefulWidget {
  final VoidCallback onSave;
  final VoidCallback onBack;

  const RoutineBuilderScreen({
    super.key,
    required this.onSave,
    required this.onBack,
  });

  @override
  State<RoutineBuilderScreen> createState() => _RoutineBuilderScreenState();
}

class _RoutineBuilderScreenState extends State<RoutineBuilderScreen> {
  final _nameCtrl = TextEditingController();
  final List<RoutineSlot> _slots = [];

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  void _addExercise(Exercise ex) {
    setState(() {
      _slots.add(RoutineSlot(
        exerciseId: ex.id,
        exerciseName: ex.name,
        muscle: ex.targetMuscle,
        sets: 3,
        reps: 10,
        restSeconds: 60,
      ));
    });
  }

  void _removeSlot(int index) {
    setState(() {
      _slots.removeAt(index);
    });
  }

  void _updateSlot(int index, {int? sets, int? reps, int? rest}) {
    setState(() {
      final old = _slots[index];
      _slots[index] = RoutineSlot(
        exerciseId: old.exerciseId,
        exerciseName: old.exerciseName,
        muscle: old.muscle,
        sets: sets ?? old.sets,
        reps: reps ?? old.reps,
        restSeconds: rest ?? old.restSeconds,
      );
    });
  }

  void _saveRoutine() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty || _slots.isEmpty) return;

    final routine = Routine(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      slots: _slots,
      isCustom: true,
    );

    await LocalDatabase.instance.saveCustomRoutine(routine);
    widget.onSave();
  }

  void _showExercisePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF16213E),
      isScrollControlled: true,
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          maxChildSize: 0.9,
          expand: false,
          builder: (ctx, controller) {
            return ListView.builder(
              controller: controller,
              itemCount: StaticData.exercises.length,
              itemBuilder: (ctx, i) {
                final ex = StaticData.exercises[i];
                return ListTile(
                  title: Text(ex.name, style: const TextStyle(color: Colors.white)),
                  subtitle: Text(ex.targetMuscle, style: const TextStyle(color: Colors.white54)),
                  trailing: const Icon(Icons.add, color: Color(0xFFE94560)),
                  onTap: () {
                    _addExercise(ex);
                    Navigator.pop(ctx);
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          key: const Key('routine_builder_back_btn'),
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: widget.onBack,
        ),
        title: Text(AppLocalizations.get('new_routine'), style: TextStyle(color: Colors.white)),
        actions: [
          TextButton(
            onPressed: (_nameCtrl.text.trim().isNotEmpty && _slots.isNotEmpty) ? _saveRoutine : null,
            child: const Text('SAVE', style: TextStyle(color: Color(0xFFE94560), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _nameCtrl,
              style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
              decoration: const InputDecoration(
                hintText: 'Routine Name',
                hintStyle: TextStyle(color: Colors.white38),
                border: InputBorder.none,
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
          Expanded(
            child: _slots.isEmpty
                ? const Center(
                    child: Text('No exercises added yet.', style: TextStyle(color: Colors.white54)),
                  )
                : ListView.builder(
                    itemCount: _slots.length,
                    itemBuilder: (ctx, i) {
                      final slot = _slots[i];
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF16213E),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(slot.exerciseName, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                                  onPressed: () => _removeSlot(i),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                _NumberAdjuster(
                                  label: 'Sets',
                                  value: slot.sets,
                                  onChanged: (v) => _updateSlot(i, sets: v),
                                ),
                                const SizedBox(width: 16),
                                _NumberAdjuster(
                                  label: 'Reps',
                                  value: slot.reps,
                                  onChanged: (v) => _updateSlot(i, reps: v),
                                ),
                                const SizedBox(width: 16),
                                _NumberAdjuster(
                                  label: 'Rest (s)',
                                  value: slot.restSeconds,
                                  step: 15,
                                  onChanged: (v) => _updateSlot(i, rest: v),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFE94560),
        onPressed: _showExercisePicker,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class _NumberAdjuster extends StatelessWidget {
  final String label;
  final int value;
  final int step;
  final ValueChanged<int> onChanged;

  const _NumberAdjuster({
    required this.label,
    required this.value,
    this.step = 1,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12)),
        Row(
          children: [
            GestureDetector(
              onTap: () {
                if (value > step) onChanged(value - step);
              },
              child: const Icon(Icons.remove_circle_outline, color: Colors.white54, size: 20),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text('$value', style: const TextStyle(color: Colors.white, fontSize: 16)),
            ),
            GestureDetector(
              onTap: () => onChanged(value + step),
              child: const Icon(Icons.add_circle_outline, color: Colors.white54, size: 20),
            ),
          ],
        ),
      ],
    );
  }
}
