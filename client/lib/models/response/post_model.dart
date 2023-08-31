import 'package:syiary_client/models/response/authenticate_model/user_model.dart';

class PostModel {
  int? postId;
  DateTime? createdAt;
  dynamic updatedAt;
  UserModel? createUser;
  String? content;
  List<String>? files;

  PostModel({
    this.postId,
    this.createdAt,
    this.updatedAt,
    this.createUser,
    this.content,
    this.files,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) => PostModel(
        postId: json['postId'] as int?,
        createdAt: json['createdAt'] == null
            ? null
            : DateTime.parse(json['createdAt'] as String),
        updatedAt: json['updatedAt'] as dynamic,
        createUser: json['createUser'] == null
            ? null
            : UserModel.fromJson(json['createUser'] as Map<String, dynamic>),
        content: json['content'] as String?,
        // files: json['files'] as List<String>?,
        files:
            (json['files'] as List<dynamic>).map((e) => e as String).toList(),
      );

  Map<String, dynamic> toJson() => {
        'postId': postId,
        'createdAt': createdAt?.toIso8601String(),
        'updatedAt': updatedAt,
        'createUser': createUser?.toJson(),
        'content': content,
        'files': files,
      };
}
