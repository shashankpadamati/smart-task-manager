import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  print('Trying new signup for sujan...');
  final res = await http.post(
    Uri.parse('http://localhost:8080/api/auth/signup'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'username': 'sujan2',
      'email': 'sujan2@gmail.com',
      'password': 'sujanpassword'
    }),
  );
  print('STATUS: ${res.statusCode}');
  print('BODY: ${res.body}');
  if (res.statusCode == 200) {
    print('✅ SUCCESS! User sujan2 signed up correctly.');
  } else {
    print('❌ FAILED.');
  }
}
