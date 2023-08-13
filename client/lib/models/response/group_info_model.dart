class GroupInfoModel {
  int? id;
  String? groupUri;
  String? groupName;
  String? createAt;

  GroupInfoModel({this.id, this.groupUri, this.groupName, this.createAt});

  factory GroupInfoModel.fromJson(Map<String, dynamic> json) {
    return GroupInfoModel(
      id: json['id'] as int?,
      groupUri: json['groupUri'] as String?,
      groupName: json['groupName'] as String?,
      createAt: json['createAt'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'groupUri': groupUri,
        'groupName': groupName,
        'createAt': createAt,
      };
}
