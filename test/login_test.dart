import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_workshop/base/dependency_provider.dart';
import 'package:flutter_workshop/feature/home/home.dart';
import 'package:flutter_workshop/feature/login/login.dart';
import 'package:flutter_workshop/model/login/login_response.dart';
import 'package:flutter_workshop/model/user/user.dart';
import 'package:flutter_workshop/util/http_event.dart';
import 'package:mockito/mockito.dart';

import 'test_util/mocks.dart';
import 'test_util/test_util.dart';

void main() {
  MockLoginBloc _mockLoginBloc;
  MockHomeBloc _mockHomeBloc;
  MockLoginResponseStream _mockLoginStream;
  MockNavigatorObserver _mockNavigationObserver;
  Widget _testableWidget;
  Finder _emailField;
  Finder _passwordField;
  Finder _submitButton;
  StreamController _streamController;

  setUp(() {
    _mockLoginBloc = MockLoginBloc();
    _mockHomeBloc = MockHomeBloc();
    _mockLoginStream = MockLoginResponseStream();
    _mockNavigationObserver = MockNavigatorObserver();
    _streamController = StreamController<HttpEvent<LoginResponse>>.broadcast();

    _testableWidget = TestUtil.makeTestableWidget(
        subject: Login(),
        dependencies:
            AppDependencies(loginBloc: _mockLoginBloc, homeBloc: _mockHomeBloc),
        navigatorObservers: [_mockNavigationObserver]);

    _emailField = find.byKey(Login.emailFieldKey);
    _passwordField = find.byKey(Login.passwordFieldKey);
    _submitButton = find.byKey(Login.submitButtonKey);

    when(_mockLoginBloc.stream).thenAnswer((_) => _mockLoginStream);
  });

  group('attempts login', () {
    testWidgets('attempts login if email and password are valid',
        (WidgetTester tester) async {
      await tester.pumpWidget(_testableWidget);

      final email = 'test@test.com';
      final password = 'qwertyuiop';

      await tester.enterText(_emailField, email);
      await tester.enterText(_passwordField, password);
      await tester.tap(_submitButton);

      verify(_mockLoginBloc.login(email: email, password: password));
    });

    testWidgets('does not attempt login if email and password are empty',
        (WidgetTester tester) async {
      await tester.pumpWidget(_testableWidget);

      await tester.tap(_submitButton);

      verifyNever(_mockLoginBloc.login(email: '', password: ''));
    });

    testWidgets('does not attempt login if email is not a valid email',
        (WidgetTester tester) async {
      await tester.pumpWidget(_testableWidget);

      final email = 'invalid email';
      final password = 'qwertyuiop';

      await tester.enterText(_emailField, email);
      await tester.enterText(_passwordField, password);
      await tester.tap(_submitButton);

      verifyNever(_mockLoginBloc.login(email: email, password: password));
    });

    testWidgets('does not attempt login if password is too short',
        (WidgetTester tester) async {
      await tester.pumpWidget(_testableWidget);

      final email = 'test@test.com';
      final password = '123';

      await tester.enterText(_emailField, email);
      await tester.enterText(_passwordField, password);
      await tester.tap(_submitButton);

      verifyNever(_mockLoginBloc.login(email: email, password: password));
    });
  });

  group('shows validation messages', () {
    testWidgets('shows invalid email error message',
        (WidgetTester tester) async {
      await tester.pumpWidget(_testableWidget);

      final email = 'invalid email';
      final password = 'qwertyuiop';

      await tester.enterText(_emailField, email);
      await tester.enterText(_passwordField, password);
      await tester.tap(_submitButton);

      await tester.pumpAndSettle();

      final errorMessage = TestUtil.findInternationalizedText(
          'validation_message_email_invalid');

      expect(errorMessage, findsOneWidget);
    });

    testWidgets('shows required email error message',
        (WidgetTester tester) async {
      await tester.pumpWidget(_testableWidget);

      final password = 'qwertyuiop';

      await tester.enterText(_passwordField, password);
      await tester.tap(_submitButton);

      await tester.pumpAndSettle();

      final errorMessage = TestUtil.findInternationalizedText(
          'validation_message_email_required');

      expect(errorMessage, findsOneWidget);
    });

    testWidgets('shows password too short error message',
        (WidgetTester tester) async {
      await tester.pumpWidget(_testableWidget);

      final email = 'test@test.com';
      final password = '123';

      await tester.enterText(_emailField, email);
      await tester.enterText(_passwordField, password);
      await tester.tap(_submitButton);

      await tester.pumpAndSettle();

      final errorMessage = TestUtil.findInternationalizedText(
          'validation_message_password_too_short');

      expect(errorMessage, findsOneWidget);
    });

    testWidgets('shows password required error message',
        (WidgetTester tester) async {
      await tester.pumpWidget(_testableWidget);

      final email = 'test@test.com';

      await tester.enterText(_emailField, email);
      await tester.tap(_submitButton);

      await tester.pumpAndSettle();

      final errorMessage = TestUtil.findInternationalizedText(
          'validation_message_password_required');

      expect(errorMessage, findsOneWidget);
    });
  });

  group('handles login stream events', () {
    testWidgets('shows circular progress inidicator when loading',
        (WidgetTester tester) async {
      when(_mockLoginBloc.stream).thenAnswer((_) => _streamController.stream);

      await tester.pumpWidget(_testableWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);

      _streamController.sink
          .add(HttpEvent<LoginResponse>(state: EventState.loading));
      await tester.pump(Duration.zero);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('navigates to home screen when login succeeds',
        (WidgetTester tester) async {
      when(_mockLoginBloc.stream).thenAnswer((_) => _streamController.stream);

      await tester.pumpWidget(_testableWidget);
      _streamController.sink.add(HttpEvent<LoginResponse>(
          state: EventState.done, data: LoginResponse('token', User.fake())));
      await tester.pump(Duration.zero);
      verify(_mockNavigationObserver.didPush(any, any));
      expect(find.byType(Home), findsOneWidget);
    });
  });

  tearDown(() {
    _streamController.close();
  });
}
