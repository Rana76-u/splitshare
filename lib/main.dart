import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:splitshare/Screens/Login/login.dart';
import 'package:splitshare/Screens/My%20Trips/my_trips.dart';
import 'package:splitshare/Widgets/bottom_nav_bar.dart';
import 'package:splitshare/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform
  );
  if(await FlutterOverlayWindow.isPermissionGranted()) {
    FlutterOverlayWindow.requestPermission();
  }
  runApp(const MyApp());
}

// overlay entry point
@pragma("vm:entry-point")
void overlayMain() {
  runApp(const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Material(child: Text("My overlay"))
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Widget screenNavigator() {
    return FutureBuilder(
      future: SharedPreferences.getInstance(),
      builder: (context, snapshot) {
        if (FirebaseAuth.instance.currentUser != null &&
            snapshot.connectionState == ConnectionState.done &&
            snapshot.data!.getString('tripCode') != null) {
          return BottomBar(bottomIndex: 0); //Fix 0
        } else if (FirebaseAuth.instance.currentUser != null) {
          FlutterOverlayWindow.showOverlay(height: 200, width: 200);
          return const MyTrips();
        } else {
          return const LoginPage();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'SplitShare',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        fontFamily: 'Urbanist',
      ),
      debugShowCheckedModeBanner: false,
      home: screenNavigator(),
    );
  }
}
