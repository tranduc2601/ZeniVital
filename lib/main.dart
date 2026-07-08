import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:trenx/core/localization.dart';
import 'package:trenx/data/api/local_database.dart';
import 'package:trenx/data/api/static_data.dart';
import 'package:trenx/domain/models/user.dart';
import 'package:trenx/presentation/screens/splash_screen.dart';
import 'package:trenx/presentation/screens/onboarding_screen.dart';
import 'package:trenx/presentation/screens/login_screen.dart';
import 'package:trenx/presentation/screens/register_screen.dart';
import 'package:trenx/presentation/screens/workout_screens.dart';
import 'package:trenx/presentation/screens/settings_screen.dart';
import 'package:trenx/presentation/screens/exercise_detail_screen.dart';
import 'package:trenx/presentation/screens/routine_builder_screen.dart';
import 'package:trenx/presentation/screens/main_tabs.dart';
import 'package:trenx/presentation/screens/exercise_list_screen.dart';
import 'package:trenx/data/repositories/exercise_repository_impl.dart';
import 'package:trenx/data/datasources/exercise_remote_datasource.dart';
import 'package:http/http.dart' as http;
import 'package:trenx/domain/models/routine.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalDatabase.instance.init();
  AppLocalizations.locale = LocalDatabase.instance.getLocale();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _screen = 'splash';
  String _activeTab = 'dashboard';
  String _selectedExercise = '';
  Routine? _selectedRoutine;
  String _previousScreen = 'dashboard';

  void _go(String screen) {
    if (!mounted) return;
    setState(() {
      _previousScreen = _screen;
      _screen = screen;
    });
  }

  void _handleBack() {
    // ponytail: simple 1-level back history + tab history
    if (_screen == 'dashboard') {
      if (_activeTab != 'dashboard') {
        setState(() => _activeTab = 'dashboard');
      }
      return; // if already on dashboard tab, let system handle exit
    }
    if (_screen == 'splash' || _screen == 'login' || _screen == 'onboarding') {
      return; // let system handle (exit app or do nothing)
    }
    _go(_previousScreen == _screen ? 'dashboard' : _previousScreen);
  }

  Widget _buildBody() {
    switch (_screen) {
      case 'splash':
        return SplashScreen(
          onTimeout: () {
            if (LocalDatabase.instance.getUser() != null) {
              if (LocalDatabase.instance.getUser()!.hasCompletedProfile) {
                _go('dashboard');
              } else {
                _go('onboarding');
              }
            } else {
              _go('login');
            }
          },
        );

      case 'onboarding':
        return OnboardingScreen(onComplete: () {
          _go('dashboard');
        });

      case 'login':
        return LoginScreen(
          onLoginSuccess: () {
            if (LocalDatabase.instance.getUser()?.hasCompletedProfile == true) {
              _go('dashboard');
            } else {
              _go('onboarding');
            }
          },
          onGoToRegister: () => _go('register'),
        );

      case 'register':
        return RegisterScreen(
          onRegisterSuccess: () => _go('onboarding'),
          onBackToLogin: () => _go('login'),
        );

      case 'dashboard':
        return _DashboardShell(
          activeTab: _activeTab,
          selectedExercise: _selectedExercise,
          onTabChange: (tab) => setState(() => _activeTab = tab),
          onExerciseTap: (name) {
            if (name == 'ALL_EXERCISES') {
              _go('exercise_library');
              return;
            }
            _selectedExercise = name;
            _go('exercise_detail');
          },
          onWorkoutTap: (Routine? routine) {
            _selectedRoutine = routine;
            _go('workout_detail');
          },
          onGoToSettings: () => _go('settings'),
          onGoToOnboarding: () => _go('onboarding'),
          onUnlikeDone: () => setState(() {}),
          onRoutineBuilderTap: () => _go('routine_builder'),
          onLocaleChanged: () => setState(() {}),
        );

      case 'exercise_detail':
        final ex = StaticData.exercises.firstWhere(
          (e) => e.name == _selectedExercise,
          orElse: () => StaticData.exercises.first,
        );
        return ExerciseDetailScreen(
          exercise: ex,
          onBack: _handleBack,
        );

      case 'workout_detail':
        return WorkoutDetailScreen(onStartWorkout: () => _go('workout_player'));

      case 'workout_player':
        return WorkoutPlayerScreen(
          goalType: LocalDatabase.instance.getUser()?.goal ?? GoalType.conditioning,
          customRoutine: _selectedRoutine,
          onComplete: () {
            _selectedRoutine = null;
            _go('workout_summary');
          },
          onExitRequest: () {
            _selectedRoutine = null;
            _go('dashboard');
          },
        );

      case 'workout_summary':
        return WorkoutSummaryScreen(
          onClose: () {
            setState(() => _activeTab = 'dashboard');
            _go('dashboard');
          },
        );

      case 'settings':
        return SettingsScreen(
          onSave: () => _go('dashboard'),
          onLogout: () {
            LocalDatabase.instance.logout();
            _go('login');
          },
          onLocaleChanged: () {
            setState(() {
              AppLocalizations.locale = LocalDatabase.instance.getLocale();
            });
          },
        );

      case 'routine_builder':
        return RoutineBuilderScreen(
          onBack: () => _go('dashboard'),
          onSave: () => _go('dashboard'),
        );

      case 'exercise_library':
        return ExerciseListScreen(
          repository: ExerciseRepositoryImpl(
            remoteDataSource: ExerciseRemoteDataSourceImpl(client: http.Client()),
          ),
        );

      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ZeniVital',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en'), Locale('vi')],
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFE94560),
          brightness: Brightness.dark,
          background: const Color(0xFF0A0A0A),
        ),
        textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF0A0A0A),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
      ),
      home: PopScope(
        canPop: _screen == 'splash' || _screen == 'login' || _screen == 'onboarding' || (_screen == 'dashboard' && _activeTab == 'dashboard'),
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) _handleBack();
        },
        child: _buildBody(),
      ),
    );
  }
}

class _DashboardShell extends StatelessWidget {
  final String activeTab;
  final String selectedExercise;
  final void Function(String) onTabChange;
  final void Function(String) onExerciseTap;
  final void Function(Routine?) onWorkoutTap;
  final VoidCallback onGoToSettings;
  final VoidCallback onGoToOnboarding;
  final VoidCallback onUnlikeDone;
  final VoidCallback onRoutineBuilderTap;
  final VoidCallback onLocaleChanged;

  const _DashboardShell({
    required this.activeTab,
    required this.selectedExercise,
    required this.onTabChange,
    required this.onExerciseTap,
    required this.onWorkoutTap,
    required this.onGoToSettings,
    required this.onGoToOnboarding,
    required this.onUnlikeDone,
    required this.onRoutineBuilderTap,
    required this.onLocaleChanged,
  });

  final List<String> availableTabs = const [
    'dashboard',
    'explore',
    if (bool.fromEnvironment('ENABLE_COMMUNITY_TAB', defaultValue: false)) 'feed',
    'profile'
  ];

  int get _tabIndex {
    final index = availableTabs.indexOf(activeTab);
    return index == -1 ? 0 : index;
  }

  Widget _tabBody() {
    switch (activeTab) {
      case 'explore':
        return ExploreScreen(
          onExerciseTap: onExerciseTap,
          onCreateRoutineTap: onRoutineBuilderTap,
        );
      case 'feed':
        if (!const bool.fromEnvironment('ENABLE_COMMUNITY_TAB', defaultValue: false)) {
          return const Center(child: Text('Coming Soon', style: TextStyle(color: Colors.white54)));
        }
        return const FeedScreen();
      case 'profile':
        return ProfileScreen(
          onGoToSettings: onGoToSettings,
          onGoToOnboarding: onGoToOnboarding,
          onUnlikeDone: onUnlikeDone,
        );
      default:
        return DashboardScreen(
          onExerciseTap: onExerciseTap,
          onWorkoutTap: onWorkoutTap,
          onGoToSettings: onGoToSettings,
          onTabChanged: onGoToOnboarding,
          onRoutineBuilderTap: onRoutineBuilderTap,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: _tabBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _tabIndex,
        backgroundColor: const Color(0xFF16213E),
        selectedItemColor: const Color(0xFFE94560),
        unselectedItemColor: Colors.white38,
        type: BottomNavigationBarType.fixed,
        onTap: (i) {
          onTabChange(availableTabs[i]);
        },
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.dashboard, key: Key('tab_dashboard')),
            label: AppLocalizations.get('dashboard'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.search, key: Key('tab_explore')),
            label: AppLocalizations.get('explore'),
          ),
          if (const bool.fromEnvironment('ENABLE_COMMUNITY_TAB', defaultValue: false))
            BottomNavigationBarItem(
              icon: const Icon(Icons.dynamic_feed, key: Key('tab_feed')),
              label: AppLocalizations.get('feed'),
            ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person, key: Key('tab_profile')),
            label: AppLocalizations.get('profile'),
          ),
        ],
      ),
      floatingActionButton: activeTab == 'explore'
          ? FloatingActionButton.extended(
              onPressed: () => onExerciseTap('ALL_EXERCISES'),
              label: const Text('Exercise Library'),
              icon: const Icon(Icons.list),
            )
          : null,
    );
  }
}
