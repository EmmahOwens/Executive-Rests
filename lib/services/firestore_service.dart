import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Properties Collection
  final CollectionReference _propertiesCollection = 
      FirebaseFirestore.instance.collection('properties');
  
  // Users Collection
  final CollectionReference _usersCollection = 
      FirebaseFirestore.instance.collection('users');

  // Bookings Collection
  final CollectionReference _bookingsCollection = 
      FirebaseFirestore.instance.collection('bookings');

  // Payments Collection
  final CollectionReference _paymentsCollection = 
      FirebaseFirestore.instance.collection('payments');

  // Get all properties
  Stream<List<PropertyModel>> getProperties() {
    return _propertiesCollection
        .where('isAvailable', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => PropertyModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    });
  }

  // Get properties by landlord
  Stream<List<PropertyModel>> getLandlordProperties(String landlordId) {
    return _propertiesCollection
        .where('landlordId', isEqualTo: landlordId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => PropertyModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    });
  }

  // Get property by ID
  Future<PropertyModel?> getPropertyById(String propertyId) async {
    final DocumentSnapshot doc = await _propertiesCollection.doc(propertyId).get();
    if (doc.exists) {
      return PropertyModel.fromJson(doc.data() as Map<String, dynamic>);
    }
    return null;
  }

  // Add new property
  Future<String> addProperty(PropertyModel property) async {
    final DocumentReference docRef = await _propertiesCollection.add(property.toJson());
    return docRef.id;
  }

  // Update property
  Future<void> updateProperty(PropertyModel property) async {
    await _propertiesCollection.doc(property.id).update(property.toJson());
  }

  // Delete property
  Future<void> deleteProperty(String propertyId) async {
    await _propertiesCollection.doc(propertyId).delete();
  }

  // Get user by ID
  Future<UserModel?> getUserById(String userId) async {
    final DocumentSnapshot doc = await _usersCollection.doc(userId).get();
    if (doc.exists) {
      return UserModel.fromJson(doc.data() as Map<String, dynamic>);
    }
    return null;
  }

  // Search properties by location or title
  Future<List<PropertyModel>> searchProperties(String query) async {
    // Search by title
    final QuerySnapshot titleResults = await _propertiesCollection
        .where('title', isGreaterThanOrEqualTo: query)
        .where('title', isLessThanOrEqualTo: query + '\uf8ff')
        .get();

    // Search by location
    final QuerySnapshot locationResults = await _propertiesCollection
        .where('location', isGreaterThanOrEqualTo: query)
        .where('location', isLessThanOrEqualTo: query + '\uf8ff')
        .get();

    // Combine results
    final Set<String> uniqueIds = {};
    final List<PropertyModel> properties = [];

    for (final doc in titleResults.docs) {
      final String id = doc.id;
      if (!uniqueIds.contains(id)) {
        uniqueIds.add(id);
        properties.add(PropertyModel.fromJson(doc.data() as Map<String, dynamic>));
      }
    }

    for (final doc in locationResults.docs) {
      final String id = doc.id;
      if (!uniqueIds.contains(id)) {
        uniqueIds.add(id);
        properties.add(PropertyModel.fromJson(doc.data() as Map<String, dynamic>));
      }
    }

    return properties;
  }

  // Filter properties by criteria
  Future<List<PropertyModel>> filterProperties({
    double? minPrice,
    double? maxPrice,
    int? minBedrooms,
    int? maxBedrooms,
    List<String>? amenities,
  }) async {
    Query query = _propertiesCollection.where('isAvailable', isEqualTo: true);

    if (minPrice != null) {
      query = query.where('price', isGreaterThanOrEqualTo: minPrice);
    }

    if (maxPrice != null) {
      query = query.where('price', isLessThanOrEqualTo: maxPrice);
    }

    if (minBedrooms != null) {
      query = query.where('bedrooms', isGreaterThanOrEqualTo: minBedrooms);
    }

    final QuerySnapshot snapshot = await query.get();

    List<PropertyModel> properties = snapshot.docs
        .map((doc) => PropertyModel.fromJson(doc.data() as Map<String, dynamic>))
        .toList();

    // Apply additional filters that can't be done in the query
    if (maxBedrooms != null) {
      properties = properties.where((p) => p.bedrooms <= maxBedrooms).toList();
    }

    if (amenities != null && amenities.isNotEmpty) {
      properties = properties.where((p) {
        for (final amenity in amenities) {
          if (!p.amenities.contains(amenity)) return false;
        }
        return true;
      }).toList();
    }

    return properties;
  }
}