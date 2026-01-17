import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';

Future<void> testFirebaseConnection() async {
  print('\n🧪 Testing Firebase Connection...\n');

  // Wait for Firebase to be ready
  await Future.delayed(Duration(seconds: 2));

  try {
    // Test Firestore
    print('📍 Testing Firestore...');
    final firestore = FirebaseFirestore.instance;
    final testDoc = await firestore.collection('test').doc('connection').get();
    print('✅ Firestore Connected: ${testDoc.exists ? 'Data exists' : 'No data yet'}');
  } catch (e) {
    print('❌ Firestore Error: $e');
  }

  // Test Realtime Database (WEB FIXED)
try {
  print('\n📍 Testing Realtime Database...');

  final database = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL:
        'https://bus-tracking-mobile-app-cfaa2-default-rtdb.firebaseio.com',
  );

  final ref = database.ref('test/connection');
  final snapshot = await ref.get();

  print(
    '✅ Realtime DB Connected: ${snapshot.exists ? 'Data exists' : 'No data yet'}',
  );
} catch (e) {
  print('❌ Realtime DB Error: $e');
}


  print('\n✅ Firebase Connection Test Complete!\n');
}
