import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../features/authentication/signin/sign_in.dart';
import '../features/authentication/signup/sign_up.dart';
import '../features/story/detail/add_story_screen.dart';
import '../features/story/detail/story_detail_screen.dart';
import '../features/story/home/home.dart';
import '../features/story/location/choose_location.dart';
import '../providers/auth_provider.dart';
import 'app_page_config.dart';

class AppRouterDelegate extends RouterDelegate<AppPageConfig>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<AppPageConfig> {
  @override
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  String _currentPath = AppPageConfig.loginPath;
  String? _selectedStoryId;

  LatLng? _pickedLatLng;
  String? _pickedAddress;

  void _handleLocationPicked(LatLng location, String address) {
    _pickedLatLng = location;
    _pickedAddress = address;
    _navigateToAddStory();
  }

  void _navigateToLogin() {
    _currentPath = AppPageConfig.loginPath;
    _selectedStoryId = null;
    notifyListeners();
  }

  void _navigateToRegister() {
    _currentPath = AppPageConfig.registerPath;
    _selectedStoryId = null;
    notifyListeners();
  }

  void _navigateToHome() {
    _currentPath = AppPageConfig.homePath;
    _selectedStoryId = null;
    _pickedLatLng = null;
    _pickedAddress = null;
    notifyListeners();
  }

  void _navigateToAddStory() {
    _currentPath = AppPageConfig.addStoryPath;
    notifyListeners();
  }

  void _navigateToPickLocation() {
    _currentPath = AppPageConfig.pickLocationPath;
    notifyListeners();
  }

  void _navigateToStoryDetail(String id) {
    _selectedStoryId = id;
    _currentPath = AppPageConfig.storyDetailPath;
    notifyListeners();
  }

  void _handleBack() {
    if (_currentPath == AppPageConfig.registerPath ||
        _currentPath == AppPageConfig.addStoryPath ||
        _currentPath == AppPageConfig.storyDetailPath ||
        _currentPath == AppPageConfig.pickLocationPath) {
      _navigateToHome();
    } else {
      _navigateToLogin();
    }
  }

  Page _buildPage(Widget child, String keyName) {
    return MaterialPage(child: child, key: ValueKey(keyName));
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: true);
    final isLoggedIn = authProvider.user != null;

    List<Page> stack = [];

    if (!isLoggedIn) {
      if (_currentPath == AppPageConfig.registerPath) {
        stack.add(
          _buildPage(
            RegisterScreen(onRegisterSuccess: _navigateToLogin),
            'RegisterPage',
          ),
        );
      } else {
        stack.add(
          _buildPage(
            LoginScreen(
              onLoginSuccess: _navigateToHome,
              onRegisterNavigate: _navigateToRegister,
            ),
            'LoginPage',
          ),
        );
      }
    } else {
      stack.add(
        _buildPage(
          HomeScreen(
            onAddStoryNavigate: _navigateToAddStory,
            onLogout: _navigateToLogin,
            onStoryTap: _navigateToStoryDetail,
          ),
          'HomePage',
        ),
      );

      if (_currentPath == AppPageConfig.addStoryPath) {
        stack.add(
          _buildPage(
            AddStoryScreen(
              onStoryAdded: _navigateToHome,
              selectedLocation: _pickedLatLng,
              selectedAddress: _pickedAddress,
              onPickLocationNavigate: _navigateToPickLocation,
            ),
            'AddStoryPage',
          ),
        );
      }

      if (_currentPath == AppPageConfig.storyDetailPath &&
          _selectedStoryId != null) {
        stack.add(
          _buildPage(
            StoryDetailScreen(storyId: _selectedStoryId!),
            'StoryDetail-${_selectedStoryId!}',
          ),
        );
      }

      if (_currentPath == AppPageConfig.pickLocationPath) {
        stack.add(
          _buildPage(
            LocationPickerPage(onLocationSelected: _handleLocationPicked),
            'LocationPickerPage',
          ),
        );
      }
    }

    return Navigator(
      key: navigatorKey,
      pages: stack,
      onPopPage: (route, result) {
        if (!route.didPop(result)) return false;
        _handleBack();
        return true;
      },
    );
  }

  @override
  Future<void> setNewRoutePath(AppPageConfig configuration) async {
    _currentPath = configuration.path;
  }

  @override
  AppPageConfig get currentConfiguration => AppPageConfig(_currentPath);
}
