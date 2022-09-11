import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:herkes_icin_sanat/models/user.dart';
import 'package:herkes_icin_sanat/pages/CreateAccountPage.dart';
import 'package:herkes_icin_sanat/pages/MapPage.dart';
import 'package:herkes_icin_sanat/pages/NotificationsPage.dart';
import 'package:herkes_icin_sanat/pages/ProfilePage.dart';
import 'package:herkes_icin_sanat/pages/SearchPage.dart';
import 'package:herkes_icin_sanat/pages/SearchPostPage.dart';
import 'package:herkes_icin_sanat/pages/TimeLinePage.dart';
import 'package:herkes_icin_sanat/pages/UploadPage.dart';

final GoogleSignIn gSignIn = GoogleSignIn();
FirebaseAuth auth = FirebaseAuth.instance;
final userReferences = FirebaseFirestore.instance.collection("users");
FirebaseStorage storage = FirebaseStorage.instance;
final Reference storageReferences = storage.ref().child("Posts Pictures");
final postReferences = FirebaseFirestore.instance.collection("posts");
final allPostReferences = FirebaseFirestore.instance.collection("allPosts");
final activityFeedReference = FirebaseFirestore.instance.collection("feed");
final commentsReference = FirebaseFirestore.instance.collection("comments");
final followersReference = FirebaseFirestore.instance.collection("followers");
final followingReference = FirebaseFirestore.instance.collection("following");
final timelineReference = FirebaseFirestore.instance.collection("timeline");

final DateTime timestamp = DateTime.now();
Kullanici currentUser;
User user;

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //*********************************************************************
  bool isSignedIn = false;
  PageController pageController;
  int getPageIndex = 0;
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  //*********************************************************************
//**********************LoginWithGoogle**********************
  void initState() {
    super.initState();

    pageController = PageController();

    gSignIn.onCurrentUserChanged.listen((gSigninAccount) {
      controlSignIn(gSigninAccount);
    }, onError: (gError) {
      print("Error Message: " + gError);
    });

    gSignIn.signInSilently(suppressErrors: false).then((gSigninAccount) {
      controlSignIn(gSigninAccount);
    }).catchError((gError) {
      print("Error Message: " + gError);
    });
  }

  saveUserInfoToFireStore() async {
    final GoogleSignInAccount gCurrentUser = gSignIn.currentUser;
    DocumentSnapshot documentSnapshot =
        await userReferences.doc(gCurrentUser.id).get();

    if (!documentSnapshot.exists) {
      final username = await Navigator.push(context,
          MaterialPageRoute(builder: (context) => CreateAccountPage()));
      userReferences.doc(gCurrentUser.id).set({
        "id": gCurrentUser.id,
        "profileName": gCurrentUser.displayName,
        "username": username,
        "url": gCurrentUser.photoUrl,
        "email": gCurrentUser.email,
        "bio": "",
        "timestamp": timestamp
      });
      await followersReference
          .doc(gCurrentUser.id)
          .collection("userFollowers")
          .doc(gCurrentUser.id)
          .set({});
      documentSnapshot = await userReferences.doc(gCurrentUser.id).get();
    }

    currentUser = Kullanici.fromDocument(documentSnapshot);
  }

  controlSignIn(GoogleSignInAccount signInAccount) async {
    if (signInAccount != null) {
      final GoogleSignInAuthentication googleSignInAuthentication =
          await signInAccount.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );
      try {
        final UserCredential userCredential =
            await auth.signInWithCredential(credential);

        user = userCredential.user;
      } on FirebaseAuthException catch (e) {
        if (e.code == 'account-exists-with-different-credential') {
          // handle the error here
        } else if (e.code == 'invalid-credential') {
          // handle the error here
        }
      } catch (e) {
        // handle the error here

      }
      await saveUserInfoToFireStore();
      setState(() {
        isSignedIn = true;
      });
      configureRealTimePushNotifications();
    } else {
      setState(() {
        isSignedIn = false;
      });
    }
  }

  configureRealTimePushNotifications() {
    final GoogleSignInAccount gUser = gSignIn.currentUser;
    /*if (Platform.isIOS) {
      getIOSPermissions();
    }

    _firebaseMessaging.getToken().then((token) {
      userReferences
          .doc(gUser.id)
          .update({"androidPushNotificationsToken": token});
      FirebaseMessaging.onMessage.asyncMap((event) {
        final String recipientId = event["data"]["recipient"];
      });
    });*/
  }

  /*getIOSPermissions() {
    _firebaseMessaging.requestPermission(alert: true, badge: true, sound: true);
    _firebaseMessaging.getNotificationSettings();
  }*/

  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  loginUser() {
    gSignIn.signIn();
  }

  logOutUser() {
    gSignIn.signOut();
  }

  //**********************Sayfalar Degisirken**********************
  whenPageChanges(int pageIndex) {
    setState(() {
      this.getPageIndex = pageIndex;
    });
  }

  onTapChangePage(int pageIndex) {
    pageController.animateToPage(
      pageIndex,
      duration: Duration(milliseconds: 400),
      curve: Curves.bounceInOut,
    );
  }

  //**********************HomeScreen**********************
  Scaffold buildHomeScreen() {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              Theme.of(context).accentColor,
              Theme.of(context).primaryColor
            ],
          ),
        ),
        child: PageView(
          children: [
            TimeLinePage(
              gCurrentUser: currentUser,
            ),
            SearchPage(),
            MapPage(),
            UploadPage(
              gCurrentUser: currentUser,
            ),
            SearchPostPage(),
            NotificationsPage(),
            ProfilePage(userProfileId: currentUser.id),
          ],
          controller: pageController,
          onPageChanged: whenPageChanges,
          physics: NeverScrollableScrollPhysics(),
        ),
      ),
      bottomNavigationBar: CupertinoTabBar(
        currentIndex: getPageIndex,
        onTap: onTapChangePage,
        backgroundColor: Theme.of(context).primaryColor,
        activeColor: const Color(0xFFFBFBFB),
        inactiveColor: Theme.of(context).accentColor,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home)),
          BottomNavigationBarItem(icon: Icon(Icons.search)),
          BottomNavigationBarItem(icon: Icon(Icons.public)),
          BottomNavigationBarItem(
              icon: Icon(
            Icons.photo_camera,
            size: 37.0,
          )),
          BottomNavigationBarItem(icon: Icon(Icons.article)),
          BottomNavigationBarItem(icon: Icon(Icons.favorite)),
          BottomNavigationBarItem(icon: Icon(Icons.person)),
        ],
      ),
    );
  }

  //**********************SignInScreen**********************
  Scaffold buildSignInScreen() {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              Theme.of(context).accentColor,
              Theme.of(context).primaryColor
            ],
          ),
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'HIS',
              style: TextStyle(
                fontSize: 92.0,
                color: const Color(0xFFFBFBFB),
                fontFamily: "Signatra",
              ),
            ),
            GestureDetector(
              onTap: loginUser,
              child: Container(
                width: 270.0,
                height: 65.0,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/images/google_signin_button.png"),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isSignedIn) {
      return buildHomeScreen();
    } else {
      return buildSignInScreen();
    }
  }
}
