import 'package:flutter/material.dart';
import '../../core/localization.dart';
import '../../domain/models/user.dart';
import '../../data/api/local_database.dart';

class OnboardingScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const OnboardingScreen({super.key, required this.onComplete});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  GoalType _selectedGoal = GoalType.weightLoss;
  double? _height;
  double? _weight;
  int? _age;
  String _level = 'Beginner';
  int _preferredDuration = 45;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _finish() async {
    // Save chosen goal
    var user = LocalDatabase.instance.getUser();
    if (user != null) {
      user = user.copyWith(
        goal: _selectedGoal,
        height: _height,
        weight: _weight,
        age: _age,
        level: _level,
        preferredDuration: _preferredDuration,
      );
      await LocalDatabase.instance.saveUser(user);
    }
    widget.onComplete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        key: const Key('onboarding_pageview'),
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(), // Only navigate via buttons
        children: [
          _OnboardingSlide(
            title: 'Track Your Progress',
            subtitle: 'Set goals and follow your fitness journey every day.',
            color: const Color(0xFF1A1A2E),
            action: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE94560),
                foregroundColor: Colors.white,
                minimumSize: const Size(200, 48),
              ),
              onPressed: () => _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut),
              child: Text(AppLocalizations.get('next')),
            ),
          ),
          _GoalPickerSlide(
            selectedGoal: _selectedGoal,
            onGoalChanged: (g) => setState(() => _selectedGoal = g),
            onNext: () => _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut),
          ),
          _HealthProfileSlide(
            height: _height,
            weight: _weight,
            age: _age,
            level: _level,
            duration: _preferredDuration,
            onChanged: (h, w, a, l, d) {
              setState(() {
                _height = h;
                _weight = w;
                _age = a;
                _level = l;
                _preferredDuration = d;
              });
            },
            onNext: () {
              if (_height != null && _weight != null && _age != null) {
                _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
              }
            },
          ),
          _OnboardingSlide(
            title: 'Start Today',
            subtitle: 'Thousands of exercises. One app.',
            color: const Color(0xFF0F3460),
            action: ElevatedButton(
              key: const Key('get_started_btn'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE94560),
                foregroundColor: Colors.white,
                minimumSize: const Size(200, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              onPressed: _finish,
              child: Text(AppLocalizations.get('get_started')),
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingSlide extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color color;
  final Widget? action;

  const _OnboardingSlide({
    required this.title,
    required this.subtitle,
    required this.color,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: color,
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            subtitle,
            style: const TextStyle(color: Colors.white70, fontSize: 16),
            textAlign: TextAlign.center,
          ),
          if (action != null) ...[const SizedBox(height: 40), action!],
        ],
      ),
    );
  }
}

class _GoalPickerSlide extends StatelessWidget {
  final GoalType selectedGoal;
  final ValueChanged<GoalType> onGoalChanged;
  final VoidCallback onNext;

  const _GoalPickerSlide({
    required this.selectedGoal,
    required this.onGoalChanged,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF16213E),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'What is your main goal?',
            style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          _goalCard(GoalType.weightLoss, '🔥 Weight Loss', 'Burn fat and get lean'),
          const SizedBox(height: 16),
          _goalCard(GoalType.conditioning, '🏃 Conditioning', 'Improve stamina and athletic performance'),
          const SizedBox(height: 16),
          _goalCard(GoalType.bodybuilding, '💪 Bodybuilding', 'Build muscle mass and strength'),
          const SizedBox(height: 40),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE94560),
              foregroundColor: Colors.white,
              minimumSize: const Size(200, 48),
            ),
            onPressed: onNext,
            child: Text(AppLocalizations.get('continue_btn')),
          ),
        ],
      ),
    );
  }

  Widget _goalCard(GoalType type, String title, String subtitle) {
    final isSelected = selectedGoal == type;
    return GestureDetector(
      onTap: () => onGoalChanged(type),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE94560).withOpacity(0.2) : Colors.white10,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFFE94560) : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(subtitle, style: const TextStyle(color: Colors.white54, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}

class _HealthProfileSlide extends StatefulWidget {
  final double? height;
  final double? weight;
  final int? age;
  final String level;
  final int duration;
  final void Function(double? h, double? w, int? a, String l, int d) onChanged;
  final VoidCallback onNext;

  const _HealthProfileSlide({
    required this.height,
    required this.weight,
    required this.age,
    required this.level,
    required this.duration,
    required this.onChanged,
    required this.onNext,
  });

  @override
  State<_HealthProfileSlide> createState() => _HealthProfileSlideState();
}

class _HealthProfileSlideState extends State<_HealthProfileSlide> {
  late TextEditingController _hCtrl;
  late TextEditingController _wCtrl;
  late TextEditingController _aCtrl;

  @override
  void initState() {
    super.initState();
    _hCtrl = TextEditingController(text: widget.height?.toString() ?? '');
    _wCtrl = TextEditingController(text: widget.weight?.toString() ?? '');
    _aCtrl = TextEditingController(text: widget.age?.toString() ?? '');
  }

  @override
  void dispose() {
    _hCtrl.dispose();
    _wCtrl.dispose();
    _aCtrl.dispose();
    super.dispose();
  }

  void _update() {
    widget.onChanged(
      double.tryParse(_hCtrl.text),
      double.tryParse(_wCtrl.text),
      int.tryParse(_aCtrl.text),
      widget.level,
      widget.duration,
    );
  }

  @override
  Widget build(BuildContext context) {
    final canGoNext = _hCtrl.text.isNotEmpty && _wCtrl.text.isNotEmpty && _aCtrl.text.isNotEmpty;
    return Container(
      color: const Color(0xFF16213E),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 60),
            const Text(
              'Your Health Profile',
              style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            _inputField('Height (cm)', _hCtrl, TextInputType.number),
            const SizedBox(height: 12),
            _inputField('Weight (kg)', _wCtrl, TextInputType.number),
            const SizedBox(height: 12),
            _inputField('Age', _aCtrl, TextInputType.number),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: canGoNext ? const Color(0xFFE94560) : Colors.grey,
                foregroundColor: Colors.white,
                minimumSize: const Size(200, 48),
              ),
              onPressed: canGoNext ? widget.onNext : null,
              child: Text(AppLocalizations.get('continue_btn')),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _inputField(String label, TextEditingController ctrl, TextInputType type) {
    return TextField(
      controller: ctrl,
      keyboardType: type,
      style: const TextStyle(color: Colors.white),
      onChanged: (v) {
        _update();
        setState(() {}); // refresh button state
      },
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white54),
        filled: true,
        fillColor: const Color(0xFF1A1A2E),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
    );
  }
}
