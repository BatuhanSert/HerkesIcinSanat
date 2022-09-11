import 'package:flutter/material.dart';

circularProgress() {
  return Container(
    alignment: Alignment.center,
    padding: EdgeInsets.only(top: 12.0),
    child: CircularProgressIndicator(
      valueColor: AlwaysStoppedAnimation(const Color(0xFFFBFBFB)),
    ),
  );
}

linearProgress() {
  return Container(
    alignment: Alignment.center,
    padding: EdgeInsets.only(top: 12.0),
    child: LinearProgressIndicator(
      backgroundColor: const Color(0xFF121212),
      valueColor: AlwaysStoppedAnimation(const Color(0xFFFBFBFB)),
    ),
  );
}
