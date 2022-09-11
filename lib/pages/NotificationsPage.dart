import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:herkes_icin_sanat/pages/HomePage.dart';
import 'package:herkes_icin_sanat/pages/PostScreenPage.dart';
import 'package:herkes_icin_sanat/pages/ProfilePage.dart';
import 'package:herkes_icin_sanat/widgets/HeaderWidget.dart';
import 'package:herkes_icin_sanat/widgets/ProgressWidget.dart';
import 'package:timeago/timeago.dart' as tAgo;

class NotificationsPage extends StatefulWidget {
  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(
        context,
        strTitle: "Bildirimler",
      ),
      body: Container(
        child: FutureBuilder(
          future: retrieveNotifications(),
          builder: (context, dataSnapshot) {
            if (!dataSnapshot.hasData) {
              return circularProgress();
            }
            return ListView(
              children: dataSnapshot.data,
            );
          },
        ),
      ),
    );
  }

  retrieveNotifications() async {
    print("currentUserId -> " + currentUser.id);
    QuerySnapshot querySnapshot = await activityFeedReference
        .doc(currentUser.id)
        .collection("feedItems")
        .orderBy("timestamp", descending: true)
        .limit(60)
        .get();
    List<NotificationsItem> notificationsItems = [];
    querySnapshot.docs.forEach((document) {
      notificationsItems.add(NotificationsItem.fromDocument(document));
    });
    return notificationsItems;
  }
}

String notificationItemText;
Widget mediaPreview;

class NotificationsItem extends StatelessWidget {
  final String username;
  final String type;
  final String commentData;
  final String postId;
  final String userId;
  final String userProfileImg;
  final String url;
  final Timestamp timestamp;

  NotificationsItem(
      {this.username,
      this.type,
      this.commentData,
      this.postId,
      this.userId,
      this.userProfileImg,
      this.url,
      this.timestamp});

  factory NotificationsItem.fromDocument(DocumentSnapshot documentSnapshot) {
    print(documentSnapshot.data());
    print("document.data-->commentData " + documentSnapshot['commentData']);
    return NotificationsItem(
      username: documentSnapshot["username"],
      type: documentSnapshot["type"],
      commentData: documentSnapshot["commentData"],
      postId: documentSnapshot["postId"],
      userId: documentSnapshot["userId"],
      userProfileImg: documentSnapshot["userProfileImg"],
      url: documentSnapshot["url"],
      timestamp: documentSnapshot["timestamp"],
    );
  }

  @override
  Widget build(BuildContext context) {
    configureMediaPreview(context);
    return Padding(
      padding: EdgeInsets.only(top: 3.0),
      child: Container(
        color: Theme.of(context).accentColor,
        child: ListTile(
          title: GestureDetector(
            onTap: () => displayUserProfile(context, userProfileId: userId),
            child: RichText(
              overflow: TextOverflow.ellipsis,
              text: TextSpan(
                style: TextStyle(
                  color: const Color(0xFFFBFBFB),
                  fontSize: 14.0,
                ),
                children: [
                  TextSpan(
                    text: username,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  TextSpan(text: " $notificationItemText"),
                ],
              ),
            ),
          ),
          leading: CircleAvatar(
            backgroundImage: CachedNetworkImageProvider(userProfileImg),
          ),
          subtitle: Text(
            tAgo.format(timestamp.toDate()),
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: const Color(0xFFFBFBFB),
            ),
          ),
          trailing: mediaPreview,
        ),
      ),
    );
  }

  configureMediaPreview(context) {
    if (type == "comment" || type == "like") {
      mediaPreview = GestureDetector(
        onTap: () => displayFullPost(context),
        child: Container(
          height: 50.0,
          width: 50.0,
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                    image: CachedNetworkImageProvider(url), fit: BoxFit.cover),
              ),
            ),
          ),
        ),
      );
    } else {
      mediaPreview = Text("");
    }
    if (type == "like") {
      notificationItemText = "gönderini beğendi.";
    } else if (type == "comment") {
      notificationItemText = "yanıtladı: $commentData";
    } else if (type == "follow") {
      notificationItemText = "seni takip etmeye başladı.";
    } else {
      notificationItemText = "Hata! Bilinmeyen tür = $type.";
    }
  }

  displayFullPost(context) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => PostScreenPage(
                  postId: postId,
                  userId: userId,
                )));
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
