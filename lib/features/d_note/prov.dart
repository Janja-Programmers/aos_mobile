import 'package:flutter/material.dart';

import '/core/errors/failures.dart';

import 'domain/entity/delivery_note.dart';
import './domain/usecases.dart';

class DeliveryNoteProvider with ChangeNotifier {
  final GetAllDeliveryNotes _getAllDeliveryNotes;
  final GetDeliveryNoteById _getById;

  DeliveryNoteProvider({
    required GetAllDeliveryNotes getAllDeliveryNotes,
    required GetDeliveryNoteById getById,
  }) : _getAllDeliveryNotes = getAllDeliveryNotes,
       _getById = getById;

  List<DeliveryNote> _notes = [];
  List<DeliveryNote> get notes => _notes;

  DeliveryNote? _selectedNote;
  DeliveryNote? get selectedNote => _selectedNote;

  bool _loading = false;
  bool get loading => _loading;

  Failure? _failure;
  Failure? get failure => _failure;

  /// Fetch all delivery notes
  Future<void> fetchAll() async {
    _setLoading(true);
    _failure = null;

    final result = await _getAllDeliveryNotes();
    result.fold((f) => _failure = f, (data) => _notes = data);

    _setLoading(false);
  }

  /// Fetch single note by ID
  Future<void> fetchById(String id) async {
    _setLoading(true);
    _failure = null;

    final result = await _getById(id);
    result.fold((f) => _failure = f, (note) => _selectedNote = note);

    _setLoading(false);
  }

  /// (Stub) Print delivery note
  Future<void> printNote(BuildContext context, DeliveryNote note) async {
    // Hook this to your print_delivery_note.dart logic

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Printing not implemented yet.')),
    );
  }

  void _setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }
}
