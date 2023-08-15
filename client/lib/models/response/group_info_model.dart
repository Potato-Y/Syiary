import 'package:syiary_client/models/response/authenticate_model/user_model.dart';

class GroupInfoModel {
  int? id;
  String? groupUri;
  String? groupName;
  String? createAt;
  UserModel? hostUser;

  GroupInfoModel(
      {this.id, this.groupUri, this.groupName, this.createAt, this.hostUser});

  factory GroupInfoModel.fromJson(Map<String, dynamic> json) {
    return GroupInfoModel(
      id: json['id'] as int?,
      groupUri: json['groupUri'] as String?,
      groupName: json['groupName'] as String?,
      createAt: json['createAt'] as String?,
      hostUser: json['hostUser'] == null
          ? null
          : UserModel.fromJson(json['hostUser'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'groupUri': groupUri,
        'groupName': groupName,
        'createAt': createAt,
        'hostUser': hostUser?.toJson(),
      };
}
