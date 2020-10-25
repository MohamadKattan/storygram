import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:storygram/widget/headerWidget.dart';

class CreateAccountPage extends StatefulWidget {
  @override
  _CreateAccountPageState createState() => _CreateAccountPageState();
}

class _CreateAccountPageState extends State<CreateAccountPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  String userName;
// this method for velvet userName if true or false
  submitUsername(){
    final form = _formKey.currentState;
    if (form.validate()){
      form.save();
      SnackBar snackBar = SnackBar(content: Text('Welcome'+userName));
      _scaffoldKey.currentState.showSnackBar(snackBar);
      Timer(Duration(seconds: 4),(){
        Navigator.pop(context,userName);
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: header(context, strTitle: 'sitting', disSappredBackButton: true),
      body: ListView(
        children: [
          Container(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 25.0),
                  child: Text('Set up a username'),
                ),
                Padding(
                  padding: const EdgeInsets.all(17.0),
                  child: Container(
                    child: Form(
                      key: _formKey,
                      autovalidate: true,
                      child: TextFormField(
                        style: TextStyle(
                          color: Colors.white,
                        ),
                        validator: (val) {
                          if (val.trim().length < 5 || val.isEmpty) {
                            return 'User Name is very short';
                          } else {
                            if (val.trim().length > 15) {
                              return 'User Name is very long';
                            } else {
                              return null;
                            }
                          }
                        },
                        onSaved: (val) => userName = val,
                        decoration: InputDecoration(
                          enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey)),
                          focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white)),
                          border: OutlineInputBorder(),
                          labelText: 'UserName',
                          labelStyle: TextStyle(fontSize: 16.0),
                          hintText: 'type your name',
                          hintStyle: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                    onTap:submitUsername,
                    child: Container(
                      height: 55.0,
                      width: 360.0,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Center(
                        child: Text(
                          'Proceed',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    )),
              ],
            ),
          )
        ],
      ),
    );
  }
}
