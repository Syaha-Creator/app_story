import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../features/authentication/signin/sign_in.dart';
import '../features/authentication/signup/sign_up.dart';
import '../features/story/detail/add_story_screen.dart';
import '../features/story/detail/story_detail_screen.dart';
import '../features/story/home/home.dart';
import '../providers/auth_provider.dart';
import 'app_page_config.dart';

class AppRouterDelegate extends RouterDelegate<AppPageConfig>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<AppPageConfig> {
  @override
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  String _currentPath = AppPageConfig.loginPath;
  String? _selectedStoryId;

  AppRouterDelegate(BuildContext context);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isLoggedIn = authProvider.user != null;
    LatLng? _pickedLatLng;
    String? _pickedAddress;

    List<Page> stack = [];

    if (!isLoggedIn) {
      switch (_currentPath) {
        case AppPageConfig.registerPath:
          stack.add(
            MaterialPage(
              child: RegisterScreen(
                onRegisterSuccess: _navigateToLoginWithDelay,
              ),
              key: const ValueKey('RegisterPage'),
            ),
          );
          break;
        default:
          stack.add(
            MaterialPage(
              child: LoginScreen(
                onLoginSuccess: _navigateToHome,
                onRegisterNavigate: _navigateToRegister,
              ),
              key: const ValueKey('LoginPage'),
            ),
          );
      }
    } else {
      stack.add(
        MaterialPage(
          child: HomeScreen(
            onAddStoryNavigate: _navigateToAddStory,
            onLogout: _navigateToLogin,
            onStoryTap: _navigateToStoryDetail,
          ),
          key: const ValueKey('HomePage'),
        ),
      );

      if (_currentPath == AppPageConfig.addStoryPath) {
        stack.add(
          MaterialPage(
            child: AddStoryScreen(onStoryAdded: _navigateToHome),
            key: const ValueKey('AddStoryPage'),
          ),
        );
      }

      if (_currentPath == AppPageConfig.storyDetailPath &&
          _selectedStoryId != null) {
        stack.add(
          MaterialPage(
            child: StoryDetailScreen(storyId: _selectedStoryId!),
            key: ValueKey('StoryDetail-${_selectedStoryId!}'),
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

  void _navigateToHome() {
    _currentPath = AppPageConfig.homePath;
    _selectedStoryId = null;
    notifyListeners();
  }

  void _navigateToLogin() {
    _currentPath = AppPageConfig.loginPath;
    _selectedStoryId = null;
    notifyListeners();
  }

  Future<void> _navigateToLoginWithDelay() async {
    _navigateToLogin();
  }

  void _navigateToRegister() {
    _currentPath = AppPageConfig.registerPath;
    _selectedStoryId = null;
    notifyListeners();
  }

  void _navigateToAddStory() {
    _currentPath = AppPageConfig.addStoryPath;
    notifyListeners();
  }

  void _navigateToStoryDetail(String id) {
    _selectedStoryId = id;
    _currentPath = AppPageConfig.storyDetailPath;
    notifyListeners();
  }

  void _handleBack() {
    if (_currentPath != AppPageConfig.homePath) {
      _navigateToHome();
    }
  }

  void _navigateToPickLocation() {
    _currentPath = AppPageConfig.pickLocationPath;
    if (_currentPath == AppPageConfig.pickLocationPath) {
      stack.add(
        MaterialPage(
          child: LocationPickerPage(
            onLocationPicked: (LatLng latLng, String address) {
              _pickedLatLng = latLng;
              _pickedAddress = address;
              _navigateToAddStory(); // kembali ke AddStory dengan data
            },
          ),
          key: const ValueKey('PickLocationPage'),
        ),
      );
    }

    notifyListeners();
  }

  @override
  Future<void> setNewRoutePath(AppPageConfig configuration) async {
    _currentPath = configuration.path;
  }

  @override
  AppPageConfig get currentConfiguration => AppPageConfig(_currentPath);
}
