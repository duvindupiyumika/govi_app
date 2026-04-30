import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:provider/provider.dart';
import 'core/storage/local_storage_service.dart';
import 'l10n/app_localizations_context.dart';
import 'l10n/generated/app_localizations.dart';
import 'screens/profile/theme_provider.dart';
import 'firebase_options.dart';
import 'screens/home/home_screen.dart';
import 'screens/tracking/tracking_screen.dart';
import 'screens/ai_suggestions/ai_suggestions_screen.dart';
import 'screens/market/market_screen.dart';
import 'screens/knowledge/knowledge_screen.dart';
import 'screens/onboarding/onboarding_flow_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/select_veg/select_veg_screen.dart';
import 'widgets/bottom_nav_bar.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  var firebaseInitialized = false;

  await LocalStorageService.initialize();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    firebaseInitialized = true;
    debugPrint('Firebase initialized successfully.');
  } catch (e) {
    debugPrint('Firebase initialization error: $e');
  }

  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint('Error loading .env file: $e');
  }

  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: GovAppBootstrap(firebaseInitialized: firebaseInitialized),
    ),
  );
}

class GovAppBootstrap extends StatefulWidget {
  final bool firebaseInitialized;

  const GovAppBootstrap({super.key, required this.firebaseInitialized});

  @override
  State<GovAppBootstrap> createState() => _GovAppBootstrapState();
}

class _GovAppBootstrapState extends State<GovAppBootstrap> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FlutterNativeSplash.remove();
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp(
      title: context.l10n.appTitle,
      debugShowCheckedModeBanner: false,
      locale: themeProvider.locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      themeMode: themeProvider.themeMode,
      theme: MyThemes.lightTheme,
      darkTheme: MyThemes.darkTheme,
      home: widget.firebaseInitialized
          ? (themeProvider.onboardingComplete
                ? const MainScreen()
                : const OnboardingFlowScreen())
          : const StartupErrorScreen(),
    );
  }
}

class StartupErrorScreen extends StatelessWidget {
  const StartupErrorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            context.l10n.startupFirebaseError,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  final _navigatorKey = GlobalKey<NavigatorState>();

  static const Map<int, String> _routeNames = {
    0: '/home',
    1: '/tracking',
    2: '/ai_suggestions',
    3: '/market',
    4: '/knowledge',
    5: '/profile',
  };

  void _onNavBarTap(int index) {
    if (_currentIndex == index) {
      _navigatorKey.currentState?.popUntil((route) => route.isFirst);
    } else {
      setState(() {
        _currentIndex = index;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _navigatorKey.currentState?.pushNamedAndRemoveUntil(
          _routeNames[index]!,
          (route) => false,
        );
      });
    }
  }

  void _pushRoute(String routeName) {
    _navigatorKey.currentState?.pushNamed(routeName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Navigator(
        key: _navigatorKey,
        initialRoute: '/home',
        onGenerateRoute: (settings) {
          WidgetBuilder builder;
          switch (settings.name) {
            case '/':
            case '/home':
              builder = (context) =>
                  HomeScreen(onNavigate: _onNavBarTap, onPushRoute: _pushRoute);
              break;
            case '/tracking':
              builder = (context) => const TrackingScreen();
              break;
            case '/ai_suggestions':
              builder = (context) => const AiSuggestionsScreen();
              break;
            case '/market':
              builder = (context) => const MarketScreen();
              break;
            case '/knowledge':
              builder = (context) => const KnowledgeScreen();
              break;
            case '/profile':
              builder = (context) => const ProfileScreen();
              break;
            case '/select_veg':
              builder = (context) => const SelectVegScreen();
              break;
            default:
              builder = (context) =>
                  HomeScreen(onNavigate: _onNavBarTap, onPushRoute: _pushRoute);
              break;
          }
          return MaterialPageRoute(builder: builder, settings: settings);
        },
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onNavBarTap,
      ),
    );
  }
}
