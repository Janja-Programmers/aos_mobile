import 'package:flutter/material.dart';

import '/core/errors/failures.dart';

import './domain/delivery_note.dart';
import './domain/usecases.dart';

class DeliveryNoteProvider with ChangeNotifier {
  final GetAllDeliveryNotes _getAllDeliveryNotes;

  DeliveryNoteProvider({required GetAllDeliveryNotes getAllDeliveryNotes})
    : _getAllDeliveryNotes = getAllDeliveryNotes;

  List<DeliveryNote> _notes = [];
  List<DeliveryNote> get notes => _notes;

  bool _loading = false;
  bool get loading => _loading;

  Failure? _failure;
  Failure? get failure => _failure;

  Future<void> fetchAll() async {
    _loading = true;
    _failure = null;
    notifyListeners();

    final result = await _getAllDeliveryNotes();

    result.fold((f) => _failure = f, (data) => _notes = data);

    _loading = false;
    notifyListeners();
  }
}
