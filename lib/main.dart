import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:wallet_app/firebase/firebase_options.dart';
import 'package:provider/provider.dart';
import 'package:wallet_app/theme/theme.dart';

//pages
import './pages/login_page/login_page.dart';
import './pages/home_page/home_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ColorThemeProvider>(
      create: (_) => ColorThemeProvider(),
      builder: (context, child) => MaterialApp(
        theme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: Provider.of<ColorThemeProvider>(context).color,
        ),
        home: FirebaseAuth.instance.currentUser != null
            ? const HomePage()
            : const LoginPage(),
      ),
    );
  }
}
