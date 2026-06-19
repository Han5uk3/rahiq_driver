class Driver {
  final String id;
  final String phoneNumber;
  final String countryCode;
  final String firstName;
  final String lastName;
  final String? avatarUrl;
  final bool isActive;
  final String type;

  Driver({
    required this.id,
    required this.phoneNumber,
    required this.countryCode,
    required this.firstName,
    required this.lastName,
    this.avatarUrl,
    required this.isActive,
    required this.type,
  });

  factory Driver.fromJson(Map<String, dynamic> json) {
    return Driver(
      id: json['id'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      countryCode: json['countryCode'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      avatarUrl: json['avatarUrl'],
      isActive: json['isActive'] ?? false,
      type: json['type'] ?? '',
    );
  }
}

class LoginResponse {
  final String accessToken;
  final String refreshToken;
  final Driver driver;

  LoginResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.driver,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      accessToken: json['accessToken'] ?? '',
      refreshToken: json['refreshToken'] ?? '',
      driver: Driver.fromJson(json['driver'] ?? {}),
    );
  }
}

class NotificationModel {
  final String id;
  final String title;
  final String body;
  final String createdAt;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      createdAt: json['createdAt'] ?? '',
    );
  }
}
