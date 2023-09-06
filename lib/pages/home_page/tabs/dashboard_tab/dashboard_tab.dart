import 'package:flutter/material.dart';
import 'package:wallet_app/user_management/user_management.dart';
import 'package:wallet_app/theme/theme.dart';
import 'package:firebase_auth/firebase_auth.dart';

//pages
import 'package:wallet_app/pages/login_page/login_page.dart';

class DashboardTab extends StatefulWidget {
  const DashboardTab({super.key});

  @override
  State<DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<DashboardTab> {
  User? user = FirebaseAuth.instance.currentUser;
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: Text(
                  'Dashboard',
                  style: theme(context).textTheme.headlineMedium!.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme(context).colorScheme.primary,
                      ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Text(
                  user!.displayName ?? '',
                  style: theme(context).textTheme.bodyLarge,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Material(
            shape: const CircleBorder(
              side: BorderSide(
                color: Colors.black,
                width: 1,
              ),
            ),
            color: theme(context).colorScheme.primaryContainer,
            child: SizedBox(
              width: 200,
              height: 200,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Balance',
                      style: theme(context).textTheme.displaySmall?.copyWith(
                            color: theme(context).colorScheme.primary,
                          ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '100 Baht',
                      style: theme(context).textTheme.headlineSmall,
                    )
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(onPressed: () {}, child: const Text('Topup')),
          const SizedBox(height: 20),
          ElevatedButton(onPressed: () {}, child: const Text('Pay')),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () async {
              await UserManagement.signOut();
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LoginPage(),
                  ),
                );
              }();
            },
            child: const Text('Sign Out'),
          )
        ],
      ),
    );
  }
}
