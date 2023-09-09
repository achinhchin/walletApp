import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:wallet_app/models/money_data_model.dart';
import 'package:wallet_app/pages/home_page/tabs/transaction_tab/transaction_tab.dart';
import 'package:wallet_app/pages/login_page/login_page.dart';
import 'package:wallet_app/user_management/user_management.dart';
import 'package:wallet_app/theme/theme.dart';

//model

//tabs
import './tabs/dashboard_tab/dashboard_tab.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  User? user = FirebaseAuth.instance.currentUser;
  double _blurController = 0;
  int _tabIndex = 0;
  late TabController _tabController;
  Timer? serverPeriodic;
  MoneyDataModel moneyData = MoneyDataModel();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, initialIndex: 0, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _tabIndex = _tabController.index;
      });
    });

    FirebaseAuth.instance.currentUser!.getIdToken().then(
      (value) {
        if (value != null) {
          serverPeriodic = Timer.periodic(1.seconds, getMoneyData);
        }
      },
    );
  }

  Future<void> getMoneyData(Timer? timer) async {
    http.Response res = await http.post(
      Uri.parse('https://walletapp-server.vercel.app/server'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': '_',
      },
      body: jsonEncode({
        'type': 'get',
        'uid': user!.email,
      }),
    );
    moneyData.moneyData = [];
    List<dynamic> dres = json.decode(res.body);
    try {
      for (var value in dres) {
        moneyData.moneyData!.add(
          EachMoneyDataModel(
            time: value['time'],
            type: value['type'],
            money: value['money'],
          ),
        );
      }
    } catch (e) {}
    setState(() {});
  }

  @override
  void dispose() {
    serverPeriodic!.cancel();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: false,
          actions: [
            IconButton(
              onPressed: () {
                Provider.of<ColorThemeProvider>(context, listen: false)
                    .setColor = Colors.green;
                _blurController = 1;
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    barrierColor: Colors.black26,
                    opaque: false,
                    barrierDismissible: true,
                    pageBuilder: (contextm, animation, secondaryAnimation) =>
                        Material(
                      color: Colors.transparent,
                      child: AlertDialog(
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text('Profile'),
                            Hero(
                              tag: 'profile',
                              child: Material(
                                shape: const CircleBorder(),
                                elevation: 2,
                                color: Colors.transparent,
                                child: ClipOval(
                                  child: Image.network(
                                    user!.photoURL ?? '',
                                    width: 40,
                                    height: 40,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        content: Text(
                            'Name: ${user!.displayName}\nEmail: ${user!.email}'),
                        actions: [
                          ElevatedButton(
                            onPressed: () {
                              Provider.of<ColorThemeProvider>(
                                context,
                                listen: false,
                              ).setColor = Colors.blue;
                              UserManagement.signOut().then(
                                (value) => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const LoginPage(),
                                  ),
                                ),
                              );
                            },
                            child: const Text('Sign Out'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            style: const ButtonStyle(
                              elevation: MaterialStatePropertyAll(0),
                            ),
                            child: const Text('Done'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ).then(
                  (value) {
                    Provider.of<ColorThemeProvider>(context, listen: false)
                        .setColor = Colors.blue;
                    _blurController = 0;
                  },
                );
              },
              icon: Hero(
                tag: 'profile',
                child: ClipOval(
                  child: Image.network(user!.photoURL ?? ''),
                ),
              ),
            ),
          ],
          automaticallyImplyLeading: false,
          title: const Text('Wallet App'),
          backgroundColor: theme(context).colorScheme.surfaceVariant,
          elevation: 5,
        ),
        body: TabBarView(
          physics: const BouncingScrollPhysics(),
          controller: _tabController,
          children: [
            DashboardTab(
              moneyData: moneyData,
            ),
            TransactionTab(
              moneyData: moneyData,
            ),
          ],
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _tabIndex,
          onDestinationSelected: (value) => setState(() {
            _tabIndex = value;
            _tabController.index = value;
          }),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.dashboard_rounded),
              label: 'Dashboard',
            ),
            NavigationDestination(
              icon: Icon(Icons.grid_4x4_rounded),
              label: 'Transaction',
            ),
          ],
        ),
      )
          .animate(
            autoPlay: false,
            target: _blurController,
          )
          .blur(
            begin: const Offset(0, 0),
            end: const Offset(7, 7),
          ),
    );
  }
}
