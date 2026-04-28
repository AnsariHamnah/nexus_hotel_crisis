import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/alert_model.dart';

class AlertService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Real-time alerts stream
  Stream<List<AlertModel>> get alertsStream {
    return _firestore
        .collection('alerts')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => AlertModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  // Single alert stream
  Stream<AlertModel?> getAlertStream(String id) {
    return _firestore.collection('alerts').doc(id).snapshots().map((doc) {
      if (!doc.exists) return null;
      return AlertModel.fromMap(doc.data()!, doc.id);
    });
  }
}
