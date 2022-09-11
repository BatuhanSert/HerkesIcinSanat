import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:herkes_icin_sanat/models/user.dart';
import 'package:herkes_icin_sanat/pages/HomePage.dart';
import 'package:herkes_icin_sanat/widgets/ProgressWidget.dart';
import 'package:image/image.dart' as ImD;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class UploadPage extends StatefulWidget {
  final Kullanici gCurrentUser;
  UploadPage({this.gCurrentUser});
  @override
  _UploadPageState createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage>
    with AutomaticKeepAliveClientMixin<UploadPage> {
  File file;
  bool uploading = false;
  String postId = Uuid().v4();
  double lat;
  double lon;

  TextEditingController descriptionTextEditingController =
      TextEditingController();
  TextEditingController locationTextEditingController = TextEditingController();
  TextEditingController priceTextEditingController = TextEditingController();

  captureImageWithCamera() async {
    Navigator.pop(context);
    PickedFile imageFile = await ImagePicker().getImage(
      source: ImageSource.camera,
      maxHeight: 680,
      maxWidth: 970,
    );
    setState(() {
      this.file = File(imageFile.path);
    });
  }

  pickImageFromGallery() async {
    Navigator.pop(context);
    PickedFile imageFile = await ImagePicker().getImage(
      source: ImageSource.gallery,
    );
    setState(() {
      this.file = File(imageFile.path);
    });
  }

  takeImage(mContext) {
    return showDialog(
      context: mContext,
      builder: (context) {
        return SimpleDialog(
          backgroundColor: Theme.of(context).accentColor,
          title: Text(
            "Yeni Post",
            style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 35.0,
              fontFamily: "Signatra",
            ),
          ),
          children: [
            SimpleDialogOption(
              child: Text(
                "Kamera",
                style: TextStyle(
                  color: const Color(0xFFFBFBFB),
                  fontSize: 25.0,
                ),
              ),
              onPressed: captureImageWithCamera,
            ),
            SimpleDialogOption(
              child: Text(
                "Galeri",
                style: TextStyle(
                  color: const Color(0xFFFBFBFB),
                  fontSize: 25.0,
                ),
              ),
              onPressed: pickImageFromGallery,
            ),
            SimpleDialogOption(
              child: Text(
                "İptal",
                style: TextStyle(
                  color: Colors.redAccent,
                  fontSize: 25.0,
                ),
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        );
      },
    );
  }

  displayUploadScreen() {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.add_photo_alternate,
            color: const Color(0xFFFBFBFB),
            size: 200.0,
          ),
          Padding(
            padding: EdgeInsets.only(top: 20.0),
            child: RaisedButton(
              onPressed: () => takeImage(context),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(9.0),
              ),
              child: Text(
                "Fotoğraf Yükle",
                style: TextStyle(
                    color: Theme.of(context).primaryColor, fontSize: 20.0),
              ),
              color: Theme.of(context).accentColor,
            ),
          ),
        ],
      ),
    );
  }

  clearPostInfo() {
    locationTextEditingController.clear();
    descriptionTextEditingController.clear();
    priceTextEditingController.clear();
    dropdownValue = 'Tür';

    setState(() {
      file = null;
      uploading = false;
      postId = Uuid().v4();
    });
  }

  getUserCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      await Geolocator.openAppSettings();
      await Geolocator.openLocationSettings();
      //return Future.error('Location services are disabled.');
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      await Geolocator.openAppSettings();
      await Geolocator.openLocationSettings();
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    List<Placemark> placeMarks =
        await placemarkFromCoordinates(position.latitude, position.longitude);
    Placemark mPlaceMark = placeMarks[0];
    String completeAddressInfo =
        '${mPlaceMark.subThoroughfare} ${mPlaceMark.thoroughfare}, ${mPlaceMark.subLocality} ${mPlaceMark.locality}, ${mPlaceMark.subAdministrativeArea} ${mPlaceMark.administrativeArea}, ${mPlaceMark.postalCode} ${mPlaceMark.country},';
    String specificAddress =
        '${mPlaceMark.thoroughfare}, ${mPlaceMark.administrativeArea}, ${mPlaceMark.country}';
    print(lat);
    print(lon);
    locationTextEditingController.text = specificAddress;
    setState(() {
      lat = position.latitude;
      lon = position.longitude;
    });
    print(lat);
    print(lon);
  }

  compressPhoto() async {
    final tDirectory = await getTemporaryDirectory();
    final path = tDirectory.path;
    ImD.Image mImageFile = ImD.decodeImage(file.readAsBytesSync());
    final compressedImageFile = File('$path/img_$postId.jpg')
      ..writeAsBytesSync(ImD.encodeJpg(mImageFile, quality: 60));
    setState(() {
      file = compressedImageFile;
    });
  }

  controlUploadAndSave() async {
    setState(() {
      uploading = true;
    });

    await compressPhoto();
    String downloadUrl = await uploadPhoto(file);
    print(downloadUrl);
    savePostInfoToFireStore(
        url: downloadUrl,
        location: locationTextEditingController.text,
        description: descriptionTextEditingController.text,
        price: priceTextEditingController.text
          ..replaceAll(new RegExp(r"\s+"), ""),
        type: dropdownValue);
    locationTextEditingController.clear();
    descriptionTextEditingController.clear();
    priceTextEditingController.clear();
    dropdownValue = "Tür";

    setState(() {
      file = null;
      uploading = false;
      postId = Uuid().v4();
    });
  }

  savePostInfoToFireStore(
      {String url,
      String location,
      String description,
      String price,
      String type}) {
    postReferences
        .doc(widget.gCurrentUser.id)
        .collection("usersPosts")
        .doc(postId)
        .set({
      "postId": postId,
      "ownerId": widget.gCurrentUser.id,
      "timestamp": DateTime.now(),
      "likes": {},
      "username": widget.gCurrentUser.username,
      "description": description,
      "location": location,
      "url": url,
      "price": price,
      "productType": type,
      "latitude": lat,
      "longitude": lon,
    });
    allPostReferences.doc(postId).set({
      "postId": postId,
      "ownerId": widget.gCurrentUser.id,
      "timestamp": DateTime.now(),
      "likes": {},
      "username": widget.gCurrentUser.username,
      "description": description,
      "location": location,
      "url": url,
      "price": price,
      "productType": type,
      "latitude": lat,
      "longitude": lon,
    });
  }

  Future<String> uploadPhoto(mImageFile) async {
    UploadTask mStorageUploadTask =
        storageReferences.child("post_$postId.jpg").putFile(mImageFile);
    var downloadUrl = await (await mStorageUploadTask).ref.getDownloadURL();
    //print("toString yazan----->" + downloadUrl.toString());
    //print("toString yazmayan----->" + downloadUrl);
    return downloadUrl;
  }

  String dropdownValue = 'Tür';
  displayUploadFormScreen() {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).accentColor,
        leading: IconButton(
            onPressed: clearPostInfo,
            icon: Icon(
              Icons.arrow_back,
              color: const Color(0xFFFBFBFB),
            )),
        title: Text(
          "Yeni Gönderi",
          style: TextStyle(
            fontSize: 24.0,
            color: const Color(0xFFFBFBFB),
            fontWeight: FontWeight.bold,
            fontFamily: "Signatra",
          ),
        ),
        actions: [
          TextButton(
            onPressed: uploading ? null : () => controlUploadAndSave(),
            child: Text(
              "Paylaş",
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontSize: 16.0,
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        children: [
          uploading ? linearProgress() : Text(""),
          Container(
            height: 230.0,
            width: MediaQuery.of(context).size.width * 0.8,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: FileImage(file),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 4.0),
          ),
          ListTile(
            leading: CircleAvatar(
              backgroundImage:
                  CachedNetworkImageProvider(widget.gCurrentUser.url),
            ),
            title: Container(
              width: 250.0,
              child: TextField(
                style: TextStyle(color: const Color(0xFFFBFBFB)),
                controller: descriptionTextEditingController,
                decoration: InputDecoration(
                  hintText: "Haydi! Bir şeyler söyleyin.",
                  hintStyle: TextStyle(color: const Color(0xFFFBFBFB)),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          Divider(),
          ListTile(
            leading: Icon(
              Icons.person_pin_circle,
              color: const Color(0xFFFBFBFB),
              size: 36.0,
            ),
            title: Container(
              width: 250.0,
              child: TextField(
                style: TextStyle(color: const Color(0xFFFBFBFB)),
                controller: locationTextEditingController,
                decoration: InputDecoration(
                  hintText: "Konum",
                  hintStyle: TextStyle(color: const Color(0xFFFBFBFB)),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          Divider(),
          ListTile(
            leading: Icon(
              Icons.account_balance_wallet_rounded,
              color: const Color(0xFFFBFBFB),
              size: 36.0,
            ),
            title: Container(
              width: 250.0,
              child: TextField(
                keyboardType: TextInputType.number,
                style: TextStyle(color: const Color(0xFFFBFBFB)),
                controller: priceTextEditingController,
                decoration: InputDecoration(
                  hintText: "Fiyat",
                  hintStyle: TextStyle(color: const Color(0xFFFBFBFB)),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          //Divider(),
          ListTile(
            leading: Text(
              "Tür: ",
              style: TextStyle(color: const Color(0xFFFBFBFB), fontSize: 22.0),
            ),
            title: DropdownButton(
              isExpanded: true,
              value: dropdownValue,
              icon: const Icon(Icons.arrow_downward),
              iconSize: 24,
              elevation: 16,
              style: const TextStyle(
                  color: const Color(0xFFFBFBFB), fontSize: 18.0),
              onChanged: (String newValue) {
                setState(() {
                  dropdownValue = newValue;
                });
              },
              items: <String>[
                'Tür',
                'Ahşap',
                'Cam',
                'Fotoğrafçılık',
                'Grafik',
                'Heykel',
                'Özgün Baskı',
                'Resim',
                'Seramik',
                'Süsleme',
                'Taş',
                'Eve Destek',
              ].map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ),
          Container(
            width: 220.0,
            height: 110.0,
            alignment: Alignment.center,
            child: RaisedButton.icon(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(35.0)),
              color: Theme.of(context).accentColor,
              icon: Icon(
                Icons.location_on,
                color: Theme.of(context).primaryColor,
              ),
              label: Text(
                "Mevcut Konumu Getir",
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                ),
              ),
              onPressed: getUserCurrentLocation,
            ),
          ),
        ],
      ),
    );
  }

  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    return file == null ? displayUploadScreen() : displayUploadFormScreen();
  }
}
