import 'package:cloud_firestore/cloud_firestore.dart';

class FetchService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<Map<String, dynamic>>> fetchVehicles() {
    return _firestore.collection('vehicles').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return {
          'id': doc['vehicle_id'].toString(),
          'brand': doc['brand'] ?? '',
          'model': doc['model'] ?? '',
          'plate_num': doc['plate_num'] ?? '',
          'body_type': doc['body_type'] ?? '',
          'color': doc['color'] ?? '',
          'rental_rate': doc['rental_rate'] ?? '',
          'status': doc['status'] ?? '',
        };
      }).toList();
    });
  }

  Stream<List<Map<String, dynamic>>> fetchStaffs() {
    return _firestore.collection('staffs').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return {
          'id': doc['staff_id'].toString(),
          'firstname': doc['firstname'] ?? '',
          'lastname': doc['lastname'] ?? '',
          'job_position': doc['job_position'] ?? '',
          'contact': doc['contact_num'] ?? '',
          'email': doc['email'] ?? '',
          'status': doc['status'] == true ? 'Active' : 'Inactive',
        };
      }).toList();
    });
  }

  Stream<List<Map<String, dynamic>>> fetchMaintenance() {
    return _firestore.collection('maintenance').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return {
          'id': doc['maintenance_id'],
          'vehicle_id': doc['vehicle_id'],
          'maintenance_type': doc['maintenance_type'].join(", "),
          'start_date': doc['start_date'],
          'end_date': doc['end_date'],
          'status': doc['status'],
        };
      }).toList();
    });
  }
}
