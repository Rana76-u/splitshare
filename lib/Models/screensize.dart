import 'package:flutter/cupertino.dart';

class ScreenSize{

  double height(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  double width(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }
}