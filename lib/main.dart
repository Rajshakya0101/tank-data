import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/home.dart';

// Firebase configuration for web
const firebaseOptions = FirebaseOptions(
  apiKey: "AIzaSyCjCT6oFOmZuYjbyy5X-T3kHmpi-DjFBX0",
  authDomain: "hydroponic-bd230.firebaseapp.com",
  databaseURL:
  "https://hydroponic-bd230-default-rtdb.asia-southeast1.firebasedatabase.app/",
  projectId: "hydroponic-bd230",
  storageBucket: "hydroponic-bd230.appspot.com",
  messagingSenderId: "227538036456",
  appId: "1:227538036456:android:74aef228b0b8df1f630b5d",
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Check if Firebase app is already initialized
    if (Firebase.apps.isEmpty) {
      if (kIsWeb) {
        await Firebase.initializeApp(options: firebaseOptions);
        debugPrint("Firebase initialized for Web");
      } else {
        await Firebase.initializeApp();
        debugPrint("Firebase initialized for Mobile");
      }
    }
  } catch (e) {
    debugPrint("Firebase initialization error: $e");
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Define custom themes
    final ThemeData lightTheme = ThemeData(
      primarySwatch: Colors.teal,
      scaffoldBackgroundColor: Colors.grey[100],
      cardColor: Colors.white,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.teal,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      textTheme: TextTheme(
        headlineMedium: TextStyle(
          fontSize: 48,
          fontWeight: FontWeight.bold,
          color: Colors.teal[800],
        ),
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.teal[700],
        ),
        bodyMedium: TextStyle(
          fontSize: 16,
          color: Colors.grey[800],
        ),
      ),
    );

    final ThemeData darkTheme = ThemeData.dark().copyWith(
      primaryColor: Colors.teal,
      scaffoldBackgroundColor: Colors.grey[900],
      cardColor: Colors.grey[800],
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.teal[700],
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      textTheme: TextTheme(
        headlineMedium: TextStyle(
          fontSize: 48,
          fontWeight: FontWeight.bold,
          color: Colors.teal[200],
        ),
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.teal[100],
        ),
        bodyMedium: TextStyle(
          fontSize: 16,
          color: Colors.grey[300],
        ),
      ),
    );

    return MaterialApp(
      title: 'Realtime Tank Data',
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: ThemeMode.system,
      home: HomeScreen(),
      // Adding a default route transition for a smoother experience
      onGenerateRoute: (settings) {
        return MaterialPageRoute(builder: (context) => HomeScreen());
      },
    );
  }
}
