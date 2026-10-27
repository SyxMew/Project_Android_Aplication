// import 'package:flutter/material.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:food_app/screens/home/home.dart';
// import 'package:food_app/utils/location_utils.dart';
// import 'firebase_test_setup.dart';

// void main() {
//   setUpAll(() async {
//     await setupFirebaseAuthMocks();
//   });

//   testWidgets('HomeScreen displays correctly', (WidgetTester tester) async {
//     await tester.pumpWidget(MaterialApp(home: HomeScreen()));

//     // Verify that the HomeScreen displays the loading indicator
//     expect(find.byType(CircularProgressIndicator), findsOneWidget);

//     // Mock the location and food items fetching
//     await tester.pumpAndSettle();

//     // Verify that the HomeScreen displays the address and food items
//     expect(find.text('Fetching location...'), findsOneWidget);
//     expect(find.byType(GridView), findsOneWidget);
//   });
// }
