import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:storygram/models/User.dart';
import 'package:storygram/pages/homePage.dart';
import 'package:storygram/widget/progressWidget.dart';
import 'package:cached_network_image/cached_network_image.dart';

class EditProfilePage extends StatefulWidget {
  final currentOnlineUserId;
  EditProfilePage({this.currentOnlineUserId});

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  TextEditingController profileNameTextEditingController =
      TextEditingController();
  TextEditingController bioTextEditingController = TextEditingController();
  final _scaffoldGlobleKey = GlobalKey<ScaffoldState>();
  bool loading = false;
  User user;
  //if litter too much or not
  bool _bioValid = true;
  //if name is too short or not
  bool _profileNameValid = true;
  @override
  void initState() {
    super.initState();
    //for update
    getAndDisplayUserInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldGlobleKey,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text('EditProfile'),
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(
              Icons.done,
              color: Colors.white,
              size: 30.0,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: loading
          ? CircularProgres()
          : ListView(
              children: <Widget>[
                Container(
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(top: 15.0, bottom: 7.0),
                        child: CircleAvatar(
                          radius: 52.0,
                          backgroundImage:
                              CachedNetworkImageProvider(user.photoUrl),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Column(
                          children: <Widget>[
                            createProfileNameTextFormFailed(),
                            createBioTextFormFailed(),
                          ],
                        ),
                      ),
                      Padding(
                        padding:
                            EdgeInsets.only(top: 29.0, left: 50.0, right: 50.0),
                        child: RaisedButton(
                          color: Colors.grey,
                          onPressed: upDateUserdata,
                          child: Text(
                            'Update',
                            style:
                                TextStyle(color: Colors.black, fontSize: 16.0),
                          ),
                        ),
                      ),
                      Padding(
                        padding:
                            EdgeInsets.only(top: 10.0, left: 50.0, right: 50.0),
                        child: RaisedButton(
                          color: Colors.red,
                          onPressed: logOut,
                          child: Text(
                            'Logout',
                            style:
                                TextStyle(color: Colors.black, fontSize: 16.0),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
    );
  }

// for edite new name
  Column createProfileNameTextFormFailed() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 13.0),
          child: Text(
            'Profile Name',
            style: TextStyle(color: Colors.grey),
          ),
        ),
        TextField(
          controller: profileNameTextEditingController,
          decoration: (InputDecoration(
              hintText: 'Write Your User Name ',labelStyle: (TextStyle(color: Colors.white)),
              hintStyle: TextStyle(color: Colors.white),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.grey,
                ),
              ),
              focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white)),
              errorText: _profileNameValid ? null : 'UserName too much short')),
        ),
      ],
    );
  }

// for edite new bio
  Column createBioTextFormFailed() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 13.0),
          child: Text(
            'Bio Name',
            style: TextStyle(color: Colors.grey),
          ),
        ),
        TextField(
          controller: bioTextEditingController,
          decoration: (InputDecoration(
              hintText: 'Write Your Bio ',labelStyle: (TextStyle(color: Colors.white)),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.grey,
                ),
              ),
              focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white)),
              hintStyle: TextStyle(color: Colors.grey),
              errorText: _bioValid ? null : 'Bio too much long')),
        ),
      ],
    );
  }

// this for update data profileName
  upDateUserdata() {
    setState(() {
      profileNameTextEditingController.text.trim().length < 3 ||
              profileNameTextEditingController.text.isEmpty
          ? _profileNameValid = false
          : _profileNameValid = true;
      bioTextEditingController.text.length > 110
          ? _bioValid = false
          : _bioValid = true;
    });
    if (_bioValid && _profileNameValid) {
      usersReference.doc(widget.currentOnlineUserId).update({
        'username': profileNameTextEditingController.text,
        'bio': bioTextEditingController.text,
      });
      SnackBar snackBar = SnackBar(
        content: Text('Update is done'),
        backgroundColor: Colors.green,
      );
      _scaffoldGlobleKey.currentState.showSnackBar(snackBar);
    }
  }

// for updata
  getAndDisplayUserInfo() async {
    setState(() {
      loading = true;
    });
    DocumentSnapshot documentSnapshot =
        await usersReference.doc(widget.currentOnlineUserId).get();
    user = User.fromDocument(documentSnapshot);
    profileNameTextEditingController.text = user.username;
    bioTextEditingController.text = user.bio;
    setState(() {
      loading = false;
    });
  }

  // this for logOut
  logOut() async {
    await googleSignIn.signOut();
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => HomePage()));
  }
}
