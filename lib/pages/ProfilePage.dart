import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:herkes_icin_sanat/models/user.dart';
import 'package:herkes_icin_sanat/pages/EditProfilePage.dart';
import 'package:herkes_icin_sanat/pages/HomePage.dart';
import 'package:herkes_icin_sanat/widgets/HeaderWidget.dart';
import 'package:herkes_icin_sanat/widgets/PostTileWidget.dart';
import 'package:herkes_icin_sanat/widgets/PostWidget.dart';
import 'package:herkes_icin_sanat/widgets/ProgressWidget.dart';

class ProfilePage extends StatefulWidget {
  final String userProfileId;

  ProfilePage({this.userProfileId});
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final String currentOnlineUserId = currentUser?.id;
  bool loading = false;
  int countPost = 0;
  List<Post> postList = [];
  String postOrientation = "grid";
  int countTotalFollewers = 0;
  int countTotalFollewings = 0;
  bool following = false;

  void initState() {
    getAllProfilePosts();
    getAllFollowers();
    getAllFollowings();
    checkIfAlreadyFollowing();
  }

  getAllFollowers() async {
    QuerySnapshot querySnapshot = await followersReference
        .doc(widget.userProfileId)
        .collection("userFollowers")
        .get();
    setState(() {
      countTotalFollewers = querySnapshot.docs.length;
    });
  }

  getAllFollowings() async {
    QuerySnapshot querySnapshot = await followingReference
        .doc(widget.userProfileId)
        .collection("userFollowing")
        .get();
    setState(() {
      countTotalFollewings = querySnapshot.docs.length;
    });
  }

  checkIfAlreadyFollowing() async {
    DocumentSnapshot documentSnapshot = await followersReference
        .doc(widget.userProfileId)
        .collection("userFollowers")
        .doc(currentOnlineUserId)
        .get();
    setState(() {
      following = documentSnapshot.exists;
    });
  }

  createProfileTopView() {
    return FutureBuilder(
      future: userReferences.doc(widget.userProfileId).get(),
      builder: (context, dataSnapshot) {
        if (!dataSnapshot.hasData) {
          return circularProgress();
        } else {
          Kullanici user = Kullanici.fromDocument(dataSnapshot.data);
          return Padding(
            padding: EdgeInsets.all(17.0),
            child: Column(
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 45.0,
                      backgroundColor: Colors.grey,
                      backgroundImage: CachedNetworkImageProvider(user.url),
                    ),
                    Expanded(
                      flex: 1,
                      child: Column(
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              createColumns("Gönderi", countPost),
                              createColumns("Takipçi", countTotalFollewers),
                              createColumns("Takip", countTotalFollewings),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              createButton(),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(top: 13.0),
                  child: Text(
                    user.profileName,
                    style: TextStyle(
                      fontSize: 18.0,
                      color: const Color(0xFFFBFBFB),
                    ),
                  ),
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(top: 2.0),
                  child: Text(
                    user.username,
                    style: TextStyle(
                      fontSize: 14.0,
                      color: const Color(0xFFFBFBFB),
                    ),
                  ),
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(top: 2.0),
                  child: Text(
                    user.bio,
                    style: TextStyle(
                      fontSize: 14.0,
                      color: const Color(0xFFFBFBFB),
                    ),
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }

  //gönderi sayisi, takipçiler, takip ettikleri
  Column createColumns(String title, int count) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 20.0,
            color: const Color(0xFFFBFBFB),
            fontWeight: FontWeight.bold,
          ),
        ),
        Container(
          margin: EdgeInsets.only(top: 5.0),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14.0,
              color: Colors.grey,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }

  //takip et takibi bırak butonu
  createButton() {
    bool ownProfile = currentOnlineUserId == widget.userProfileId;
    if (ownProfile) {
      return createButtonTitleAndFunction(
        title: "Profili Düzenle",
        performFunction: editUserProfile,
      );
    } else if (following) {
      return createButtonTitleAndFunction(
        title: "Takibi Bırak",
        performFunction: controlUnfollowUser,
      );
    } else if (!following) {
      return createButtonTitleAndFunction(
        title: "Takip Et",
        performFunction: controlFollowUser,
      );
    }
  }

  controlUnfollowUser() {
    setState(() {
      following = false;
    });

    followersReference
        .doc(widget.userProfileId)
        .collection("userFollowers")
        .doc(currentOnlineUserId)
        .get()
        .then((document) {
      if (document.exists) {
        document.reference.delete();
      }
    });

    followingReference
        .doc(currentOnlineUserId)
        .collection("userFollowing")
        .doc(widget.userProfileId)
        .get()
        .then((document) {
      if (document.exists) {
        document.reference.delete();
      }
    });

    activityFeedReference
        .doc(widget.userProfileId)
        .collection("feedItems")
        .doc(currentOnlineUserId)
        .get()
        .then((document) {
      if (document.exists) {
        document.reference.delete();
      }
    });
    getAllFollowers();
  }

  controlFollowUser() {
    setState(() {
      following = true;
    });
    followersReference
        .doc(widget.userProfileId)
        .collection("userFollowers")
        .doc(currentOnlineUserId)
        .set({});
    followingReference
        .doc(currentOnlineUserId)
        .collection("userFollowing")
        .doc(widget.userProfileId)
        .set({});

    activityFeedReference
        .doc(widget.userProfileId)
        .collection("feedItems")
        .doc(currentOnlineUserId)
        .set({
      "type": "follow",
      "username": currentUser.username,
      "commentData": "",
      "postId": "",
      "userId": currentOnlineUserId,
      "userProfileImg": currentUser.url,
      "url": "",
      "timestamp": DateTime.now(),
      "ownerId": widget.userProfileId,
      "price": "",
      "productType": "",
      "latitude": "",
      "longitude": "",
    });
    getAllFollowers();
  }

  Container createButtonTitleAndFunction(
      {String title, Function performFunction}) {
    return Container(
      padding: EdgeInsets.only(top: 3.0),
      child: TextButton(
        onPressed: performFunction,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.55,
          height: 26.0,
          child: Text(
            title,
            style: TextStyle(
              color: following
                  ? Theme.of(context).primaryColor
                  : Theme.of(context).primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: following
                ? Theme.of(context).accentColor
                : Theme.of(context).accentColor,
            border: Border.all(
              color: Theme.of(context).accentColor,
            ),
            borderRadius: BorderRadius.circular(6.0),
          ),
        ),
      ),
    );
  }

  editUserProfile() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                EditProfilePage(currentOnlineUserId: currentOnlineUserId)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(
        context,
        strTitle: "Profil",
      ),
      body: ListView(
        children: [
          createProfileTopView(),
          Divider(),
          createListAndGridPostOrientation(),
          Divider(
            height: 0.0,
          ),
          displayProfilePost(),
        ],
      ),
    );
  }

  displayProfilePost() {
    if (loading) {
      return circularProgress();
    } else if (postList.isEmpty) {
      return Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.all(30.0),
              child: Icon(
                Icons.photo_library,
                color: const Color(0xFFFBFBFB),
                size: 200.0,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 20.0),
              child: Text(
                "Hiç Gönderi Yok",
                style: TextStyle(
                  color: Colors.redAccent,
                  fontSize: 40.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          ],
        ),
      );
    } else if (postOrientation == "grid") {
      List<GridTile> gridTilesList = [];
      postList.forEach((eachPost) {
        gridTilesList.add(GridTile(child: PostTile(eachPost)));
      });
      return GridView.count(
        crossAxisCount: 3,
        childAspectRatio: 1.0,
        mainAxisSpacing: 1.5,
        crossAxisSpacing: 1.5,
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        children: gridTilesList,
      );
    } else if (postOrientation == "list") {
      return Column(
        children: postList,
      );
    }
  }

  getAllProfilePosts() async {
    setState(() {
      loading = true;
    });
    QuerySnapshot querySnapshot = await postReferences
        .doc(widget.userProfileId)
        .collection("usersPosts")
        .orderBy("timestamp", descending: true)
        .get();
    setState(() {
      loading = false;
      countPost = querySnapshot.docs.length;
      postList = querySnapshot.docs
          .map((documentSnapshot) => Post.fromDocument(documentSnapshot))
          .toList();
    });
  }

  createListAndGridPostOrientation() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton(
          onPressed: () => setOrientation("grid"),
          icon: Icon(Icons.grid_on),
          color: postOrientation == "grid"
              ? Theme.of(context).primaryColor
              : Colors.grey,
        ),
        IconButton(
          onPressed: () => setOrientation("list"),
          icon: Icon(Icons.list),
          color: postOrientation == "list"
              ? Theme.of(context).primaryColor
              : Colors.grey,
        ),
      ],
    );
  }

  setOrientation(String orientation) {
    setState(() {
      this.postOrientation = orientation;
    });
  }
}
