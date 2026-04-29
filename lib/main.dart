import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'screens/profile/theme_provider.dart'; // 🔥 Path එක Fix කළා
import 'firebase_options.dart';
import 'screens/home/home_screen.dart';
import 'screens/tracking/tracking_screen.dart';
import 'screens/ai_suggestions/ai_suggestions_screen.dart';
import 'screens/market/market_screen.dart';
import 'screens/knowledge/knowledge_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/select_Veg/select_veg_screen.dart';
import 'widgets/bottom_nav_bar.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:govi_app/logic/user_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print("Firebase Initialized Successfully! ✅");
  } catch (e) {
    print("Firebase Initialization Error: $e ❌");
  }

  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    print("Error loading .env file: $e");
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) => UserProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'Smart Agriculture',
      debugShowCheckedModeBanner: false,
      themeMode: themeProvider.themeMode,
      theme: MyThemes.lightTheme,
      darkTheme: MyThemes.darkTheme,
      home: const MainScreen(),
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
              builder = (context) => HomeScreen(
                onNavigate: _onNavBarTap,
                onPushRoute: _pushRoute,
              );
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
              builder = (context) => HomeScreen(
                onNavigate: _onNavBarTap,
                onPushRoute: _pushRoute,
              );
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