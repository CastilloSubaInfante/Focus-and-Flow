import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'login_page.dart';
import 'signup_page.dart';
import 'home_page.dart';
import 'profile_page.dart';
import 'calendar_page.dart';
import 'notification_page.dart';
import 'edit_profile_page.dart';
import 'settings_page.dart';
import 'theme_provider.dart';
import 'data_store.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Load all persistent data on app startup
  await DataStore.loadRegisteredUsers();
  await DataStore.loadCurrentUserEmail();
  await DataStore.loadCurrentUserUsername();
  await DataStore.loadCalendarData();
  await DataStore.loadTasks();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Focus & Flow',
            theme: themeProvider.getLightTheme(),
            darkTheme: themeProvider.getDarkTheme(),
            themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            home: StreamBuilder<User?>(
              stream: FirebaseAuth.instance.authStateChanges(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Scaffold(
                    body: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                
                // If user is logged in and email is verified
                if (snapshot.hasData && snapshot.data?.emailVerified == true) {
                  return const HomePage();
                }
                
                // Otherwise show login page
                return const LoginPage();
              },
            ),
            routes: {
              '/login': (context) => const LoginPage(),
              '/signup': (context) => const SignUpPage(),
              '/home': (context) => const HomePage(),
              '/profile': (context) => const ProfilePage(),
              '/edit-profile': (context) => const EditProfilePage(),
              '/settings': (context) => const SettingsPage(),
              '/calendar': (context) => const CalendarPage(),
              '/notifications': (context) => const NotificationPage(),
            },
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}