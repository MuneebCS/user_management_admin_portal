import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/admin_authprovider.dart';
import 'screens/login.dart';
import 'theme/light_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize Firebase based on the platform
    if (kIsWeb) {
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: "AIzaSyAH-gWOlR_zUUsVDbGFVi8s8paaJxyez78",
          authDomain: "user-management-system-e0b64.firebaseapp.com",
          projectId: "user-management-system-e0b64",
          storageBucket: "user-management-system-e0b64.appspot.com",
          messagingSenderId: "762047865975",
          appId: "1:762047865975:web:fe6696178f9b4ade2f5272",
          measurementId: "G-7P1XYZL399",
        ),
      );
    } else {
      // Initialization for non-web platforms can be added here
      await Firebase.initializeApp();
    }
  } catch (e) {
    print('Error initializing Firebase: $e');
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthenticationProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Firebase Auth',
      theme: lightTheme,
      home: Login(),
    );
  }
}
