// import 'package:flutter/material.dart';
// import '../../domain/item.dart';

// class AddItemModal extends StatefulWidget {
//   final int userId;

//   const AddItemModal({super.key, required this.userId});

//   @override
//   State<AddItemModal> createState() => _AddItemModalState();
// }

// class _AddItemModalState extends State<AddItemModal> {
//   final _formKey = GlobalKey<FormState>();

//   final TextEditingController _itemCodeController = TextEditingController();
//   final TextEditingController _itemNameController = TextEditingController();
//   final TextEditingController _itemGroupController = TextEditingController();

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.all(16.0),
//       child: Form(
//         key: _formKey,
//         child: Wrap(
//           runSpacing: 12,
//           children: [
//             const Text(
//               'Add New Item',
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//             TextFormField(
//               controller: _itemCodeController,
//               decoration: const InputDecoration(labelText: 'Item Code'),
//               validator: (value) => value!.isEmpty ? 'Required' : null,
//             ),
//             TextFormField(
//               controller: _itemNameController,
//               decoration: const InputDecoration(labelText: 'Item Name'),
//               validator: (value) => value!.isEmpty ? 'Required' : null,
//             ),
//             TextFormField(
//               controller: _itemGroupController,
//               decoration: const InputDecoration(labelText: 'Item Group'),
//               validator: (value) => value!.isEmpty ? 'Required' : null,
//             ),
//             ElevatedButton(
//               onPressed: () async {
//                 if (_formKey.currentState!.validate()) {
//                   final newItem = Item(
//                     itemCode: _itemCodeController.text,
//                     name: _itemNameController.text,
//                     itemGroup: _itemGroupController.text,
//                   );
//                   // await itemProvider.addItem(newItem);
//                   print(newItem);
//                   Navigator.of(context).pop();
//                 }
//               },
//               child: const Text('Save Item'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
