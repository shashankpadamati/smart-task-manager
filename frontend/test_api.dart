import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  final res = await http.post(
    Uri.parse('http://localhost:8080/api/auth/signup'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'username': 'shashank',
      'email': 'shashank@gmail.com',
      'password': 'shashank123'
    }),
  );
  print('STATUS: ${res.statusCode}');
  print('BODY: ${res.body}');
}
