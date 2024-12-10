import 'dart:ffi';

class User {
  final int id;
  final String username;
  final String authToken;

  User(
      {required this.id,
      required this.username,
      required this.authToken});
}
