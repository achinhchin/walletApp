import 'package:flutter/material.dart';

ThemeData theme(BuildContext context) {
  return Theme.of(context);
} 

class ColorThemeProvider extends ChangeNotifier {
  Color color = Colors.blue;
  set setColor(Color color) {
    this.color = color;
    notifyListeners();
  }
}
