import 'dart:convert';

class UserType {
  int id;
  int branch;
  String guid;
  String arabicDescription;
  String englishDescription;
  String userName;
  bool deleted;

  String currWarehouse;

  UserType();

  @override
  String toString() {
    return this.toJson();
  }

  String toJson() {
    return json.encode({
      "id": id,
      "branch": branch,
      "guid": guid,
      "arabicDescription": arabicDescription,
      "englishDescription": englishDescription,
      "userName": userName,
      "deleted": deleted,
      "currWarehouse": currWarehouse
    });
  }

  factory UserType.fromString(String userJsonString) {
    var decoded = json.decode(userJsonString);
    UserType user = new UserType();
    user.id = int.parse(decoded['id'].toString());
    user.branch = int.parse(decoded['branch'].toString());
    user.guid = decoded['guid'];
    user.arabicDescription = decoded['arabicDescription'];
    user.englishDescription = decoded['englishDescription'];
    user.userName = decoded['userName'];
    user.deleted = decoded['deleted'];
    user.currWarehouse = decoded['currWarehouse'];
    return user;
  }

  factory UserType.fromJson(Map<String, dynamic> json) {
    UserType user = new UserType();
    user.id = int.parse(json['ID']);
    user.branch = int.parse(json['Branch']);
    user.guid = json['GUID'];
    user.arabicDescription = json['ArabicDescription'];
    user.englishDescription = json['EnglishDescription'];
    user.userName = json['UserName'];
    user.deleted = json['Deleted'] == "1";
    return user;
  }
}
