import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:tankdata/screens/home_new.dart';
import 'package:google_fonts/google_fonts.dart';

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
    // Define a **light-only** theme using GoogleFonts.sulphurPointTextTheme
    final ThemeData lightTheme = ThemeData(
      brightness: Brightness.light,
      primarySwatch: Colors.teal,
      scaffoldBackgroundColor: Colors.grey[100],
      cardColor: Colors.white,
      // Set the default text theme to use Sulphur Point
      textTheme: GoogleFonts.sulphurPointTextTheme(
        ThemeData.light().textTheme,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.teal,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.sulphurPoint(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );

    return MaterialApp(
      title: 'Realtime Tank Data',
      debugShowCheckedModeBanner: false,
      // Use our custom light theme
      theme: lightTheme,
      // Force app into light mode only
      themeMode: ThemeMode.light,
      home: HomeScreenNew(),
      // Route
      onGenerateRoute: (settings) {
        return MaterialPageRoute(builder: (context) => HomeScreenNew());
      },
    );
  }
}
