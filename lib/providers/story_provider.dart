import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../models/story_model.dart';
import '../services/api_service.dart';

class StoryProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  final List<Story> _stories = [];
  final Map<String, Story> _storyDetailCache = {};

  Story? _selectedStory;
  bool _isLoading = false;
  String _errorMessage = '';

  int _page = 1;
  final int _pageSize = 10;
  bool _hasMore = true;
  bool _isFetchingMore = false;
  bool _hasFetchedInitialData = false;

  List<Story> get stories => _stories;
  Story? get selectedStory => _selectedStory;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  bool get hasMore => _hasMore;
  bool get isFetchingMore => _isFetchingMore;

  bool isSameStory(String id) => _selectedStory?.id == id;

  Future<void> fetchStoriesOnce() async {
    if (_hasFetchedInitialData) return;
    _hasFetchedInitialData = true;
    await fetchStories(refresh: true);
  }

  Future<void> fetchStories({bool refresh = false}) async {
    try {
      if (refresh) {
        _page = 1;
        _stories.clear();
        _hasMore = true;
      }

      _isLoading = true;
      _errorMessage = '';
      notifyListeners();

      final newStories = await _apiService.getStories(
        page: _page,
        size: _pageSize,
      );
      if (newStories.length < _pageSize) _hasMore = false;

      _stories.addAll(newStories);
      _page++;

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> fetchMoreStories() async {
    if (_isFetchingMore || !_hasMore) return;

    _isFetchingMore = true;
    notifyListeners();

    try {
      final newStories = await _apiService.getStories(
        page: _page,
        size: _pageSize,
      );
      if (newStories.isEmpty || newStories.length < _pageSize) {
        _hasMore = false;
      } else {
        _stories.addAll(newStories);
        _page++;
      }
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isFetchingMore = false;
    notifyListeners();
  }

  Future<Story?> fetchStoryDetail(String id) async {
    if (_storyDetailCache.containsKey(id)) {
      _selectedStory = _storyDetailCache[id];
      notifyListeners();
      return _selectedStory;
    }

    try {
      _isLoading = true;
      _errorMessage = '';
      notifyListeners();

      final story = await _apiService.getStoryDetail(id);
      _selectedStory = story;
      _storyDetailCache[id] = story;

      _isLoading = false;
      notifyListeners();

      return story;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<bool> addStory(
    File photo,
    String description, {
    LatLng? location,
    String? address,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = '';
      notifyListeners();

      final success = await _apiService.addStory(
        photo,
        description,
        lat: location?.latitude,
        lon: location?.longitude,
      );

      if (success) {
        await fetchStories(refresh: true);
      }

      _isLoading = false;
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
