import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:lost_and_found_fnlyrprj/firebase_options.dart';
import 'package:lost_and_found_fnlyrprj/screens/admin_panel_screen.dart';
import 'package:lost_and_found_fnlyrprj/screens/admin_reported_items.dart';
import 'package:lost_and_found_fnlyrprj/screens/admin_reported_found_items.dart';
import 'package:lost_and_found_fnlyrprj/screens/claim_requests_screen.dart';
import 'package:lost_and_found_fnlyrprj/screens/favorites_screen.dart';
import 'screens/notifications_screen.dart';
import 'screens/profile_screen.dart';
import 'package:lost_and_found_fnlyrprj/screens/pending_approvals_screen.dart';
import 'package:lost_and_found_fnlyrprj/screens/resolved_items_screen.dart';
import 'package:lost_and_found_fnlyrprj/screens/user_home.dart';
import 'package:lost_and_found_fnlyrprj/screens/welcome_screen.dart';
import 'auth_screens/login_screen.dart';
import 'screens/lost_screen.dart';
import 'screens/found_screen.dart';
import 'screens/user_reported_found_screen.dart';
import 'auth_screens/registration_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Color(0xFF643579),
        colorScheme: ColorScheme.fromSwatch().copyWith(
          secondary: Color(0xFFBB99CD),
          primary: Color(0xFF643579),
        ),
        scaffoldBackgroundColor: Colors.white,
        textTheme: TextTheme(
          titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          // was headline6
          bodyMedium: TextStyle(fontSize: 16), // was bodyText2
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        cardTheme: CardTheme(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
          margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF643579),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            textStyle: TextStyle(color: Colors.white),
          ),
        ),
        appBarTheme: AppBarTheme(
          elevation: 2,
          backgroundColor: Color(0xFF643579),
          titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      initialRoute: WelcomeScreen.id,
      routes: {
        WelcomeScreen.id: (context) => WelcomeScreen(),
        LostScreen.id: (context) => LostScreen(),
        FoundScreen.id: (context) => FoundScreen(),
        AdminPanelScreen.id: (context) => AdminPanelScreen(),
        AdminReportedItems.id: (context) => AdminReportedItems(),
        AdminReportedFoundItems.id: (context) => AdminReportedFoundItems(),
        ResolvedItemsScreen.id: (context) => ResolvedItemsScreen(),
        UserHome.id: (context) => UserHome(),
        UserReportedFoundScreen.id: (context) => UserReportedFoundScreen(),
        RegistrationScreen.id: (context) => RegistrationScreen(),
        LoginScreen.id: (context) => LoginScreen(),
        PendingApprovalsScreen.id: (context) => PendingApprovalsScreen(),
        ClaimRequestsScreen.id: (context) => ClaimRequestsScreen(),
        FavoritesScreen.id: (context) => FavoritesScreen(),
        NotificationsScreen.id: (context) => NotificationsScreen(),
        ProfileScreen.id: (context) => ProfileScreen(),
      },
    );
  }
}
