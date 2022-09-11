import 'package:flutter/material.dart';
import 'package:herkes_icin_sanat/pages/HomePage.dart';
import 'package:herkes_icin_sanat/widgets/HeaderWidget.dart';
import 'package:herkes_icin_sanat/widgets/PostWidget.dart';
import 'package:herkes_icin_sanat/widgets/ProgressWidget.dart';

class PostScreenPage extends StatelessWidget {
  final String postId;
  final String userId;

  PostScreenPage({this.userId, this.postId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future:
          postReferences.doc(userId).collection("usersPosts").doc(postId).get(),
      builder: (context, dataSnapshot) {
        if (!dataSnapshot.hasData) {
          circularProgress();
        }
        Post post = Post.fromDocument(dataSnapshot.data);
        return Center(
          child: Scaffold(
            appBar: header(context, strTitle: post.description),
            body: ListView(
              children: [
                Container(
                  child: post,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
