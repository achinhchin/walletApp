import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:wallet_app/theme/theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:nfc_manager/nfc_manager.dart';

//models
import 'package:wallet_app/models/money_data_model.dart';

class DashboardTab extends StatefulWidget {
  MoneyDataModel moneyData;

  DashboardTab({
    super.key,
    required this.moneyData,
  });

  @override
  State<DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<DashboardTab> {
  User? user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
  }

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
                      '${widget.moneyData.moneyData?[widget.moneyData.moneyData!.length - 1].money ?? 0} Baht',
                      textAlign: TextAlign.center,
                      style: theme(context).textTheme.headlineSmall,
                    )
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              showDialog(context: context, builder: (context) => const Topup());
            },
            child: const Text('Topup'),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () async {
              if (await checkNFC(context)) {
                showDialog(
                    context: context, builder: (context) => const GetMoney());
              }
            },
            child: const Text('Get Money'),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
              onPressed: () async {
                if (await checkNFC(context)) {
                  showDialog(
                      context: context, builder: (context) => const Pay());
                }
              },
              child: const Text('Pay')),
        ],
      ),
    );
  }

  Future<bool> checkNFC(context) async {
    if (!(await NfcManager.instance.isAvailable())) {
      Provider.of<ColorThemeProvider>(context, listen: false).setColor =
          Colors.red;
      await showDialog(
          context: context,
          builder: (context) => AlertDialog(
                title: const Text('Stupid!!'),
                content: const Text(
                    'Your device is not support NFC or you forgot to turn it on.'),
                actions: [
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ButtonStyle(
                      elevation: MaterialStateProperty.all(0),
                    ),
                    child: const Text('Ok'),
                  )
                ],
              ));
      Provider.of<ColorThemeProvider>(context, listen: false).setColor =
          Colors.blue;
      return false;
    }
    return true;
  }
}

class Topup extends StatefulWidget {
  const Topup({super.key});

  @override
  State<Topup> createState() => _TopupState();
}

class _TopupState extends State<Topup> {
  final _formKey = GlobalKey<FormState>();
  int amount = 0;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Topup'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              validator: (value) {
                if (value == null ||
                    int.tryParse(value) == null ||
                    int.parse(value) <= 0) {
                  return 'Amount has to be a ( > 0)-number ';
                }
                amount = int.parse(value);
                return null;
              },
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 10),
                suffixText: 'Baht',
                labelText: 'Amount',
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  await http.post(
                    Uri.parse('https://walletapp-server.vercel.app/server'),
                    headers: {
                      'Content-Type': 'application/json',
                      'Authorization': '_',
                    },
                    body: jsonEncode({
                      'type': 'topup',
                      'uid': FirebaseAuth.instance.currentUser!.email,
                      'amount': amount,
                    }),
                  );
                  () {
                    Navigator.pop(context);
                  }();
                }
              },
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}

class GetMoney extends StatefulWidget {
  const GetMoney({super.key});

  @override
  State<GetMoney> createState() => _GetMoneyState();
}

class _GetMoneyState extends State<GetMoney> {
  final _formKey = GlobalKey<FormState>();
  int amount = 0;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Get Money'),
      content: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Touch other device to get their money.'),
          SizedBox(
            height: 10,
          ),
          Icon(
            Icons.nfc_rounded,
            size: 75,
          ),
        ],
      ),
      actions: [
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          style: ButtonStyle(elevation: MaterialStateProperty.all(0)),
          child: const Text('Done'),
        )
      ],
    );
  }
}

class Pay extends StatefulWidget {
  const Pay({super.key});

  @override
  State<Pay> createState() => _PayState();
}

class _PayState extends State<Pay> {
  final _formKey = GlobalKey<FormState>();
  int amount = 0;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Pay'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              validator: (value) {
                if (value == null ||
                    int.tryParse(value) == null ||
                    int.parse(value) <= 0) {
                  return 'Amount has to be a ( > 0)-number ';
                }
                amount = int.parse(value);
                return null;
              },
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 10),
                suffixText: 'Baht',
                labelText: 'Amount',
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  await http.post(
                    Uri.parse('https://walletapp-server.vercel.app/server'),
                    headers: {
                      'Content-Type': 'application/json',
                      'Authorization': '_',
                    },
                    body: jsonEncode({
                      'type': 'topup',
                      'uid': FirebaseAuth.instance.currentUser!.email,
                      'amount': amount,
                    }),
                  );
                  () {
                    Navigator.pop(context);
                  }();
                }
              },
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
