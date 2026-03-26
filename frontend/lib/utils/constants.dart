class ApiConstants {
  static const String baseUrl = 'http://localhost:8080/api';
  static const String authLogin = '$baseUrl/auth/login';
  static const String authSignup = '$baseUrl/auth/signup';
  static const String tasks = '$baseUrl/tasks';
  static const String tags = '$baseUrl/tags';

  static String taskById(int id) => '$tasks/$id';
  static String taskComplete(int id) => '$tasks/$id/complete';
  static String subtasks(int taskId) => '$tasks/$taskId/subtasks';
  static String subtaskById(int taskId, int subId) =>
      '$tasks/$taskId/subtasks/$subId';
  static String subtaskComplete(int taskId, int subId) =>
      '$tasks/$taskId/subtasks/$subId/complete';
}
