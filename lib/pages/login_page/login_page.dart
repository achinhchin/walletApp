import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:wallet_app/theme/theme.dart';

//user management
import 'package:wallet_app/user_management/user_management.dart';

//pages
import 'package:wallet_app/pages/home_page/home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  double _blurController = 0;
  int loginState = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Sign in to',
                style: theme(context).textTheme.displaySmall,
              ),
              const SizedBox(height: 10),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'Wallet ',
                      style: theme(context).textTheme.displayMedium!.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[800],
                          ),
                    ),
                    TextSpan(
                      text: 'App',
                      style: theme(context).textTheme.displayMedium!.copyWith(
                            color: Colors.blue[900],
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              const SizedBox(
                height: 10,
              ),
              FloatingActionButton.extended(
                onPressed: () async {
                  setState(() {
                    _blurController = 1;
                  });
                  loginState = await UserManagement.login();
                  setState(() {
                    _blurController = 0;
                  });
                },
                label: const Text('Sign in with google'),
                icon: Image.asset(
                  "assets/icons/app-icon.png",
                  height: 32,
                  width: 32,
                ),
              ),
              const SizedBox(height: 15),
              Text(
                'with only @samsenwit.ac.th email.',
                style: TextStyle(color: Colors.red[400]),
              ),
            ],
          ),
        ),
      ),
    )
        .animate(
          onComplete: (controller) {
            if (loginState == 1) {
              Navigator.push(
                context,
                CupertinoPageRoute(
                  builder: (context) => const HomePage(),
                ),
              );
            } else if (loginState == -1) {
              Provider.of<ColorThemeProvider>(context, listen: false).setColor =
                  Colors.red;
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Stupid!!'),
                  content: const Text(
                      'I said you have to use only @samsenwit.ac.th email.'),
                  actions: [
                    ElevatedButton(
                      style: const ButtonStyle(
                          elevation: MaterialStatePropertyAll(0)),
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Ok'),
                    )
                  ],
                ),
              ).then(
                (value) => {
                  loginState = 0,
                  Provider.of<ColorThemeProvider>(context, listen: false)
                      .setColor = Colors.blue,
                },
              );
            }
          },
          autoPlay: false,
          target: _blurController,
        )
        .blur(
          begin: const Offset(0, 0),
          end: const Offset(5, 5),
        );
  }
}
