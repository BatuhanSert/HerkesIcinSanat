import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:herkes_icin_sanat/widgets/HeaderWidget.dart';
//import 'package:http/http.dart' as http;

class CreateAccountPage extends StatefulWidget {
  @override
  _CreateAccountPageState createState() => _CreateAccountPageState();
}

class _CreateAccountPageState extends State<CreateAccountPage> {
  CollectionReference users = FirebaseFirestore.instance.collection("users");
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  String username;
  String isim;
  String soyisim;
  int tcNo;
  int dogumYili;

  /* String soap = '''<?xml version="1.0"? encoding="utf-8">
<soapenv:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                  xmlns:xsd="http://www.w3.org/2001/XMLSchema"
                  xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
  <soapenv:Body>
    <TCKimlikNoDogrula xmlns="http://tckimlik.nvi.gov.tr/WS">
      <TCKimlikNo>long</TCKimlikNo>
      <Ad>string</Ad>
      <Soyad>string</Soyad>
      <DogumYili>int</DogumYili>
    </TCKimlikNoDogrula>
  </soapenv:Body>
</soapenv:Envelope>''';*/

  submitUsername() async {
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      /*Uri uri =
          'https://tckimlik.nvi.gov.tr/Service/KPSPublic.asmx?WSDL' as Uri;
      http.Response response = await http.post(
        uri,
        headers: {
          'content-type': 'text/xmlc',
          'authorization': 'bWVzdHJlOnRvdHZz',
          'SOAPAction':
              'http://www.totvs.com/IwsConsultaSQL/RealizarConsultaSQL',
        },
        body: utf8.encode(soap),
      );
      print(response.statusCode);*/

      if (await checkUsernameExist(username)) {
        SnackBar snackBar = SnackBar(content: Text("Hoşgeldin " + username));
        _scaffoldKey.currentState.showSnackBar(snackBar);
        Timer(Duration(seconds: 4), () {
          Navigator.pop(context, username);
        });
      } else {
        SnackBar snackBar =
            SnackBar(content: Text("Bu kullanıcı adı alınmış.."));
        _scaffoldKey.currentState.showSnackBar(snackBar);
      }
    }
  }

  checkUsernameExist(String str) async {
    var response = await users.get();
    int size = response.size;
    var list = response.docs;
    var gelenUsernameler;
    bool returndegeri = true;
    //print("benim yazdığım username: " + str);
    for (int i = 0; i < size; i++) {
      gelenUsernameler = list[i].get("username");
      print(gelenUsernameler);
      if (gelenUsernameler != str) {
        returndegeri = true;
      } else {
        returndegeri = false;
        break;
      }
    }
    return returndegeri;
  }

  @override
  Widget build(BuildContext parentContext) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: header(context,
          strTitle: "Profil Olustur", disappearedBackButton: true),
      body: ListView(
        children: [
          Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 26.0, left: 10.0),
                  child: Text(
                    "Kullanıcı Adı: ",
                    style: TextStyle(fontSize: 16.0, color: Colors.grey),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Container(
                    child: Form(
                      key: _formKey,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      child: TextFormField(
                        style: TextStyle(color: Colors.white),
                        validator: (val) {
                          if (val.trim().length < 5 || val.isEmpty) {
                            return "Kullanıcı adı çok kısa.";
                          } else if (val.trim().length > 18) {
                            return "Kullanıcı adı çok uzun.";
                          } else {
                            return null;
                          }
                        },
                        onSaved: (val) => username = "@" + val,
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Theme.of(context).accentColor),
                          ),
                          border: OutlineInputBorder(),
                          labelStyle: TextStyle(fontSize: 16.0),
                          hintText: "En az 5 en fazla 18 karakter olmalı.",
                          hintStyle: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ),
                  ),
                ),
                //İsim:
                /*Padding(
                  padding: EdgeInsets.only(top: 2.0, left: 10.0),
                  child: Text(
                    "İsim: ",
                    style: TextStyle(fontSize: 16.0, color: Colors.grey),
                  ),
                ),

                Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Container(
                    child: Form(
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      child: TextFormField(
                        style: TextStyle(color: Colors.white),
                        validator: (val) {
                          if (val.isEmpty) {
                            return "İsim alanı boş olamaz!";
                          } else if (val.contains(new RegExp(r'[0-9]'))) {
                            return "İsim sayı içeremez.";
                          } else {
                            return null;
                          }
                        },
                        onSaved: (val) => isim = val.toUpperCase(),
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Theme.of(context).accentColor),
                          ),
                          border: OutlineInputBorder(),
                          labelStyle: TextStyle(fontSize: 16.0),
                          hintText: "Osman",
                          hintStyle: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ),
                  ),
                ),
                //Soyisim:
                Padding(
                  padding: EdgeInsets.only(top: 2.0, left: 10.0),
                  child: Text(
                    "Soyisim: ",
                    style: TextStyle(fontSize: 16.0, color: Colors.grey),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Container(
                    child: Form(
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      child: TextFormField(
                        style: TextStyle(color: Colors.white),
                        validator: (val) {
                          if (val.isEmpty) {
                            return "Soyisim alanı boş olamaz!";
                          } else if (val.contains(new RegExp(r'[0-9]'))) {
                            return "Soyisim sayı içeremez.";
                          } else {
                            return null;
                          }
                        },
                        onSaved: (val) => soyisim = val.toUpperCase(),
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Theme.of(context).accentColor),
                          ),
                          border: OutlineInputBorder(),
                          labelStyle: TextStyle(fontSize: 16.0),
                          hintText: "Şentürk",
                          hintStyle: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ),
                  ),
                ),
                //dogum yili
                Padding(
                  padding: EdgeInsets.only(top: 2.0, left: 10.0),
                  child: Text(
                    "Doğum Yılı: ",
                    style: TextStyle(fontSize: 16.0, color: Colors.grey),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Container(
                    child: Form(
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      child: TextFormField(
                        keyboardType: TextInputType.number,
                        style: TextStyle(color: Colors.white),
                        validator: (val) {
                          if (val.isEmpty) {
                            return "Doğum yılı boş olamaz!";
                          } else if (int.tryParse(val) == null) {
                            return "Doğum yılı sadece rakam içermelidir.";
                          } else if (val.trim().length != 4) {
                            return "Doğum yılı 4 hane içermelidir.";
                          } else {
                            return null;
                          }
                        },
                        onSaved: (val) => dogumYili = int.parse(val),
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Theme.of(context).accentColor),
                          ),
                          border: OutlineInputBorder(),
                          labelStyle: TextStyle(fontSize: 16.0),
                          hintText: "1990",
                          hintStyle: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ),
                  ),
                ),
                //TC
                Padding(
                  padding: EdgeInsets.only(top: 2.0, left: 10.0),
                  child: Text(
                    "TC No: ",
                    style: TextStyle(fontSize: 16.0, color: Colors.grey),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Container(
                    child: Form(
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      child: TextFormField(
                        keyboardType: TextInputType.number,
                        style: TextStyle(color: Colors.white),
                        validator: (val) {
                          if (val.isEmpty) {
                            return "TC No boş olamaz!";
                          } else if (int.tryParse(val) == null) {
                            return "TC No sadece rakam içermelidir.";
                          } else if (val.trim().length != 11) {
                            return "TC No 11 hane içermelidir.";
                          } else {
                            return null;
                          }
                        },
                        onSaved: (val) => tcNo = int.parse(val),
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Theme.of(context).accentColor),
                          ),
                          border: OutlineInputBorder(),
                          labelStyle: TextStyle(fontSize: 16.0),
                          hintText: "12345678902",
                          hintStyle: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ),
                  ),
                ),*/
                GestureDetector(
                  onTap: submitUsername,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10.0),
                    child: Container(
                      height: 55.0,
                      width: 390.0,
                      decoration: BoxDecoration(
                        color: Colors.greenAccent,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Center(
                        child: Text(
                          "Gönder",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
