import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'features/authentication/signin/sign_in.dart';
import 'features/authentication/signup/sign_up.dart';
import 'features/story/detail/add_story_screen.dart';
import 'features/story/detail/story_detail_screen.dart';
import 'features/story/home/home.dart';
import 'providers/auth_provider.dart';
import 'providers/locale_provider.dart';
import 'providers/story_provider.dart';
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
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => StoryProvider()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
      ],
      child: Consumer<LocaleProvider>(
        builder: (context, localeProvider, _) {
          return MaterialApp(
            title: 'Story App',
            theme: ThemeData(
              primarySwatch: Colors.blue,
              visualDensity: VisualDensity.adaptivePlatformDensity,
              useMaterial3: true,
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
            localizationsDelegates: LocalizationSetup.localizationsDelegates,
            supportedLocales: LocalizationSetup.supportedLocales,
            locale: localeProvider.locale,
            localeResolutionCallback:
                LocalizationSetup.localeResolutionCallback,
            initialRoute: '/',
            routes: {
              '/': (context) => const SplashScreen(),
              LoginScreen.routeName: (context) => const LoginScreen(),
              RegisterScreen.routeName: (context) => const RegisterScreen(),
              HomeScreen.routeName: (context) => const HomeScreen(),
              StoryDetailScreen.routeName:
                  (context) => const StoryDetailScreen(),
              AddStoryScreen.routeName: (context) => const AddStoryScreen(),
            },
          );
        },
      ),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    final isLoggedIn =
        await Provider.of<AuthProvider>(
          context,
          listen: false,
        ).checkLoginStatus();

    if (isLoggedIn) {
      Navigator.pushReplacementNamed(context, HomeScreen.routeName);
    } else {
      Navigator.pushReplacementNamed(context, LoginScreen.routeName);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image, size: 100, color: Theme.of(context).primaryColor),
            const SizedBox(height: 24),
            Text(
              AppLocalizations.of(context)?.appTitle ?? 'Story App',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
