import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UpLoadPage extends StatefulWidget {
  @override
  _UpLoadPageState createState() => _UpLoadPageState();
}

class _UpLoadPageState extends State<UpLoadPage> {
  File file;

// this method for pick image from gallery
  PickImageFromGallery() async {
    Navigator.pop(context);
    File imageFile = await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      this.file = imageFile;
    });
  }

  // this method for pickImage from camera
  CaptureImageWithCamera() async {
    Navigator.pop(context);
    File imageFile = await ImagePicker.pickImage(
        source: ImageSource.camera, maxHeight: 600, maxWidth: 970);
    setState(() {
      this.file = imageFile;
    });
  }

  // this method for switch between camera or gallery
  takeImage(mContext) {
    return showDialog(
        context: mContext,
        builder: (context) {
          return SimpleDialog(
            title: Text('NewPost',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
            children: <Widget>[
              SimpleDialogOption(
                child: Text(
                  'Capture Image with camera',
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: CaptureImageWithCamera,
              ),
              SimpleDialogOption(
                child: Text(
                  'Select Image from gallery',
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: PickImageFromGallery,
              ),
              SimpleDialogOption(
                child: Text(
                  'Cancel',
                  style: TextStyle(color: Colors.white),
                ),
                onPressed:()=> Navigator.pop(context),
              ),
            ],
          );
        });
  }

  // this method for starting pick an Image
  disPlayUploadScreen() {
    return Container(
      color: Theme.of(context).accentColor.withOpacity(0.5),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(
            Icons.add_photo_alternate,
            color: Colors.grey,
            size: 200.0,
          ),
          Padding(
            padding: EdgeInsets.only(top: 20.0),
            child: RaisedButton(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(9.0)),
              child: Text('Upload Image',
                  style: TextStyle(color: Colors.white, fontSize: 20.0)),
              color: Colors.green,
              onPressed: () => takeImage(context),
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return disPlayUploadScreen();
  }
}
