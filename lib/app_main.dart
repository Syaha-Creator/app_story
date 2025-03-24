import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'providers/locale_provider.dart';
import 'providers/story_provider.dart';
import 'routes/app_route_parser.dart';
import 'routes/app_router_delegate.dart';
import 'utils/helper/localization_setup.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => StoryProvider()),
      ],
      child: Builder(
        builder: (context) {
          final localeProvider = Provider.of<LocaleProvider>(context);
          final routerDelegate = AppRouterDelegate();
          final routeInformationParser = AppRouteInformationParser();

          return MaterialApp.router(
            title: 'Story App',
            theme: ThemeData(
              useMaterial3: true,
              primarySwatch: Colors.blue,
              visualDensity: VisualDensity.adaptivePlatformDensity,
              appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            routerDelegate: routerDelegate,
            routeInformationParser: routeInformationParser,
            localizationsDelegates: LocalizationSetup.localizationsDelegates,
            supportedLocales: LocalizationSetup.supportedLocales,
            locale: localeProvider.locale,
            localeResolutionCallback:
                LocalizationSetup.localeResolutionCallback,
          );
        },
      ),
    );
  }
}
