import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:islamia/core/services/exceptions/service_exception.dart';
import '../firebase/firebase_config.dart';

abstract class BaseService<T> {
  final String collectionName;
  
  BaseService(this.collectionName);

  CollectionReference<Map<String, dynamic>> get collection =>
      FirebaseConfig.firestore.collection(collectionName);

  DocumentReference<Map<String, dynamic>> doc(String id) =>
      collection.doc(id);

  // Abstract methods to be implemented by concrete services
  T fromJson(Map<String, dynamic> json);
  Map<String, dynamic> toJson(T model);

  // Common CRUD operations
  Future<String> create(T model) async {
    try {
      final docRef = collection.doc();
      final data = toJson(model);
      data['id'] = docRef.id;
      data['createdAt'] = FieldValue.serverTimestamp();
      data['updatedAt'] = FieldValue.serverTimestamp();
      
      await docRef.set(data);
      return docRef.id;
    } catch (e) {
      throw ServiceException('Failed to create document: $e');
    }
  }

  Future<T?> read(String id) async {
    try {
      final doc = await collection.doc(id).get();
      if (doc.exists && doc.data() != null) {
        return fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      throw ServiceException('Failed to read document: $e');
    }
  }

  Future<void> update(String id, T model) async {
    try {
      final data = toJson(model);
      data['updatedAt'] = FieldValue.serverTimestamp();
      await collection.doc(id).update(data);
    } catch (e) {
      throw ServiceException('Failed to update document: $e');
    }
  }

  Future<void> delete(String id) async {
    try {
      await collection.doc(id).delete();
    } catch (e) {
      throw ServiceException('Failed to delete document: $e');
    }
  }

  Future<List<T>> getAll({
    int? limit,
    DocumentSnapshot? startAfter,
    Query<Map<String, dynamic>>? Function(Query<Map<String, dynamic>>)? queryBuilder,
  }) async {
    try {
      Query<Map<String, dynamic>> query = collection;
      
      if (queryBuilder != null) {
        query = queryBuilder(query)!;
      }
      
      if (limit != null) {
        query = query.limit(limit);
      }
      
      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }
      
      final snapshot = await query.get();
      return snapshot.docs.map((doc) => fromJson(doc.data())).toList();
    } catch (e) {
      throw ServiceException('Failed to get documents: $e');
    }
  }
}
