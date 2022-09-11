import 'dart:async';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/material.dart';
import 'package:herkes_icin_sanat/models/user.dart';
import 'package:herkes_icin_sanat/pages/CommentsPage.dart';
import 'package:herkes_icin_sanat/pages/HomePage.dart';
import 'package:herkes_icin_sanat/pages/ProfilePage.dart';
import 'package:herkes_icin_sanat/widgets/ProgressWidget.dart';
import 'package:square_in_app_payments/in_app_payments.dart';
import 'package:square_in_app_payments/models.dart';

class Post extends StatefulWidget {
  final String postId;
  final String ownerId;
  final dynamic likes;
  final String username;
  final String description;
  final String location;
  final String url;
  final String price;
  final String productType;
  final double latitude;
  final double longitude;

  Post({
    this.postId,
    this.ownerId,
    this.likes,
    this.username,
    this.description,
    this.location,
    this.url,
    this.price,
    this.productType,
    this.latitude,
    this.longitude,
  });

  factory Post.fromDocument(DocumentSnapshot documentSnapshot) {
    return Post(
      postId: documentSnapshot["postId"],
      ownerId: documentSnapshot["ownerId"],
      //timestamp: documentSnapshot["timestamp"],
      likes: documentSnapshot["likes"],
      username: documentSnapshot["username"],
      description: documentSnapshot["description"],
      location: documentSnapshot["location"],
      url: documentSnapshot["url"],
      price: documentSnapshot["price"],
      productType: documentSnapshot["productType"],
      latitude: documentSnapshot["latitude"],
      longitude: documentSnapshot["longitude"],
    );
  }

  factory Post.fromElements(Post posts) {
    return Post(
      postId: posts.postId,
      ownerId: posts.ownerId,
      //timestamp: documentSnapshot["timestamp"],
      likes: posts.likes,
      username: posts.username,
      description: posts.description,
      location: posts.location,
      url: posts.url,
      price: posts.price,
      productType: posts.productType,
      latitude: posts.latitude,
      longitude: posts.longitude,
    );
  }

  int getTotalNumberOfLikes(likes) {
    if (likes == null) {
      return 0;
    }
    int counter = 0;
    likes.values.forEach((eachValue) {
      if (eachValue == true) {
        counter += 1;
      }
    });
    return counter;
  }

  @override
  _PostState createState() => _PostState(
      postId: this.postId,
      ownerId: this.ownerId,
      likes: this.likes,
      username: this.username,
      description: this.description,
      location: this.location,
      url: this.url,
      likeCount: getTotalNumberOfLikes(this.likes),
      price: this.price,
      productType: this.productType,
      latitude: this.latitude,
      longitude: this.longitude);
}

class _PostState extends State<Post> {
  final String postId;
  final String ownerId;
  Map likes;
  final String username;
  final String description;
  final String location;
  final String url;
  final double latitude;
  final double longitude;

  int likeCount;
  final String price;
  final String productType;
  bool isLiked;
  bool showHeart = false;
  final String currentOnlineUserId = currentUser?.id;

  _PostState({
    this.postId,
    this.ownerId,
    this.likes,
    this.username,
    this.description,
    this.location,
    this.url,
    this.likeCount,
    this.price,
    this.productType,
    this.latitude,
    this.longitude,
  });

  @override
  Widget build(BuildContext context) {
    isLiked = (likes[currentOnlineUserId] == true);
    return Padding(
      padding: EdgeInsets.only(top: 3.0),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          createPostHead(),
          createPostPicture(),
          createPostFooter(),
        ],
      ),
    );
  }

  createPostHead() {
    return Container(
      color: const Color(0xFF2D2D2D),
      child: FutureBuilder(
        future: userReferences.doc(ownerId).get(),
        builder: (context, dataSnapshot) {
          if (!dataSnapshot.hasData) {
            return circularProgress();
          }
          Kullanici user = Kullanici.fromDocument(dataSnapshot.data);
          bool isPostOwner = currentOnlineUserId == ownerId;
          return ListTile(
            leading: CircleAvatar(
              backgroundImage: CachedNetworkImageProvider(user.url),
              backgroundColor: const Color(0xFFFBFBFB),
            ),
            title: GestureDetector(
              onTap: () => displayUserProfile(context, userProfileId: user.id),
              child: Text(
                user.username,
                style: TextStyle(
                    color: const Color(0xFFFBFBFB),
                    fontWeight: FontWeight.bold),
              ),
            ),
            subtitle: Text(
              location,
              style: TextStyle(
                color: const Color(0xFFFBFBFB),
              ),
            ),
            trailing: isPostOwner
                ? IconButton(
                    icon: Icon(
                      Icons.more_vert,
                      color: const Color(0xFFFBFBFB),
                    ),
                    onPressed: () => print("deleted"),
                  )
                : Text(""),
          );
        },
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

  final FirebaseAnalytics analytics = FirebaseAnalytics();
  FirebaseAnalyticsObserver getAnalyticsObserver() =>
      FirebaseAnalyticsObserver(analytics: analytics);
  _sendAnalyticsEvent() async {
    _testSetUserId();
    await analytics.logEvent(
      name: "liked_post",
      parameters: <String, dynamic>{
        'userId': currentOnlineUserId,
        'postId': postId,
        'productType': productType,
        'price': price
      },
    );
  }

  Future<void> _testSetUserId() async {
    await analytics.setUserId(currentOnlineUserId);
  }

  removeLike() {
    bool isNotPostOwner = currentOnlineUserId != ownerId;

    if (isNotPostOwner) {
      activityFeedReference
          .doc(ownerId)
          .collection("feedItems")
          .doc(postId)
          .get()
          .then((document) {
        if (document.exists) {
          document.reference.delete();
        }
      });
    }
  }

  addLike() async {
    bool isNotPostOwner = currentOnlineUserId != ownerId;

    if (isNotPostOwner) {
      await analytics.setUserId(currentOnlineUserId).then((value) async {
        await analytics.logEvent(
          name: "liked_post",
          parameters: <String, dynamic>{
            'userId': currentOnlineUserId,
            'postId': postId,
            'productType': productType,
            'price': price
          },
        ).then((value) {
          activityFeedReference
              .doc(ownerId)
              .collection("feedItems")
              .doc(postId)
              .set({
            "username": currentUser.username,
            "type": "like",
            "commentData": "",
            "postId": postId,
            "userId": currentUser.id,
            "userProfileImg": currentUser.url,
            "url": url,
            "timestamp": DateTime.now(),
            "price": price,
            "productType": productType,
            "latitude": latitude,
            "longitude": longitude
          });
        });
      });
    }
  }

  controlUserLikePost() {
    bool _liked = likes[currentOnlineUserId] == true;

    if (_liked) {
      allPostReferences
          .doc(postId)
          .update({"likes.$currentOnlineUserId": false});
      postReferences
          .doc(ownerId)
          .collection("usersPosts")
          .doc(postId)
          .update({"likes.$currentOnlineUserId": false});
      removeLike();
      setState(() {
        likeCount -= 1;
        isLiked = false;
        likes[currentOnlineUserId] = false;
      });
    } else if (!_liked) {
      postReferences
          .doc(ownerId)
          .collection("usersPosts")
          .doc(postId)
          .update({"likes.$currentOnlineUserId": true});
      allPostReferences
          .doc(postId)
          .update({"likes.$currentOnlineUserId": true});
      addLike();

      setState(() {
        likeCount += 1;
        isLiked = true;
        likes[currentOnlineUserId] = true;
        showHeart = true;
      });
      Timer(Duration(milliseconds: 800), () {
        setState(() {
          showHeart = false;
        });
      });
    }
  }

  createPostPicture() {
    return Container(
      color: const Color(0xFF2D2D2D),
      child: GestureDetector(
        onDoubleTap: () => controlUserLikePost(),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Image.network(url),
            showHeart
                ? Icon(
                    Icons.favorite,
                    size: 140.0,
                    color: const Color(0xFFFFC68A),
                  )
                : Text(""),
          ],
        ),
      ),
    );
  }

  void _pay() async {
    InAppPayments.setSquareApplicationId(
        'sandbox-sq0idb-LPWjMZ6SFJgEMpAZM_j-Mw');
    InAppPayments.startCardEntryFlow(
      onCardNonceRequestSuccess: _cardNonceRequestSuccess,
      onCardEntryCancel: _cardEntryCancel,
    );
  }

  void _cardEntryCancel() {
    //cancelled card entry
  }
  void _cardNonceRequestSuccess(CardDetails result) {
    print(result.nonce);
    InAppPayments.completeCardEntry(onCardEntryComplete: _cardEntryComplete);
  }

  void _cardEntryComplete() {
    //success
  }

  createPostFooter() {
    return Container(
      color: const Color(0xFF2D2D2D),
      //height: 15.0,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(padding: EdgeInsets.only(top: 40.0, left: 20.0)),
              GestureDetector(
                onTap: () => controlUserLikePost(),
                child: Icon(
                  isLiked ? Icons.favorite : Icons.favorite_border,
                  size: 28.0,
                  color: const Color(0xFFFFC68A),
                ),
              ),
              Padding(padding: EdgeInsets.only(right: 20.0)),
              GestureDetector(
                onTap: () => _pay(),
                child: Icon(
                  Icons.payment,
                  size: 28.0,
                  color: const Color(0xFFFBFBFB),
                ),
              ),
              GestureDetector(
                onTap: () => _pay(),
                child: Text(
                  "$price tl",
                  style: TextStyle(
                      color: const Color(0xFFFBFBFB),
                      fontWeight: FontWeight.bold),
                ),
              ),
              Padding(padding: EdgeInsets.only(right: 20.0)),
              GestureDetector(
                onTap: () => displayComments(context,
                    postId: postId, ownerId: ownerId, url: url),
                child: Icon(
                  Icons.chat_bubble_outline,
                  size: 28.0,
                  color: const Color(0xFFFBFBFB),
                ),
              ),
            ],
          ),
          Row(
            children: [
              Container(
                margin: EdgeInsets.only(left: 20.0),
                child: Text(
                  "$likeCount beğeni",
                  style: TextStyle(
                    color: const Color(0xFFFBFBFB),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8.0, bottom: 12.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: [
                Container(
                  margin: EdgeInsets.only(left: 20.0),
                  child: Text(
                    "$username  ",
                    style: TextStyle(
                        color: const Color(0xFFFBFBFB),
                        fontWeight: FontWeight.bold),
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    color: const Color(0xFFFFC68A),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  displayComments(BuildContext context,
      {String postId, String ownerId, String url}) {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return CommentsPage(
          postId: postId, postOwnerId: ownerId, postImageUrl: url);
    }));
  }
}
