import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:herkes_icin_sanat/widgets/PostWidget.dart';
import 'package:herkes_icin_sanat/widgets/ProgressWidget.dart';

import 'HomePage.dart';

class SearchPostPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPostPage> {
  TextEditingController searchTextEditingController = TextEditingController();
  Future<QuerySnapshot> futureSearchResult;
  String dropdownValue = 'Bizim Önerimiz';
  List<Post> posts = new List<Post>.empty(growable: true);
  List<String> followingsList = [];
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  List<Post> allPosts = List<Post>.empty(growable: true);

  retrieveTimeLine() async {
    List<Post> butunPostlar = [];
    List<String> likedPostIds = [];
    List<int> likeRatio = [];
    int totalLikedPosts = 0;
    int totalLikedAhsap = 0;
    int totalLikedCam = 0;
    int totalLikedFotorafcilik = 0;
    int totalLikedGrafik = 0;
    int totalLikedHeykel = 0;
    int totalLikedOzgunBaski = 0;
    int totalLikedResim = 0;
    int totalLikedSeramik = 0;
    int totalLikedSusleme = 0;
    int totalLikedTas = 0;
    int totalLikedEveDestek = 0;

    if (allPosts.isNotEmpty) {
      butunPostlar.clear();
      this.posts.clear();
      allPosts.clear();
    }

    await allPostReferences.get().then((dataSnapshot) {
      dataSnapshot.docs.forEach((doc) {
        if (doc.get('ownerId') != currentUser.id) {
          butunPostlar.add(Post.fromDocument(doc));
          if (dropdownValue != 'Bizim Önerimiz') {
            if (doc.get('productType') == dropdownValue) {
              setState(() {
                allPosts.add(Post.fromDocument(doc));
                allPosts.sort((b, a) => a
                    .getTotalNumberOfLikes(a.likes)
                    .compareTo(b.getTotalNumberOfLikes(b.likes)));
              });
            }
          } else {
            if (doc.get('likes') != null) {
              doc.get('likes').keys.forEach((eachValue) {
                if (eachValue == currentUser.id) {
                  if (doc.get('likes')[currentUser.id]) {
                    print(totalLikedPosts);
                    totalLikedPosts++;
                    likedPostIds.add(doc.get('postId'));
                    switch (doc.get('productType')) {
                      case "Ahşap":
                        totalLikedAhsap++;
                        break;
                      case "Cam":
                        totalLikedCam++;
                        break;
                      case "Fotoğrafçılık":
                        totalLikedFotorafcilik++;
                        break;
                      case "Grafik":
                        totalLikedGrafik++;
                        break;
                      case "Heykel":
                        totalLikedHeykel++;
                        break;
                      case "Özgün Baskı":
                        totalLikedOzgunBaski++;
                        break;
                      case "Resim":
                        totalLikedResim++;
                        break;
                      case "Seramik":
                        totalLikedSeramik++;
                        break;
                      case "Süsleme":
                        totalLikedSusleme++;
                        break;
                      case "Taş":
                        totalLikedTas++;
                        break;
                      case "Eve Destek":
                        totalLikedEveDestek++;
                        break;
                    }
                  }
                }
              });
            }
          }
        }
      });
    });

    if (dropdownValue == 'Bizim Önerimiz') {
      butunPostlar.sort((b, a) => a
          .getTotalNumberOfLikes(a.likes)
          .compareTo(b.getTotalNumberOfLikes(b.likes)));
      likeRatio.clear();
      likeRatio.add((totalLikedAhsap / totalLikedPosts * 100 / 10).round());
      likeRatio.add((totalLikedCam / totalLikedPosts * 100 / 10).round());
      likeRatio
          .add((totalLikedFotorafcilik / totalLikedPosts * 100 / 10).round());
      likeRatio.add((totalLikedGrafik / totalLikedPosts * 100 / 10).round());
      likeRatio.add((totalLikedHeykel / totalLikedPosts * 100 / 10).round());
      likeRatio
          .add((totalLikedOzgunBaski / totalLikedPosts * 100 / 10).round());
      likeRatio.add((totalLikedResim / totalLikedPosts * 100 / 10).round());
      likeRatio.add((totalLikedSeramik / totalLikedPosts * 100 / 10).round());
      likeRatio.add((totalLikedSusleme / totalLikedPosts * 100 / 10).round());
      likeRatio.add((totalLikedTas / totalLikedPosts * 100 / 10).round());
      likeRatio.add((totalLikedEveDestek / totalLikedPosts * 100 / 10).round());
      int counter = 0;

      for (int i = 0; i < likeRatio.length; i++) {
        if (likeRatio[i] > 0) {
          switch (i) {
            case 0:
              for (int j = 0; j < butunPostlar.length; j++)
                if (butunPostlar[j].productType == "Ahşap") if (!(likedPostIds
                    .contains(
                        butunPostlar[j].postId))) if (counter < likeRatio[i]) {
                  allPosts.add(butunPostlar[j]);
                  counter++;
                } else {
                  counter = 0;
                  j = butunPostlar.length;
                }
              break;
            case 1:
              for (int j = 0; j < butunPostlar.length; j++)
                if (butunPostlar[j].productType == "Cam") if (!(likedPostIds
                    .contains(
                        butunPostlar[j].postId))) if (counter < likeRatio[i]) {
                  allPosts.add(butunPostlar[j]);
                  counter++;
                } else {
                  counter = 0;
                  j = butunPostlar.length;
                }
              break;
            case 2:
              for (int j = 0; j < butunPostlar.length; j++)
                if (butunPostlar[j].productType ==
                    "Fotoğrafçılık") if (!(likedPostIds.contains(butunPostlar[
                        j]
                    .postId))) if (counter < likeRatio[i]) {
                  allPosts.add(butunPostlar[j]);
                  counter++;
                } else {
                  counter = 0;
                  j = butunPostlar.length;
                }
              break;
            case 3:
              for (int j = 0; j < butunPostlar.length; j++)
                if (butunPostlar[j].productType == "Grafik") if (!(likedPostIds
                    .contains(
                        butunPostlar[j].postId))) if (counter < likeRatio[i]) {
                  allPosts.add(butunPostlar[j]);
                  counter++;
                } else {
                  counter = 0;
                  j = butunPostlar.length;
                }
              break;
            case 4:
              for (int j = 0; j < butunPostlar.length; j++)
                if (butunPostlar[j].productType == "Heykel") if (!(likedPostIds
                    .contains(
                        butunPostlar[j].postId))) if (counter < likeRatio[i]) {
                  allPosts.add(butunPostlar[j]);
                  counter++;
                } else {
                  counter = 0;
                  j = butunPostlar.length;
                }
              break;
            case 5:
              for (int j = 0; j < butunPostlar.length; j++)
                if (butunPostlar[j].productType ==
                    "Özgün Baskı") if (!(likedPostIds.contains(butunPostlar[
                        j]
                    .postId))) if (counter < likeRatio[i]) {
                  allPosts.add(butunPostlar[j]);
                  counter++;
                } else {
                  counter = 0;
                  j = butunPostlar.length;
                }
              break;
            case 6:
              for (int j = 0; j < butunPostlar.length; j++)
                if (butunPostlar[j].productType == "Resim") if (!(likedPostIds
                    .contains(
                        butunPostlar[j].postId))) if (counter < likeRatio[i]) {
                  allPosts.add(butunPostlar[j]);
                  counter++;
                } else {
                  counter = 0;
                  j = butunPostlar.length;
                }
              break;
            case 7:
              for (int j = 0; j < butunPostlar.length; j++)
                if (butunPostlar[j].productType == "Seramik") if (!(likedPostIds
                    .contains(
                        butunPostlar[j].postId))) if (counter < likeRatio[i]) {
                  allPosts.add(butunPostlar[j]);
                  counter++;
                } else {
                  counter = 0;
                  j = butunPostlar.length;
                }
              break;
            case 8:
              for (int j = 0; j < butunPostlar.length; j++)
                if (butunPostlar[j].productType == "Süsleme") if (!(likedPostIds
                    .contains(
                        butunPostlar[j].postId))) if (counter < likeRatio[i]) {
                  allPosts.add(butunPostlar[j]);
                  counter++;
                } else {
                  counter = 0;
                  j = butunPostlar.length;
                }
              break;
            case 9:
              for (int j = 0; j < butunPostlar.length; j++)
                if (butunPostlar[j].productType == "Taş") if (!(likedPostIds
                    .contains(
                        butunPostlar[j].postId))) if (counter < likeRatio[i]) {
                  allPosts.add(butunPostlar[j]);
                  counter++;
                } else {
                  counter = 0;
                  j = butunPostlar.length;
                }
              break;
            case 10:
              for (int j = 0; j < butunPostlar.length; j++)
                if (butunPostlar[j].productType ==
                    "Eve Destek") if (!(likedPostIds.contains(butunPostlar[
                        j]
                    .postId))) if (counter < likeRatio[i]) {
                  allPosts.add(butunPostlar[j]);
                  counter++;
                } else {
                  counter = 0;
                  j = butunPostlar.length;
                }
              break;
          }
        }
      }
    }

    setState(() {
      this.posts = allPosts;
    });
  }

  @override
  void initState() {
    super.initState();
    retrieveTimeLine();
  }

  createUserTimeLine() {
    if (posts == null) {
      return circularProgress();
    } else {
      return new ListView.builder(
          itemCount: posts.length,
          itemBuilder: (BuildContext ctxt, int Index) {
            return new Post.fromElements(posts[Index]);
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Theme.of(context).accentColor,
        title: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            DropdownButton(
              // isExpanded: true,
              value: dropdownValue,
              icon: const Icon(
                Icons.arrow_downward,
                color: const Color(0xFFFFC68A),
              ),
              iconSize: 24,
              elevation: 16,
              style: const TextStyle(
                  color: const Color(0xFFFFC68A), fontSize: 22.0),
              onChanged: (String newValue) {
                setState(() {
                  dropdownValue = newValue;
                  retrieveTimeLine();
                });
              },
              items: <String>[
                'Bizim Önerimiz',
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
              underline: SizedBox(
                height: 0,
              ),
              //underline: SizedBox(),
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        child: createUserTimeLine(),
        onRefresh: () => retrieveTimeLine(),
      ),
    );
  }
}
