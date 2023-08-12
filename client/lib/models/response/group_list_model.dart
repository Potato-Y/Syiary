class GroupListModel {
  int? id;
  String? groupUri;
  String? groupName;

  GroupListModel({this.id, this.groupUri, this.groupName});

  factory GroupListModel.fromJson(Map<String, dynamic> json) {
    return GroupListModel(
      id: json['id'] as int?,
      groupUri: json['groupUri'] as String?,
      groupName: json['groupName'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'groupUri': groupUri,
        'groupName': groupName,
      };
}
