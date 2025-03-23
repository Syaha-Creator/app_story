import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/story_model.dart';
import '../models/user_model.dart';
import '../utils/constant/constant.dart';

class ApiService {
  static const String baseUrl = 'https://story-api.dicoding.dev/v1';

  Future<User> login(String email, String password) async {
    final response = await _postRequest(
      endpoint: '/login',
      body: {'email': email, 'password': password},
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 200 && data['error'] == false) {
      final user = User.fromJson(data['loginResult']);
      await _saveUserToPreferences(user);
      return user;
    } else {
      throw Exception(data['message'] ?? 'Failed to login');
    }
  }

  Future<bool> register(String name, String email, String password) async {
    final response = await _postRequest(
      endpoint: '/register',
      body: {'name': name, 'email': email, 'password': password},
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 201 && data['error'] == false) {
      return true;
    } else {
      throw Exception(data['message'] ?? 'Failed to register');
    }
  }

  Future<User?> getUserFromPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(Constants.tokenKey);
    final userId = prefs.getString('userId');
    final userName = prefs.getString('userName');

    if (token != null && userId != null && userName != null) {
      return User(userId: userId, name: userName, token: token);
    }
    return null;
  }

  Future<List<Story>> getStories({int page = 1, int size = 10}) async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/stories?page=$page&size=$size'),
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
    final response = await _getRequest(endpoint: '/stories/$id');
    final data = jsonDecode(response.body);
    if (response.statusCode == 200 && data['error'] == false) {
      return Story.fromJson(data['story']);
    } else {
      throw Exception(data['message'] ?? 'Failed to fetch story details');
    }
  }

  Future<bool> addStory(
    File photo,
    String description, {
    double? lat,
    double? lon,
  }) async {
    final token = await _getToken();
    var request =
        http.MultipartRequest('POST', Uri.parse('$baseUrl/stories'))
          ..headers['Authorization'] = 'Bearer $token'
          ..fields['description'] = description;

    if (lat != null && lon != null) {
      request.fields['lat'] = lat.toString();
      request.fields['lon'] = lon.toString();
    }

    request.files.add(await http.MultipartFile.fromPath('photo', photo.path));

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    final data = jsonDecode(response.body);
    if (response.statusCode == 201 && data['error'] == false) {
      return true;
    } else {
      throw Exception(data['message'] ?? 'Failed to add story');
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(Constants.isLoggedInKey) ?? false;
  }

  Future<http.Response> _postRequest({
    required String endpoint,
    required Map<String, dynamic> body,
  }) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    return response;
  }

  Future<http.Response> _getRequest({required String endpoint}) async {
    final token = await _getToken();
    final url = Uri.parse('$baseUrl$endpoint');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    return response;
  }

  Future<String> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(Constants.tokenKey);
    if (token == null || token.isEmpty) {
      throw Exception('You are not logged in');
    }
    return token;
  }

  Future<void> _saveUserToPreferences(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(Constants.tokenKey, user.token);
    await prefs.setBool(Constants.isLoggedInKey, true);
    await prefs.setString('userId', user.userId);
    await prefs.setString('userName', user.name);
  }
}
