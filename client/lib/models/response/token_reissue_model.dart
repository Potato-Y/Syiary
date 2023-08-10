class TokenReissueModel {
  String? accessToken;

  TokenReissueModel({this.accessToken});

  factory TokenReissueModel.fromJson(Map<String, dynamic> json) {
    return TokenReissueModel(
      accessToken: json['accessToken'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'accessToken': accessToken,
      };
}
