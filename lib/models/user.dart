import 'package:cloud_firestore/cloud_firestore.dart';

class Kullanici {
  final String id;
  final String profileName;
  final String username;
  final String url;
  final String email;
  final String bio;

  Kullanici({
    this.id,
    this.profileName,
    this.username,
    this.url,
    this.email,
    this.bio,
  });

  factory Kullanici.fromDocument(DocumentSnapshot doc) {
    return Kullanici(
      id: doc.id,
      email: doc['email'],
      username: doc['username'],
      url: doc['url'],
      profileName: doc['profileName'],
      bio: doc['bio'],
    );
  }
}
