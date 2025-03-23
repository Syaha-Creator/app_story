import 'package:flutter/material.dart';

import 'app_page_config.dart';

class AppRouteInformationParser extends RouteInformationParser<AppPageConfig> {
  @override
  Future<AppPageConfig> parseRouteInformation(
    RouteInformation routeInformation,
  ) async {
    final uri = routeInformation.uri;

    switch (uri.path) {
      case AppPageConfig.loginPath:
        return AppPageConfig(AppPageConfig.loginPath);
      case AppPageConfig.registerPath:
        return AppPageConfig(AppPageConfig.registerPath);
      case AppPageConfig.addStoryPath:
        return AppPageConfig(AppPageConfig.addStoryPath);
      case AppPageConfig.homePath:
      default:
        return AppPageConfig(AppPageConfig.homePath);
    }
  }

  @override
  RouteInformation restoreRouteInformation(AppPageConfig configuration) {
    return RouteInformation(uri: Uri.parse(configuration.path));
  }
}
