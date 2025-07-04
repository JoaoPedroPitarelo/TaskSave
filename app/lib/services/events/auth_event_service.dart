import 'dart:async';

import 'package:app/domain/events/auth_events.dart';


class AuthEventService {
  static final AuthEventService _instance = AuthEventService._internal();

  AuthEventService._internal();

  factory AuthEventService() {
    return _instance;
  }

  final StreamController<AuthDataEvent> _authEventsController = StreamController<AuthDataEvent>.broadcast();
  Stream<AuthDataEvent> get onAuthChanged => _authEventsController.stream;

  void add(AuthDataEvent event) {
    _authEventsController.add(event);
  }

  void dispose() {
    _authEventsController.close();
  }
}