import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  print('--- TEST SUITE START ---');

  // 1. Login with shashank@gmail.com (created by the previous script)
  print('Testing Login...');
  var res = await http.post(
    Uri.parse('http://localhost:8080/api/auth/login'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'email': 'shashank@gmail.com', 'password': 'shashank123'}),
  );
  if (res.statusCode != 200) {
    print('LOGIN FAILED: ${res.statusCode} ${res.body}');
    return;
  }
  final token = jsonDecode(res.body)['token'];
  print('Login SUCCESS. Token: \${token.substring(0, 10)}...');

  final headers = {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token'
  };

  // 2. Create Task
  print('Testing Create Task...');
  res = await http.post(
    Uri.parse('http://localhost:8080/api/tasks'),
    headers: headers,
    body: jsonEncode({
      'title': 'Automated Test Task',
      'description': 'This is a test task',
      'priority': 'HIGH',
      'tags': ['test', 'automation'],
      'subtasks': [{'title': 'Subtask 1'}]
    }),
  );
  if (res.statusCode != 200) {
    print('CREATE TASK FAILED: ${res.statusCode} ${res.body}');
    return;
  }
  final taskId = jsonDecode(res.body)['id'];
  print('Create Task SUCCESS. ID: $taskId');

  // 3. Get Tasks
  print('Testing Get Tasks...');
  res = await http.get(Uri.parse('http://localhost:8080/api/tasks'), headers: headers);
  if (res.statusCode != 200) {
    print('GET TASKS FAILED: ${res.statusCode} ${res.body}');
    return;
  }
  print('Get Tasks SUCCESS. Returned ${jsonDecode(res.body).length} task(s).');

  // 4. Update Task (toggle complete)
  print('Testing Complete Task...');
  res = await http.patch(Uri.parse('http://localhost:8080/api/tasks/$taskId/complete'), headers: headers);
  if (res.statusCode != 200) {
    print('COMPLETE TASK FAILED: ${res.statusCode} ${res.body}');
    return;
  }
  final isCompleted = jsonDecode(res.body)['completed'];
  print('Complete Task SUCCESS. Status: $isCompleted');

  // 5. Delete Task
  print('Testing Delete Task...');
  res = await http.delete(Uri.parse('http://localhost:8080/api/tasks/$taskId'), headers: headers);
  if (res.statusCode != 200) {
    print('DELETE TASK FAILED: ${res.statusCode} ${res.body}');
    return;
  }
  print('Delete Task SUCCESS.');

  print('--- ALL TESTS PASSED! ---');
}
