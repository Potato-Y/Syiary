import 'package:syiary_client/models/response/authenticate_model/user_model.dart';

class GroupMembersModel {
  UserModel? hostUser;
  List<UserModel>? memberUser;

  GroupMembersModel({this.hostUser, this.memberUser});

  factory GroupMembersModel.fromJson(Map<String, dynamic> json) =>
      GroupMembersModel(
        hostUser: json['hostUser'] == null
            ? null
            : UserModel.fromJson(json['hostUser'] as Map<String, dynamic>),
        memberUser: (json['memberUser'] as List<dynamic>?)
            ?.map((e) => UserModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'hostUser': hostUser?.toJson(),
        'memberUser': memberUser?.map((e) => e.toJson()).toList(),
      };
}
