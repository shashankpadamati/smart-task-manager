import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  print('Trying new signup...');
  final res = await http.post(
    Uri.parse('http://localhost:8080/api/auth/signup'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'username': 'newuser123',
      'email': 'newuser123@gmail.com',
      'password': 'password123'
    }),
  );
  print('STATUS: ${res.statusCode}');
  print('BODY: ${res.body}');
}
