import 'package:dio/dio.dart';
import 'package:todo_app/model/Todo.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TodoService {
  static final Dio _dio = Dio(BaseOptions(
    baseUrl: 'https://thetodaytodo.netlify.app/',
    headers: {
      'Content-Type': 'application/json',
    },
  ));

  static Future<List<Todo>> fetchTodos() async {
    try {

      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');
      if (token == null) throw Exception('No auth token');

      final response = await _dio.get(
        '/api/todos',
        options: Options(headers: {
          'Cookie': 'token=$token',
        }),
      );

      final List data = response.data;
      return data.map((todo) => Todo.fromJson(todo)).toList();
    } catch (e) {
      print('Error fetching todos: $e');
      return [];
    }
  }

  static Future<Todo?> addTodo(String title, String? description, DateTime? deadline) async {
    try {

      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');
      if (token == null) throw Exception('No auth token');

      final response = await _dio.post(
        '/api/todos',
        data: {
          'title': title,
          'description': description,
          'deadline': deadline?.toUtc().toIso8601String()
        },
        options: Options(headers: {
          'Cookie': 'token=$token',
        }),
      );

      if (response.statusCode == 201) {
        return Todo.fromJson(response.data);
      } else {
        throw Exception('Failed to add todo');
      }
    } catch (e) {
      print('Error adding todo: $e');
      return null;
    }
  }

  static Future<bool> toggleTodo(String id, bool completed) async {
    try {

      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');
      if (token == null) throw Exception('No auth token');

      final response = await _dio.put(
        '/api/todos/$id',
        data: {
          'completed': completed,
        },
        options: Options(headers: {
          'Cookie': 'token=$token',
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error toggling todo: $e');
      return false;
    }
  }

  static Future<bool> deleteTodo(String id) async {
    try {

      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');
      if (token == null) throw Exception('No auth token');

      final response = await _dio.delete(
        '/api/todos/$id',
        options: Options(headers: {
          'Cookie': 'token=$token',
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error deleting todo: $e');
      return false;
    }
  }
}
