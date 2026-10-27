import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  factory DatabaseService() {
    return _instance;
  }

  DatabaseService._internal();

  Future<void> addFoodItem({
    required String name,
    required num price,
    required String category,
    required String description,
    required String imagePath,
    bool isAvailable = true,
    bool isPopular = false, // Optional field to mark popular items
    double rating = 0.0, // Default rating
    List<Map<String, dynamic>> extraItems = const [], // Optional extra items
  }) async {
    try {
      await FirebaseFirestore.instance.collection('food_items').add({
        'name': name,
        'price': price,
        'category': category,
        'description': description,
        'imagePath': imagePath,
        'isPopular': isPopular,
        'rating': rating,
        'extraItems': extraItems,
      });
      print('Food item "$name" added successfully.');
    } catch (e) {
      print('Error adding food item: $e');
    }
  }

  Future<void> addToCart(String imagePath, String name, int price,
      String extras, String userEmail) async {
    await _firestore.collection('cart').add({
      'imagePath': imagePath,
      'name': name,
      'price': price,
      'extras': extras,
      'userEmail': userEmail,
    });
  }

  Future<void> addToOrder(
    String imagePath,
    String name,
    int price,
    String extras,
    String userEmail,
  ) async {
    await _firestore.collection('orders').add({
      'imagePath': imagePath,
      'name': name,
      'price': price,
      'userEmail': userEmail,
      'extras': extras,
      'status': 'Dalam Proses',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> removeFromCart(String cartId) async {
    await _firestore.collection('cart').doc(cartId).delete();
  }

  Future<List<Map<String, dynamic>>> getCart(String userEmail) async {
    QuerySnapshot snapshot = await _firestore
        .collection('cart')
        .where('userEmail', isEqualTo: userEmail)
        .get();
    return snapshot.docs
        .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
        .toList();
  }

  Future<List<Map<String, dynamic>>> getOrders(String userEmail) async {
    QuerySnapshot snapshot = await _firestore
        .collection('orders')
        .where('userEmail', isEqualTo: userEmail)
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs
        .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
        .toList();
  }

  Stream<List<Map<String, dynamic>>> streamOrders(String userEmail) {
    return _firestore
        .collection('orders')
        .where('userEmail', isEqualTo: userEmail)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return {'id': doc.id, ...doc.data()};
      }).toList();
    });
  }

  Stream<List<Map<String, dynamic>>> streamNewOrders() {
    return _firestore
        .collection('orders')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return {'id': doc.id, ...doc.data()};
      }).toList();
    });
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    await _firestore
        .collection('orders')
        .doc(orderId)
        .update({'status': status});
  }

  Future<void> clearCart(String userEmail) async {
    QuerySnapshot snapshot = await _firestore
        .collection('cart')
        .where('userEmail', isEqualTo: userEmail)
        .get();
    for (var doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }

  Future<List<Map<String, dynamic>>> getUserOrders(String userEmail) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('orders')
          .where('userEmail', isEqualTo: userEmail)
          .orderBy('createdAt', descending: true)
          .get();
      return snapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
          .toList();
    } catch (e) {
      print('Error fetching user orders: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getAllOrders() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('orders')
          .orderBy('createdAt', descending: true)
          .get();
      return snapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
          .toList();
    } catch (e) {
      print('Error fetching all orders: $e');
      return [];
    }
  }

  Future<List<DateTime>> getOrderDates() async {
    try {
      QuerySnapshot snapshot =
          await _firestore.collection('orders').orderBy('createdAt').get();

      // Konversi ke daftar tanggal unik
      return snapshot.docs
          .map((doc) => (doc['createdAt'] as Timestamp)
              .toDate()
              .toLocal()) // Firestore Timestamp ke DateTime
          .toSet()
          .toList();
    } catch (e) {
      return [];
    }
  }

  // Total pendapatan untuk tanggal tertentu
  Future<int> getTotalForDate(DateTime date) async {
    try {
      // Tentukan awal dan akhir hari
      DateTime startOfDay = DateTime(date.year, date.month, date.day);
      DateTime endOfDay = startOfDay.add(const Duration(days: 1));

      // Query dokumen yang berada di antara startOfDay dan endOfDay
      QuerySnapshot snapshot = await _firestore
          .collection('orders')
          .where('createdAt', isGreaterThanOrEqualTo: startOfDay)
          .where('createdAt', isLessThan: endOfDay)
          .get();

      // Hitung total harga dari dokumen
      int total = snapshot.docs.fold(0, (sum, doc) {
        final data = doc.data() as Map<String, dynamic>; // Cast ke Map
        final price = data['price'] as int? ?? 0; // Tangani null secara aman
        return sum + price;
      });

      return total;
    } catch (e) {
      print('Error calculating total for date: $e');
      return 0; // Kembalikan 0 jika terjadi error
    }
  }

  Future<int> getTotalForMonth(DateTime date) async {
    try {
      DateTime startOfMonth = DateTime(date.year, date.month, 1);
      DateTime endOfMonth = DateTime(date.year, date.month + 1, 1);

      QuerySnapshot snapshot = await _firestore
          .collection('orders')
          .where('createdAt', isGreaterThanOrEqualTo: startOfMonth)
          .where('createdAt', isLessThan: endOfMonth)
          .get();

      int total = snapshot.docs.fold(0, (sum, doc) {
        final data = doc.data() as Map<String, dynamic>;
        final price = data['price'] as int? ?? 0;
        return sum + price;
      });

      return total;
    } catch (e) {
      return 0;
    }
  }

  Future<int> getTotalForYear(DateTime date) async {
    try {
      DateTime startOfYear = DateTime(date.year, 1, 1);
      DateTime endOfYear = DateTime(date.year + 1, 1, 1);

      QuerySnapshot snapshot = await _firestore
          .collection('orders')
          .where('createdAt', isGreaterThanOrEqualTo: startOfYear)
          .where('createdAt', isLessThan: endOfYear)
          .get();

      int total = snapshot.docs.fold(0, (sum, doc) {
        final data = doc.data() as Map<String, dynamic>;
        final price = data['price'] as int? ?? 0;
        return sum + price;
      });

      return total;
    } catch (e) {
      return 0;
    }
  }

  // Jumlah order untuk tanggal tertentu
  Future<int> getOrderCountForDate(DateTime date) async {
    try {
      DateTime startOfDay = DateTime(date.year, date.month, date.day);
      DateTime endOfDay = startOfDay.add(const Duration(days: 1));

      QuerySnapshot snapshot = await _firestore
          .collection('orders')
          .where('createdAt', isGreaterThanOrEqualTo: startOfDay)
          .where('createdAt', isLessThan: endOfDay)
          .get();

      return snapshot.docs.length;
    } catch (e) {
      return 0;
    }
  }

  // Jumlah order untuk bulan tertentu
  Future<int> getOrderCountForMonth(DateTime date) async {
    try {
      DateTime startOfMonth = DateTime(date.year, date.month, 1);
      DateTime endOfMonth = DateTime(date.year, date.month + 1, 1);

      QuerySnapshot snapshot = await _firestore
          .collection('orders')
          .where('createdAt', isGreaterThanOrEqualTo: startOfMonth)
          .where('createdAt', isLessThan: endOfMonth)
          .get();

      return snapshot.docs.length;
    } catch (e) {
      return 0;
    }
  }

  // Jumlah order untuk tahun tertentu
  Future<int> getOrderCountForYear(DateTime date) async {
    try {
      DateTime startOfYear = DateTime(date.year, 1, 1);
      DateTime endOfYear = DateTime(date.year + 1, 1, 1);

      QuerySnapshot snapshot = await _firestore
          .collection('orders')
          .where('createdAt', isGreaterThanOrEqualTo: startOfYear)
          .where('createdAt', isLessThan: endOfYear)
          .get();

      return snapshot.docs.length;
    } catch (e) {
      return 0;
    }
  }

  Future<void> sendMessage({
    required String senderEmail,
    required String receiverEmail,
    required String message,
  }) async {
    try {
      await _firestore.collection('messages').add({
        'senderEmail': senderEmail,
        'receiverEmail': receiverEmail,
        'message': message,
        'timestamp': FieldValue.serverTimestamp(),
      });
      print('Message sent successfully.');
    } catch (e) {
      print('Error sending message: $e');
    }
  }

  Stream<List<Map<String, dynamic>>> streamMessages(String userEmail) {
    return _firestore
        .collection('messages')
        .where('receiverEmail', isEqualTo: userEmail)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return {'id': doc.id, ...doc.data()};
      }).toList();
    });
  }
}
