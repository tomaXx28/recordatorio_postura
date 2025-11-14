import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/reminder.dart';

class FirebaseService {
  final CollectionReference _col =
      FirebaseFirestore.instance.collection('reminders');

  Stream<List<Reminder>> listenReminders() {
    return _col.snapshots().map(
      (snapshot) {
        return snapshot.docs
            .map((doc) =>
                Reminder.fromJson(doc.data() as Map<String, dynamic>))
            .toList();
      },
    );
  }

  Future<void> saveReminder(Reminder r) async {
    await _col.doc(r.id).set(r.toJson());
  }

  Future<void> deleteReminder(String id) async {
    await _col.doc(id).delete();
  }
}
