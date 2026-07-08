import 'package:flutter/material.dart';
import '../../data/api/local_database.dart';
import '../../domain/models/user.dart';
import '../../core/localization.dart';

class SettingsScreen extends StatefulWidget {
  final VoidCallback onSave;
  final VoidCallback onLogout;
  final VoidCallback onLocaleChanged;

  const SettingsScreen({
    super.key,
    required this.onSave,
    required this.onLogout,
    required this.onLocaleChanged,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _dropdownOpen = false;

  void _selectGoal(GoalType goal) {
    LocalDatabase.instance.updateGoal(goal);
    setState(() => _dropdownOpen = false);
  }

  void _toggleLanguage() async {
    final current = LocalDatabase.instance.getLocale();
    final next = current == 'en' ? 'vi' : 'en';
    await LocalDatabase.instance.setLocale(next);
    widget.onLocaleChanged();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF16213E),
        title: Text(AppLocalizations.get('settings'), style: const TextStyle(color: Colors.white)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppLocalizations.get('fitness_goal'), style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 8),
            ElevatedButton(
              key: const Key('goal_dropdown'),
              onPressed: () => setState(() => _dropdownOpen = !_dropdownOpen),
              child: const Text('Select Goal'),
            ),
            if (_dropdownOpen) ...[
              const SizedBox(height: 8),
              _GoalOption(
                label: AppLocalizations.get('weight_loss'),
                onTap: () => _selectGoal(GoalType.weightLoss),
              ),
              _GoalOption(
                label: AppLocalizations.get('conditioning'),
                onTap: () => _selectGoal(GoalType.conditioning),
              ),
              _GoalOption(
                label: AppLocalizations.get('bodybuilding'),
                onTap: () => _selectGoal(GoalType.bodybuilding),
              ),
            ],
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Language', style: TextStyle(color: Colors.white70)),
                ElevatedButton(
                  onPressed: _toggleLanguage,
                  child: Text(LocalDatabase.instance.getLocale() == 'en' ? 'English' : 'Tiếng Việt'),
                ),
              ],
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                key: const Key('settings_save_btn'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE94560),
                  foregroundColor: Colors.white,
                ),
                onPressed: widget.onSave,
                child: Text(AppLocalizations.get('save')),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                key: const Key('settings_logout_btn'),
                style: OutlinedButton.styleFrom(foregroundColor: Colors.white54),
                onPressed: widget.onLogout,
                child: Text(AppLocalizations.get('logout')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GoalOption extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _GoalOption({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(label, style: const TextStyle(color: Colors.white)),
      onTap: onTap,
    );
  }
}
