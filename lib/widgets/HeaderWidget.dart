import 'package:flutter/material.dart';

AppBar header(context,
    {bool isAppTitle = false, String strTitle, disappearedBackButton = false}) {
  return AppBar(
    iconTheme: IconThemeData(
      color: const Color(0xFFFFC68A),
    ),
    automaticallyImplyLeading: disappearedBackButton ? false : true,
    title: Text(
      isAppTitle ? "HIS" : strTitle,
      style: TextStyle(
        color: const Color(0xFFFFC68A),
        fontFamily: "Signatra",
        fontSize: 45.0,
      ),
      overflow: TextOverflow.ellipsis,
    ),
    centerTitle: true,
    backgroundColor: Theme.of(context).accentColor,
  );
}
