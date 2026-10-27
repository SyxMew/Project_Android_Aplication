import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:food_app/providers/auth_providers.dart';
import 'package:food_app/screens/SignUp/signup.dart';
import 'package:food_app/screens/home/home.dart';
import 'package:food_app/screens/menu/menu.dart';
import 'package:food_app/screens/profile/profile.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  MobileAds.instance.initialize();

  AwesomeNotifications().initialize(
    'resource://drawable/launcher_icon', // Ensure valid small icon
    [
      NotificationChannel(
        channelKey: 'basic_channel',
        channelName: 'Basic notifications',
        channelDescription: 'Notification channel for basic tests',
        defaultColor: Color(0xFF9D50DD),
        ledColor: Colors.white,
        importance: NotificationImportance.High,
        channelShowBadge: true,
        playSound: true,
        enableVibration: true,
        enableLights: true,
        defaultRingtoneType: DefaultRingtoneType.Notification,
      )
    ],
    debug: true,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AuthProvider(),
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          return MaterialApp(
            locale: const Locale('id'),
            supportedLocales: const [
              Locale('en'),
              Locale('id'),
            ],
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            theme: ThemeData(
              fontFamily: 'Itim',
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.black),
              useMaterial3: true,
            ),
            debugShowCheckedModeBanner: false,
            initialRoute:
                authProvider.currentUser == null ? '/create' : '/home',
            routes: {
              '/create': (context) => const SignUpScreen(),
              '/home': (context) => const HomeScreen(),
              '/menu': (context) => const MenuScreen(),
              '/profile': (context) => const ProfileScreen(),
            },
          );
        },
      ),
    );
  }
}
