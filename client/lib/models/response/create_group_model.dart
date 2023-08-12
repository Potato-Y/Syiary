class CreateGroupModel {
  int? id;
  String? groupUri;
  String? groupName;

  CreateGroupModel({this.id, this.groupUri, this.groupName});

  factory CreateGroupModel.fromJson(Map<String, dynamic> json) {
    return CreateGroupModel(
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
