// import 'package:flutter/material.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:food_app/screens/menu/menu.dart';
// import 'firebase_test_setup.dart';

// void main() {
//   setUpAll(() async {
//     await setupFirebaseAuthMocks();
//   });

//   testWidgets('MenuScreen displays correctly', (WidgetTester tester) async {
//     await tester.pumpWidget(MaterialApp(home: MenuScreen()));

//     // Verify that the MenuScreen displays the loading indicator
//     expect(find.byType(CircularProgressIndicator), findsOneWidget);

//     // Mock the location and food items fetching
//     await tester.pumpAndSettle();

//     // Verify that the MenuScreen displays the address and food items
//     expect(find.text('Fetching location...'), findsOneWidget);
//     expect(find.byType(GridView), findsOneWidget);
//   });
// }
