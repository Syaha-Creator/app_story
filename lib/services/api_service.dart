import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../repositories/story_model.dart';
import '../repositories/user_model.dart';
import '../utils/constant/constant.dart';

class ApiService {
  static const String baseUrl = 'https://story-api.dicoding.dev/v1';

  // Auth endpoints
  Future<User> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      if (data['error'] == false) {
        final user = User.fromJson(data['loginResult']);

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(Constants.tokenKey, user.token);
        await prefs.setBool(Constants.isLoggedInKey, true);
        return user;
      } else {
        throw Exception(data['message']);
      }
    } else {
      throw Exception('Failed to login');
    }
  }

  Future<bool> register(String name, String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name, 'email': email, 'password': password}),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 201 && data['error'] == false) {
      return true;
    } else {
      throw Exception(data['message'] ?? 'Failed to register');
    }
  }

  // Stories endpoints
  Future<List<Story>> getStories() async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/stories'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      if (data['error'] == false) {
        final List<dynamic> storiesJson = data['listStory'];
        return storiesJson.map((json) => Story.fromJson(json)).toList();
      } else {
        throw Exception(data['message']);
      }
    } else {
      throw Exception('Failed to fetch stories');
    }
  }

  Future<Story> getStoryDetail(String id) async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/stories/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      if (data['error'] == false) {
        return Story.fromJson(data['story']);
      } else {
        throw Exception(data['message']);
      }
    } else {
      throw Exception('Failed to fetch story details');
    }
  }

  Future<bool> addStory(File photo, String description) async {
    final token = await _getToken();
    var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/stories'));

    request.headers['Authorization'] = 'Bearer $token';
    request.fields['description'] = description;
    request.files.add(await http.MultipartFile.fromPath('photo', photo.path));

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 201) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      if (data['error'] == false) {
        return true;
      } else {
        throw Exception(data['message']);
      }
    } else {
      throw Exception('Failed to add story');
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(Constants.tokenKey);
    await prefs.setBool(Constants.isLoggedInKey, false);
  }

  Future<String> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(Constants.tokenKey) ?? '';
    if (token.isEmpty) {
      throw Exception('You are not logged in');
    }
    return token;
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(Constants.isLoggedInKey) ?? false;
  }
}
