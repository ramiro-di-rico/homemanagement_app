import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/reminder.dart';
import '../security/authentication.service.dart';

class ReminderService {
  final AuthenticationService _authenticationService;
  final Uri backendEndpoint = Uri.https('www.ramiro-di-rico.dev', 'reminderapi/reminder');

  ReminderService(this._authenticationService);

  Future<List<Reminder>> getReminders() async {
    final token = await _authenticationService.getUserToken();
    final response = await http.get(
      backendEndpoint,
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      final List<dynamic> json = jsonDecode(response.body);
      return json.map((e) => Reminder.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load reminders');
    }
  }

  Future<Reminder> addReminder(Reminder reminder) async {
    final token = await _authenticationService.getUserToken();
    final response = await http.post(
      backendEndpoint,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(reminder.toJson()),
    );

    var okStatusCode = response.statusCode > 200 && response.statusCode < 300;
    if (okStatusCode) {
      return Reminder.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to add reminder');
    }
  }

  Future<Reminder> updateReminder(int id, Reminder reminder) async {
    final token = await _authenticationService.getUserToken();
    final response = await http.put(
      backendEndpoint.resolve("reminder"),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(reminder.toJson()),
    );

    var okStatusCode = response.statusCode >= 200 && response.statusCode < 300;
    if (okStatusCode) {
      return Reminder.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to update reminder');
    }
  }

  Future<void> deleteReminder(String id) async {
    final token = await _authenticationService.getUserToken();
    final response = await http.delete(
      backendEndpoint.resolve("reminder/${id}"),
      headers: {'Authorization': 'Bearer $token'},
    );
    var okStatusCode = response.statusCode > 200 && response.statusCode < 300;
    if (!okStatusCode) {
      throw Exception('Failed to delete reminder');
    }
  }
}