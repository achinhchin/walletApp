import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:wallet_app/theme/theme.dart';

//models
import 'package:wallet_app/models/money_data_model.dart';

class TransactionTab extends StatefulWidget {
  MoneyDataModel moneyData;
  TransactionTab({super.key, required this.moneyData});

  @override
  State<TransactionTab> createState() => _TransactionTabState();
}

class _TransactionTabState extends State<TransactionTab> {
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
                  'Transaction',
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
          DataTable(
            columns: [
              DataColumn(
                  label: Text(
                'Date',
                style: theme(context)
                    .textTheme
                    .headlineSmall!
                    .copyWith(fontWeight: FontWeight.bold),
              )),
              DataColumn(
                  label: Text(
                'Type',
                style: theme(context)
                    .textTheme
                    .headlineSmall!
                    .copyWith(fontWeight: FontWeight.bold),
              )),
              DataColumn(
                  numeric: true,
                  label: Text(
                    'Total',
                    style: theme(context)
                        .textTheme
                        .headlineSmall!
                        .copyWith(fontWeight: FontWeight.bold),
                  )),
            ],
            rows: [
              if (widget.moneyData.moneyData != null)
                for (var value in widget.moneyData.moneyData!)
                  DataRow(
                    cells: [
                      DataCell(
                        Text(value.time),
                      ),
                      DataCell(
                        Text(value.type == 0
                            ? 'Topup'
                            : value.type == 1
                                ? 'Pay'
                                : value.type == -1
                                    ? 'Income'
                                    : 'undifined'),
                      ),
                      DataCell(
                        Text(
                          '${value.money.toString()} Baht',
                        ),
                      ),
                    ],
                  )
            ],
          )
        ],
      ),
    );
  }
}
