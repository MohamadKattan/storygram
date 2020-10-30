import 'dart:io';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:storygram/constent.dart';
import 'package:storygram/models/User.dart';
import 'package:storygram/pages/homePage.dart';
import 'package:storygram/widget/progressWidget.dart';
import 'package:uuid/uuid.dart';
import 'package:image/image.dart' as Imd;

class UpLoadPage extends StatefulWidget {
  //**this argment for got info user from home page=>pageview (so much important)
  final User gCurrentUser;
  UpLoadPage({this.gCurrentUser});
  //*********************************
  String path;
  @override
  _UpLoadPageState createState() => _UpLoadPageState();
}

class _UpLoadPageState extends State<UpLoadPage> {
  File file;

  // for botton share
  bool uploading = false;

  // this verbal for give id user post
  String postId = Uuid().v4();
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
  clearPostInfo() {
    loctionTextEditingController.clear();
    descriptionTextEditingController.clear();
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
    String specficAddress =
        '${mplacemark.country} ${mplacemark.locality} ${mplacemark.subAdministrativeArea}';
    loctionTextEditingController.text = specficAddress;
    print(specficAddress);
  }

  // this method for compressing Photot
  comPressingPhoto() async {
    final tempDir = await getTemporaryDirectory();
    final path = tempDir.path;
    Imd.Image mImageFile = Imd.decodeImage(file.readAsBytesSync());
    final compressingImageFile = File('$path/img_$postId.jpg')
      ..writeAsBytesSync(Imd.encodeJpg(mImageFile, quality: 90));
    setState(() {
      file = compressingImageFile;
    });
  }

  // this method for starting upload photo to storage fire base
  uploadPhoto(mImageFile) async {
    StorageUploadTask mStorageUploadTask =
        storageReference.child('post_$postId.jpg').putFile(mImageFile);
    StorageTaskSnapshot storageTaskSnapshot =
        await mStorageUploadTask.onComplete;
    String downloadUrl = await storageTaskSnapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  // this method for uoload to firestore
  savePostInfoToFireStore(
      {String url, String location, String description}) async {
    postsReference
        .doc(widget.gCurrentUser.id)
        .collection(kuserPostscollection)
        .doc(postId)
        .set({
      kpostID: postId,
      kownerID: widget.gCurrentUser.id,
      ktime: timestamp,
      kUsername: widget.gCurrentUser.username,
      klikes: {},
      kdescription: description,
      klocation: location,
      kurl: url,
    });
  }

// this method for switch uploading to true and start compersing photo for upload to storage and fireStore
  controlUploadingAndSave() async {
    setState(() {
      uploading = true;
    });
    await comPressingPhoto();
    String downloadUrl = await uploadPhoto(file);
    savePostInfoToFireStore(
        url: downloadUrl,
        location: loctionTextEditingController.text,
        description: descriptionTextEditingController.text);
    loctionTextEditingController.clear();
    descriptionTextEditingController.clear();
    setState(() {
      file = null;
      uploading = false;
      postId = Uuid().v4();
    });
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
              clearPostInfo();
            }),
        title: Text(
          'NewPost',
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20.0),
        ),
        actions: <Widget>[
          FlatButton(
            onPressed: uploading ? null : () => controlUploadingAndSave(),
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
          uploading ? linerProgres() : Text(''),
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
