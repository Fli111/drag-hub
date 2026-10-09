// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pertemuan_3/main.dart';

void main() {
  testWidgets('Login page and navigation smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify LoginPage elements
    expect(find.text('DRAG HUB'), findsOneWidget);
    expect(find.text('Masuk ke Akun'), findsOneWidget);
    expect(find.text('Masuk sebagai Tamu (Lihat Event)'), findsOneWidget);

    // Tap "Masuk sebagai Tamu" to enter HomePage
    await tester.tap(find.text('Masuk sebagai Tamu (Lihat Event)'));
    await tester.pumpAndSettle();

    // Verify AppBar title and bell icon
    expect(find.text('Event'), findsOneWidget);
    expect(find.byIcon(Icons.notifications_outlined), findsOneWidget);

    // Verify filter tabs
    expect(find.text('Ongoing'), findsOneWidget);
    expect(find.text('Upcoming'), findsOneWidget);

    // Verify event items
    expect(find.text('Drag Race Cup #3'), findsOneWidget);
    expect(find.text('Sirkuit BSD'), findsOneWidget);
    expect(find.text('Matic Open Class'), findsOneWidget);
    expect(find.text('Sentul'), findsOneWidget);

    // Verify bottom navigation bar
    expect(find.byType(BottomNavigationBar), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('History'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);
  });
}
