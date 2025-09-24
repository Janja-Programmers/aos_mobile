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

  bool _listLoading = false;
  bool get listLoading => _listLoading;

  bool _detailLoading = false;
  bool get detailLoading => _detailLoading;

  Failure? _failure;
  Failure? get failure => _failure;

  // Fetch all delivery notes
  Future<void> fetchAll() async {
    _listLoading = true;
    _failure = null;
    notifyListeners();

    final result = await _getAllDeliveryNotes();
    result.fold((f) => _failure = f, (data) => _notes = data);

    _listLoading = false;
    notifyListeners();
  }

  // Fetch single note by ID
  Future<void> fetchById(String id) async {
    _detailLoading = true;
    _failure = null;
    notifyListeners();

    final result = await _getById(id);
    result.fold((f) => _failure = f, (note) => _selectedNote = note);

    _detailLoading = false;
    notifyListeners();
  }

  // Stub for printing
  Future<void> printNote(BuildContext context, DeliveryNote note) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Printing not implemented yet.')),
    );
  }
}
