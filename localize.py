import os

dictionary = {
    'dashboard': 'Dashboard',
    'explore': 'Explore',
    'feed': 'Feed',
    'profile': 'Profile',
    'settings': 'Settings',
    'new_routine': 'New Routine',
    'workout_completed': 'Workout Completed',
    'liked_exercises': 'Liked Exercises',
    'fitness_goal': 'Fitness Goal',
    'weight_loss': 'Weight Loss',
    'conditioning': 'General Conditioning',
    'bodybuilding': 'Advanced Bodybuilding',
    'logout': 'Logout',
    'save': 'Save',
    'all_exercises': 'All Exercises',
    'custom_routines': 'Custom Routines',
    'fitness_test': 'Fitness Test',
    'search_exercises': 'Search exercises...',
    'all': 'All',
    'no_exercises_found': 'No exercises found',
    'no_posts_yet': 'No posts yet.',
    'guest': 'Guest',
    'day_streak': 'Day Streak',
    'first_step': 'First Step',
    'consistency': 'Consistency',
    'power': 'Power',
    'night_owl': 'Night Owl',
    'workouts': 'Workouts',
    'minutes': 'Minutes',
    'avg_mins': 'Avg Mins',
    'recent_activity': 'Recent Activity (Minutes)',
    'fitness_diagnostic': 'Fitness Diagnostic',
    'perform': 'Perform',
    'submit': 'Submit',
    'hello': 'Hello, ',
    'athlete_greeting': 'Athlete',
    'plan': 'Plan',
    "today_workout": "Today's Workout",
    'setup_instructions': 'Setup your profile to begin tracking workouts.',
    'track_progress': 'Track Your Progress',
    'track_progress_sub': 'Set goals and follow your fitness journey every day.',
    'next': 'Next',
    'start_today': 'Start Today',
    'start_today_sub': 'Thousands of exercises. One app.',
    'get_started': 'Get Started',
    'what_is_goal': 'What is your main goal?',
    'continue_btn': 'Continue',
    'start_workout': 'Start Workout',
    'rest': 'REST',
    'finish_workout': 'Finish Workout',
    'skip_rest': 'Skip Rest →',
    'set': 'Set',
    'duration': 'Duration',
    'duration_30s': '30 sec',
    'reps': 'Reps',
    'weight': 'Weight',
    'exit_workout': 'Exit Workout?',
    'exit_workout_sub': 'Your progress will not be saved.',
    'keep_going': 'Keep Going',
    'exit': 'Exit',
    'workout_complete': 'Workout Complete!',
    'share_to_feed': 'Share to Feed',
    'workout_shared': 'Workout shared to feed!',
    'close_summary': 'Close Summary',
    'target': 'Target',
    'equipment': 'Equipment',
    'level': 'Level',
    'exercise_images': 'Exercise Images',
    'description': 'Description',
    'how_to_perform': 'How to Perform',
    'login': 'Login',
    'register': 'Register',
    'email': 'Email',
    'password': 'Password',
    'no_account': "Don't have an account? Register",
    'have_account': 'Already have an account? Login',
    'create_account': 'Create Account',
    'login_instead': 'Login Instead',
}

files = [
    'lib/presentation/screens/login_screen.dart',
    'lib/presentation/screens/register_screen.dart',
    'lib/presentation/screens/onboarding_screen.dart',
    'lib/presentation/screens/settings_screen.dart',
    'lib/presentation/screens/workout_screens.dart',
    'lib/presentation/screens/routine_builder_screen.dart',
    'lib/presentation/screens/main_tabs.dart'
]

for path in files:
    if not os.path.exists(path):
        continue
    with open(path, 'r', encoding='utf-8') as f:
        content = f.read()

    # Add import if missing
    if 'core/localization.dart' not in content:
        content = content.replace("import 'package:flutter/material.dart';", "import 'package:flutter/material.dart';\nimport '../../core/localization.dart';")

    for key, val in dictionary.items():
        # Text('val')
        content = content.replace(f"Text('{val}'", f"Text(AppLocalizations.get('{key}')")
        content = content.replace(f'Text("{val}"', f"Text(AppLocalizations.get('{key}')")
        
        # const Text('val')
        content = content.replace(f"const Text('{val}'", f"Text(AppLocalizations.get('{key}')")
        content = content.replace(f'const Text("{val}"', f"Text(AppLocalizations.get('{key}')")

        # Fallback for raw string replacements in Text
        content = content.replace(f"Text(AppLocalizations.get('{key}'),", f"Text(AppLocalizations.get('{key}'),")

    # Clean up double AppLocalizations if occurred
    content = content.replace("AppLocalizations.get(AppLocalizations.get(", "AppLocalizations.get(")
    content = content.replace("const Text(AppLocalizations.get", "Text(AppLocalizations.get")

    with open(path, 'w', encoding='utf-8') as f:
        f.write(content)
    print(f"Processed {path}")
