import 'dart:convert';
import 'package:http/http.dart' as http;

Future<void> main() async {
  const baseUrl = 'http://localhost:8080/api';
  final testEmail = 'final_test_${DateTime.now().millisecondsSinceEpoch}@gmail.com';
  final testUser = 'tester_${DateTime.now().millisecondsSinceEpoch}';

  print('--- FINAL API HEALTH CHECK ---');

  // 1. SIGNUP
  print('\n[1/4] Testing Signup...');
  final signupRes = await http.post(
    Uri.parse('$baseUrl/auth/signup'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'username': testUser,
      'email': testEmail,
      'password': 'password123'
    }),
  );

  if (signupRes.statusCode != 200) {
    print('❌ Signup failed: ${signupRes.body}');
    return;
  }
  final authData = jsonDecode(signupRes.body);
  final token = authData['token'];
  print('✅ Signup Success! Token received.');

  final authHeaders = {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token',
  };

  // 2. CREATE TASKS (Check Priority Order)
  print('\n[2/4] Creating Tasks with different priorities...');
  final priorities = ['LOW', 'HIGH', 'MEDIUM'];
  for (var p in priorities) {
    final res = await http.post(
      Uri.parse('$baseUrl/tasks'),
      headers: authHeaders,
      body: jsonEncode({
        'title': '$p Task',
        'priority': p,
        'description': 'Testing priority sorting'
      }),
    );
    if (res.statusCode == 200) {
      print('✅ Created $p task');
    } else {
      print('❌ Failed to create $p task');
    }
  }

  // 3. GET TASKS & VERIFY SORTING
  print('\n[3/4] Fetching tasks with priority sorting...');
  final getRes = await http.get(
    Uri.parse('$baseUrl/tasks?sortBy=priority'),
    headers: authHeaders,
  );

  if (getRes.statusCode == 200) {
    final List tasks = jsonDecode(getRes.body);
    print('Received ${tasks.length} tasks.');
    print('Order of priorities: ${tasks.map((t) => t['priority']).toList()}');
    
    // Check if HIGH comes before MEDIUM, and MEDIUM before LOW
    final order = tasks.map((t) => t['priority']).toList();
    if (order.indexOf('HIGH') < order.indexOf('MEDIUM') && 
        order.indexOf('MEDIUM') < order.indexOf('LOW')) {
      print('✅ Priority sorting logic is CORRECT (HIGH > MEDIUM > LOW)');
    } else {
      print('❌ Priority sorting logic is WRONG!');
    }
  } else {
    print('❌ Failed to fetch tasks.');
  }

  // 4. TOGGLE COMPLETE
  if (jsonDecode(getRes.body).isNotEmpty) {
      final firstTaskId = jsonDecode(getRes.body)[0]['id'];
      print('\n[4/4] Toggling completion for task ID $firstTaskId...');
      final toggleRes = await http.patch(
          Uri.parse('$baseUrl/tasks/$firstTaskId/toggle'),
          headers: authHeaders
      );
      if (toggleRes.statusCode == 200) {
          print('✅ Toggle Success!');
      } else {
          print('❌ Toggle Failed.');
      }
  }

  print('\n--- ALL SYSTEMS GO! ---');
}
