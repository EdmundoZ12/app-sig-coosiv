import 'package:app_coosiv/features/auth/domain/domain.dart';

class UserMapper {
  static User userJsonToEntity(Map<dynamic, dynamic> json) => User(
      id: json['id'], username: json['username'], authToken: json['authToken']);
}
