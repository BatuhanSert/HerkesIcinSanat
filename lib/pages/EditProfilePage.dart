import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import "package:flutter/material.dart";
import 'package:flutter/services.dart';
import 'package:herkes_icin_sanat/models/user.dart';
import 'package:herkes_icin_sanat/pages/HomePage.dart';
import 'package:herkes_icin_sanat/widgets/ProgressWidget.dart';

class EditProfilePage extends StatefulWidget {
  final String currentOnlineUserId;
  EditProfilePage({this.currentOnlineUserId});
  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  TextEditingController profileNameTextEditingController =
      TextEditingController();
  TextEditingController bioTextEditingController = TextEditingController();
  final _scaffoldGlobalKey = GlobalKey<ScaffoldState>();
  bool loading = false;
  Kullanici user;
  bool _bioValid = true;
  bool _profileNameValid = true;

  //android onstart çalışması gibi
  void initState() {
    super.initState();

    getAndDisplayUserInformation();
  }

  getAndDisplayUserInformation() async {
    setState(() {
      loading = true;
    });

    DocumentSnapshot documentSnapshot =
        await userReferences.doc(widget.currentOnlineUserId).get();
    user = Kullanici.fromDocument(documentSnapshot);

    profileNameTextEditingController.text = user.profileName;
    bioTextEditingController.text = user.bio;

    setState(() {
      loading = false;
    });
  }

  updateUserData() {
    setState(() {
      profileNameTextEditingController.text.trim().length < 3 ||
              profileNameTextEditingController.text.isEmpty
          ? _profileNameValid = false
          : _profileNameValid = true;

      bioTextEditingController.text.trim().length > 110
          ? _bioValid = false
          : _bioValid = true;
    });

    if (_bioValid && _profileNameValid) {
      userReferences.doc(widget.currentOnlineUserId).update({
        "profileName": profileNameTextEditingController.text,
        "bio": bioTextEditingController.text,
      });
      SnackBar successSnackBar =
          SnackBar(content: Text("Profil başarıyla güncellendi."));
      //ScaffoldMessenger.of(context).showSnackBar(successSnackBar);
      _scaffoldGlobalKey.currentState.showSnackBar(successSnackBar);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldGlobalKey,
      appBar: AppBar(
        backgroundColor: Theme.of(context).accentColor,
        iconTheme: IconThemeData(color: const Color(0xFFFBFBFB)),
        title: Text(
          "Profil Düzenle",
          style: TextStyle(
            color: const Color(0xFFFBFBFB),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Icons.done,
              color: Theme.of(context).primaryColor,
              size: 30.0,
            ),
          ),
        ],
      ),
      body: loading
          ? circularProgress()
          : ListView(
              children: [
                Container(
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: 16.0, bottom: 7.0),
                        child: CircleAvatar(
                          radius: 52.0,
                          backgroundImage: CachedNetworkImageProvider(user.url),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            createProfileNameTextFormField(),
                            createBioTextFormField(),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 20.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                primary: Theme.of(context).accentColor,
                              ),
                              onPressed: updateUserData,
                              child: Text(
                                "          Güncelle          ",
                                style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontSize: 16.0,
                                ),
                              ),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                primary: Theme.of(context).accentColor,
                              ),
                              onPressed: logoutUser,
                              child: Text(
                                "Hesaptan Çıkış Yap",
                                style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontSize: 16.0,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  logoutUser() async {
    await gSignIn.signOut();
    SystemNavigator.pop();
    // Navigator.push(
    //     context, MaterialPageRoute(builder: (context) => HomePage()));
  }

  Column createProfileNameTextFormField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 13.0),
          child: Text(
            "İsim",
            style: TextStyle(color: const Color(0xFFFBFBFB)),
          ),
        ),
        TextField(
          style: TextStyle(
            color: Colors.white,
          ),
          controller: profileNameTextEditingController,
          decoration: InputDecoration(
            hintText: "isim",
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: const Color(0xFFFBFBFB)),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: const Color(0xFFFBFBFB)),
            ),
            hintStyle: TextStyle(color: const Color(0xFFFBFBFB)),
            errorText: _profileNameValid ? null : "İsim çok kısa.",
          ),
        ),
      ],
    );
  }

  Column createBioTextFormField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 13.0),
          child: Text(
            "Bio",
            style: TextStyle(color: const Color(0xFFFBFBFB)),
          ),
        ),
        TextField(
          style: TextStyle(
            color: const Color(0xFFFBFBFB),
          ),
          controller: bioTextEditingController,
          decoration: InputDecoration(
            hintText: "bio",
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: const Color(0xFFFBFBFB)),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: const Color(0xFFFBFBFB)),
            ),
            hintStyle: TextStyle(color: const Color(0xFFFBFBFB)),
            errorText: _bioValid ? null : "Bio çok uzun.",
          ),
        ),
      ],
    );
  }
}
