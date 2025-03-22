import 'dart:io';

import 'package:flutter/material.dart';

import '../repositories/story_model.dart';
import '../services/api_service.dart';

class StoryProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<Story> _stories = [];
  Story? _selectedStory;
  bool _isLoading = false;
  String _errorMessage = '';

  List<Story> get stories => _stories;
  Story? get selectedStory => _selectedStory;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  Future<void> fetchStories() async {
    try {
      _isLoading = true;
      _errorMessage = '';
      notifyListeners();

      _stories = await _apiService.getStories();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> fetchStoryDetail(String id) async {
    try {
      _isLoading = true;
      _errorMessage = '';
      notifyListeners();

      _selectedStory = await _apiService.getStoryDetail(id);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<bool> addStory(File photo, String description) async {
    try {
      _isLoading = true;
      _errorMessage = '';
      notifyListeners();

      final success = await _apiService.addStory(photo, description);
      _isLoading = false;

      if (success) {
        await fetchStories(); // Refresh the stories list after adding
      }

      notifyListeners();
      return success;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  void clearSelectedStory() {
    _selectedStory = null;
    notifyListeners();
  }
}
