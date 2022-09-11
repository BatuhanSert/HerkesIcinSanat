import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:herkes_icin_sanat/models/user.dart';
import 'package:herkes_icin_sanat/pages/HomePage.dart';
import 'package:herkes_icin_sanat/pages/ProfilePage.dart';
import 'package:herkes_icin_sanat/widgets/ProgressWidget.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage>
    with AutomaticKeepAliveClientMixin<SearchPage> {
  TextEditingController searchTextEditingController = TextEditingController();
  Future<QuerySnapshot> futureSearchResult;

  emptyTheTextFormField() {
    searchTextEditingController.clear();
  }

  controlSearching(String str) {
    if (str.isNotEmpty) {
      if (str.contains("@")) {
        Future<QuerySnapshot> allUsers =
            userReferences.where("username", isGreaterThanOrEqualTo: str).get();
        setState(() {
          futureSearchResult = allUsers;
        });
      } else {
        Future<QuerySnapshot> allUsers = userReferences
            .where("profileName", isGreaterThanOrEqualTo: str)
            .get();
        setState(() {
          futureSearchResult = allUsers;
        });
      }
    }
  }

  AppBar searchPageHeader() {
    return AppBar(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      title: TextFormField(
        style: TextStyle(
          fontSize: 18.0,
          color: const Color(0xFFFBFBFB),
        ),
        controller: searchTextEditingController,
        decoration: InputDecoration(
          hintText: "@Kullanıcıadı veya isim giriniz",
          hintStyle: TextStyle(
            color: const Color(0xFFFBFBFB),
          ),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              color: const Color(0xFFFBFBFB),
            ),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              color: const Color(0xFFFBFBFB),
            ),
          ),
          filled: true,
          prefixIcon: Icon(
            Icons.person_pin,
            color: Theme.of(context).primaryColor,
            size: 30.0,
          ),
          /*suffixIcon: IconButton(
              onPressed: emptyTheTextFormField,
              icon: Icon(
                Icons.clear,
                color: Colors.white,
              )),*/
        ),
        //onChanged: controlSearching,
        onFieldSubmitted: controlSearching,
      ),
    );
  }

  Container displayNoSearchResultScreen() {
    final Orientation orientation = MediaQuery.of(context).orientation;
    return Container(
      color: Theme.of(context).accentColor,
      child: Center(
        child: ListView(
          shrinkWrap: true,
          children: [
            Icon(
              Icons.group,
              color: const Color(0xFFFBFBFB),
              size: 200.0,
            ),
            Text(
              "Kullanıcı Arama.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: const Color(0xFFFBFBFB),
                fontWeight: FontWeight.w500,
                fontSize: 65.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  displayUsersFoundScreen() {
    return FutureBuilder(
      future: futureSearchResult,
      builder: (context, dataSnapShot) {
        if (!dataSnapShot.hasData) {
          return circularProgress();
        } else {
          List<UserResult> searchUsersResult = [];
          dataSnapShot.data.docs.forEach((document) {
            Kullanici eachUser = Kullanici.fromDocument(document);
            UserResult userResult = UserResult(eachUser);
            searchUsersResult.add(userResult);
          });
          return ListView(children: searchUsersResult);
        }
      },
    );
  }

  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: searchPageHeader(),
      body: futureSearchResult == null
          ? displayNoSearchResultScreen()
          : displayUsersFoundScreen(),
    );
  }
}

class UserResult extends StatelessWidget {
  final Kullanici eachUser;
  UserResult(this.eachUser);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(4.0),
      child: Container(
        color: Colors.white54,
        child: Column(
          children: [
            GestureDetector(
              onTap: () =>
                  displayUserProfile(context, userProfileId: eachUser.id),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.black,
                  backgroundImage: CachedNetworkImageProvider(eachUser.url),
                ),
                title: Text(
                  eachUser.profileName,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  eachUser.username,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 13.0,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  displayUserProfile(BuildContext context, {String userProfileId}) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ProfilePage(
                  userProfileId: userProfileId,
                )));
  }
}
