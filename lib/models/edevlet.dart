class EDevletDataModel {
  String isim;
  String soyisim;
  int dogumyili;
  int tcno;

  EDevletDataModel(String isim, String soyisim, int dogumyili, int tcno) {
    this.isim = isim;
    this.soyisim = soyisim;
    this.dogumyili = dogumyili;
    this.tcno = tcno;
  }
  EDevletDataModel.fromJson(Map json) {
    isim = json["isim"];
    soyisim = json["soyisim"];
    dogumyili = json["dogumyili"];
    tcno = json["tcno"];
  }

  Map toJson() {
    return {
      "isim": isim,
      "soyisim": soyisim,
      "dogumyili": dogumyili,
      "tcno": tcno
    };
  }
}
