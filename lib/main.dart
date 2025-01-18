import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:provider/provider.dart';
import 'pages/home.dart';
import 'pages/login_page.dart';
import 'pages/profile.dart';
import 'pages/settings_pages.dart';
import 'pages/register_page.dart';
import 'provider/like_provider.dart';
import 'provider/comment_provider.dart';
import 'provider/share_provider.dart';
import 'models/user.dart' as app_user;
import 'firebase_options.dart';
import 'package:logging/logging.dart';

final Logger _logger = Logger('MyAppLogger');
void main() async {
  _logger.info('Application started');
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    log("test");
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LikeProvider()),
        ChangeNotifierProvider(create: (_) => CommentProvider()),
        ChangeNotifierProvider(create: (_) => ShareProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Social Network',
        initialRoute: '/',
        routes: {
          '/': (context) => AuthGate(),
          '/login': (context) => LoginPage(),
          '/register': (context) => RegisterPage(),
          '/home': (context) => MainScreen(),
        },
      ),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<firebase_auth.User?>(
      stream: firebase_auth.FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasData) {
          final user = snapshot.data!;
          if (user.isAnonymous) {
            print('Utilisateur connecté anonymement.');
          } else {
            print('Utilisateur connecté avec email : ${user.email}');
          }
          return MainScreen(); // Redirection vers l'écran principal
        } else {
          return LoginPage(); // Redirection vers la page de connexion
        }
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final firebase_auth.User? currentUser =
        firebase_auth.FirebaseAuth.instance.currentUser;

    // Conversion de firebase_auth.User en app_user.User
    final app_user.User user = app_user.User.fromFirebaseUser(currentUser!);

    final List<Widget> widgetOptions = <Widget>[
      const HomePage(),
      ProfilePage(
        user: user,
        userPosts: [], // Remplacez par la logique pour récupérer les posts de l'utilisateur
      ),
      SettingsPage(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Social Network'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await firebase_auth.FirebaseAuth.instance.signOut();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        onTap: _onItemTapped,
      ),
    );
  }
}
