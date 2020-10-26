import 'dart:io';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:storygram/models/User.dart';
import 'package:storygram/pages/homePage.dart';

class UpLoadPage extends StatefulWidget {
  //**this argment for got info user from home page=>pageview (so much important)
  final User gCurrentUser;
  UpLoadPage({this.gCurrentUser});
  //*********************************
  @override
  _UpLoadPageState createState() => _UpLoadPageState();
}

class _UpLoadPageState extends State<UpLoadPage> {
  File file;
  TextEditingController descriptionTextEditingController =
      TextEditingController();
  TextEditingController loctionTextEditingController = TextEditingController();

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
                onPressed: () => Navigator.pop(context),
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

  // this method for delete image i fuser dont want to add or update
  removeImage() {
    setState(() {
      // ignore: unnecessary_statements
      file == null;
    });
  }

  // this methoed for get user current location
  getUserCurrentLocation() async {
    Position position = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    List<Placemark> placemark = await Geolocator()
        .placemarkFromCoordinates(position.latitude, position.longitude);
    Placemark mplacemark = placemark[0];
    String completAddressInfo = '${mplacemark.subThoroughfare}'
        '${mplacemark.thoroughfare} ${mplacemark.subLocality} ${mplacemark.locality} ${mplacemark.subAdministrativeArea} ${mplacemark.administrativeArea} ${mplacemark.postalCode} ${mplacemark.country}';
    String specficAddress = '${mplacemark.country} ${mplacemark.locality} ${mplacemark.subAdministrativeArea}';
    loctionTextEditingController.text = specficAddress;
    print(specficAddress);
  }

// this method for share new post or cancel
  disPlauUploadFromScrren() {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Colors.lightGreenAccent,
            ),
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => HomePage()));
              removeImage();
            }),
        title: Text(
          'NewPost',
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20.0),
        ),
        actions: <Widget>[
          FlatButton(
            onPressed: () => 'tagge',
            child: Text(
              'Share',
              style: TextStyle(
                  color: Colors.lightGreenAccent,
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold),
            ),
          )
        ],
      ),
      body: ListView(
        children: <Widget>[
          Container(
              width: MediaQuery.of(context).size.width * 0.8,
              height: 230.0,
              child: Center(
                child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Container(
                        decoration: BoxDecoration(
                            image: DecorationImage(
                                image: FileImage(file), fit: BoxFit.cover)))),
              )),
          Padding(
            padding: EdgeInsets.only(top: 12.0),
          ),
          ListTile(
            leading: CircleAvatar(
              backgroundImage:
                  CachedNetworkImageProvider('${widget.gCurrentUser.photoUrl}'),
            ),
            title: Container(
              width: 250.0,
              child: TextField(
                decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'type your description',
                    hintStyle: TextStyle(color: Colors.white)),
                controller: descriptionTextEditingController,
                style: (TextStyle(color: Colors.white)),
              ),
            ),
          ),
          Divider(),
          ListTile(
            leading: Icon(
              Icons.person_pin_circle,
              color: Colors.white,
              size: 36.0,
            ),
            title: Container(
              width: 250.0,
              child: TextField(
                decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'type your location',
                    hintStyle: TextStyle(color: Colors.white)),
                controller: loctionTextEditingController,
                style: (TextStyle(color: Colors.white)),
              ),
            ),
          ),
          Container(
            width: 220.0,
            height: 110.0,
            alignment: Alignment.center,
            child: RaisedButton.icon(
                onPressed: getUserCurrentLocation,
                color: Colors.green,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(35.0)),
                icon: Icon(
                  Icons.location_on,
                  color: Colors.white,
                ),
                label: Text(
                  'your current location',
                  style: TextStyle(color: Colors.white),
                )),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return file == null ? disPlayUploadScreen() : disPlauUploadFromScrren();
  }
}
