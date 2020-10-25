import 'package:flutter/material.dart';
// this class for name AppBar and change between name AppBar same Page
AppBar header(context,
    {bool isAppTitle = false, String strTitle, disSappredBackButton = false}) {
  return AppBar(
    iconTheme: IconThemeData(color: Colors.white),
    automaticallyImplyLeading: disSappredBackButton ? false : true,
    title: Text(
      isAppTitle ? 'Story' : strTitle,
      style: TextStyle(
          fontSize: isAppTitle ? 45.0 : 22.0,
          color: Colors.white,
          fontFamily: isAppTitle ? 'Lobster' : ''),
      overflow: TextOverflow.ellipsis,

    ),
    backgroundColor: Theme.of(context).accentColor,
  );
}
