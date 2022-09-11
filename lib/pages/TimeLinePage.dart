import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:herkes_icin_sanat/models/user.dart';
import 'package:herkes_icin_sanat/pages/HomePage.dart';
import 'package:herkes_icin_sanat/widgets/HeaderWidget.dart';
import 'package:herkes_icin_sanat/widgets/PostWidget.dart';
import 'package:herkes_icin_sanat/widgets/ProgressWidget.dart';

class TimeLinePage extends StatefulWidget {
  final Kullanici gCurrentUser;

  TimeLinePage({this.gCurrentUser});

  @override
  _TimeLinePageState createState() => _TimeLinePageState();
}

class _TimeLinePageState extends State<TimeLinePage> {
  List<Post> posts;
  List<String> followingsList = [];
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  retrieveTimeLine() async {
    QuerySnapshot querySnapshot = await timelineReference
        .doc(widget.gCurrentUser.id)
        .collection("timelinePosts")
        .orderBy("timestamp", descending: true)
        .get();
    List<Post> allPosts = querySnapshot.docs
        .map((document) => Post.fromDocument(document))
        .toList();

    setState(() {
      this.posts = allPosts;
    });
  }

  retrieveFollowings() async {
    QuerySnapshot querySnapshot = await followingReference
        .doc(currentUser.id)
        .collection("userFollowing")
        .get();
    setState(() {
      followingsList =
          querySnapshot.docs.map((document) => document.id).toList();
    });
  }

  @override
  void initState() {
    super.initState();

    retrieveTimeLine();
    retrieveFollowings();
  }

  createUserTimeLine() {
    if (posts == null) {
      return circularProgress();
    } else {
      return ListView(
        children: posts,
      );
    }
  }

  @override
  Widget build(context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: header(
        context,
        isAppTitle: true,
      ),
      body: RefreshIndicator(
        child: createUserTimeLine(),
        onRefresh: () => retrieveTimeLine(),
      ),
    );
  }
}
