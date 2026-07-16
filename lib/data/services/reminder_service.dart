import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:home_management_app/domain/models/reminder.dart';
import 'package:home_management_app/data/services/authentication.service.dart';

class ReminderService {
  final AuthenticationService _authenticationService;
  final Uri backendEndpoint = Uri.https('www.ramiro-di-rico.dev', 'reminderapi/reminder');

  ReminderService(this._authenticationService);

  Future<List<Reminder>> getReminders() async {
    await _autoAuthenticateIfNeeded();
    final response = await http.get(
      backendEndpoint,
      headers: _getHeaders(),
    );
    if (response.statusCode == 200) {
      final List<dynamic> json = jsonDecode(response.body);
      return json.map((e) => Reminder.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load reminders');
    }
  }

  Future<Reminder> addReminder(Reminder reminder) async {
    await _autoAuthenticateIfNeeded();
    final response = await http.post(
      backendEndpoint,
      headers: _getHeaders(),
      body: jsonEncode(reminder.toJson()),
    );

    var okStatusCode = response.statusCode >= 200 && response.statusCode < 300;
    if (okStatusCode) {
      return Reminder.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to add reminder');
    }
  }

  Future<Reminder> updateReminder(int id, Reminder reminder) async {
    await _autoAuthenticateIfNeeded();
    final response = await http.put(
      backendEndpoint.resolve("reminder/${id}"),
      headers: _getHeaders(),
      body: jsonEncode(reminder.toJson()),
    );

    var okStatusCode = response.statusCode >= 200 && response.statusCode < 300;
    if (okStatusCode) {
      return Reminder.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to update reminder');
    }
  }

  Future<void> setAllCompleted(bool isCompleted) async {
    await _autoAuthenticateIfNeeded();
    final uri = backendEndpoint.replace(
      path: '${backendEndpoint.path}/completed',
      queryParameters: {
        'isCompleted': isCompleted.toString(),
      },
    );
    final response = await http.patch(
      uri,
      headers: _getHeaders(),
    );
    var okStatusCode = response.statusCode >= 200 && response.statusCode < 300;
    if (!okStatusCode) {
      throw Exception('Failed to set all reminders completion');
    }
  }

  Future<void> deleteReminder(String id) async {
    await _autoAuthenticateIfNeeded();
    final response = await http.delete(
      backendEndpoint.resolve("reminder/${id}"),
      headers: _getHeaders(),
    );
    var okStatusCode = response.statusCode >= 200 && response.statusCode < 300;
    if (!okStatusCode) {
      throw Exception('Failed to delete reminder');
    }
  }

  Future<void> snoozeReminder(int id, int days) async {
    await _autoAuthenticateIfNeeded();
    final uri = backendEndpoint.replace(
      path: '${backendEndpoint.path}/$id/snooze',
      queryParameters: {'days': days.toString()},
    );
    final response = await http.patch(
      uri,
      headers: _getHeaders(),
    );
    var okStatusCode = response.statusCode >= 200 && response.statusCode < 300;
    if (!okStatusCode) {
      throw Exception('Failed to snooze reminder');
    }
  }

  Future<void> updateNotificationPreferences(
      String userId, int digestFrequency, String? preferredSendTime) async {
    await _autoAuthenticateIfNeeded();
    final uri = backendEndpoint.replace(
      path: '/reminderapi/User/$userId/preferences',
    );
    final response = await http.patch(
      uri,
      headers: _getHeaders(),
      body: jsonEncode({
        'digestFrequency': digestFrequency,
        'preferredSendTime': preferredSendTime,
      }),
    );
    var okStatusCode = response.statusCode >= 200 && response.statusCode < 300;
    if (!okStatusCode) {
      throw Exception('Failed to update notification preferences');
    }
  }

  Future<Map<String, dynamic>> getNotificationPreferences() async {
    await _autoAuthenticateIfNeeded();
    final uri = backendEndpoint.replace(
      path: '/reminderapi/user/me',
    );
    final response = await http.get(
      uri,
      headers: _getHeaders(),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load notification preferences');
    }
  }

  Future _autoAuthenticateIfNeeded() async {
    if (!_authenticationService.isAuthenticated() &&
        _authenticationService.canAutoAuthenticate()) {
      await _authenticationService.autoAuthenticate();
    }
  }

  Map<String, String> _getHeaders() {
    final token = _authenticationService.getUserToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }
}