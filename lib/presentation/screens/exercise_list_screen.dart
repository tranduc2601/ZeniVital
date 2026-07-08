import 'dart:async';
import 'package:flutter/material.dart';
import '../../domain/models/exercise.dart';
import '../../domain/repositories/exercise_repository.dart';
import '../widgets/exercise_card.dart';

class ExerciseListScreen extends StatefulWidget {
  final ExerciseRepository repository;

  const ExerciseListScreen({super.key, required this.repository});

  @override
  State<ExerciseListScreen> createState() => _ExerciseListScreenState();
}

class _ExerciseListScreenState extends State<ExerciseListScreen> {
  List<Exercise> _allExercises = [];
  List<Exercise> _displayedExercises = [];
  bool _isLoading = true;
  
  String _searchQuery = '';
  String _selectedCategory = 'All';
  
  Timer? _debounce;
  
  final List<String> _categories = ['All', 'Chest', 'Back', 'Legs', 'Arms', 'Core', 'Cardio'];

  @override
  void initState() {
    super.initState();
    _fetchAllExercises();
  }

  Future<void> _fetchAllExercises() async {
    try {
      // Fetch a large number to load all into memory as requested
      final exercises = await widget.repository.getExercises(limit: 2000, offset: 0);
      if (mounted) {
        setState(() {
          _allExercises = exercises;
          _displayedExercises = exercises;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading exercises: $e')),
        );
      }
    }
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      setState(() {
        _searchQuery = query;
        _filterExercises();
      });
    });
  }
  
  void _onCategorySelected(String category) {
    setState(() {
      _selectedCategory = category;
      _filterExercises();
    });
  }

  void _filterExercises() {
    setState(() {
      _displayedExercises = _allExercises.where((exercise) {
        final matchesSearch = exercise.name.toLowerCase().contains(_searchQuery.toLowerCase());
        
        bool matchesCategory = true;
        if (_selectedCategory != 'All') {
          final target = exercise.targetMuscle.toLowerCase();
          final category = _selectedCategory.toLowerCase();
          
          matchesCategory = target.contains(category);
        }
        
        return matchesSearch && matchesCategory;
      }).toList();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exercise Library'),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search exercises...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
          
          // Filter Chips
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = category == _selectedCategory;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: FilterChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (_) => _onCategorySelected(category),
                    selectedColor: Theme.of(context).colorScheme.primaryContainer,
                  ),
                );
              },
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Exercise List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _displayedExercises.isEmpty
                    ? const Center(child: Text('No exercises found'))
                    : ListView.builder(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        itemCount: _displayedExercises.length,
                        itemBuilder: (context, index) {
                          return ExerciseCard(exercise: _displayedExercises[index]);
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
