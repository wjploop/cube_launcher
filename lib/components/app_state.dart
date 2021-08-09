import 'package:cube_launcher/main.dart';
import 'package:flutter/material.dart';

class AppData with ChangeNotifier{
  bool hadLoad =false;

  void loaded(){
    hadLoad =true;
    notifyListeners();
  }
}