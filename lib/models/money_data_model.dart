class MoneyDataModel {
  List<EachMoneyDataModel>? moneyData;
}

class EachMoneyDataModel {
  String time;
  int type;
  int money;
  EachMoneyDataModel({
    required this.time,
    required this.type,
    required this.money,
  });
}
