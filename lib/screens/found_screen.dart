import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FoundScreen extends StatefulWidget {
  static String id = 'found_screen';

  @override
  _FoundScreenState createState() => _FoundScreenState();
}

class _FoundScreenState extends State<FoundScreen> {
  final _formKey = GlobalKey<FormState>();

  String? _reporterName;
  String? _reporterId;
  String? _reporterDepartment;
  String? _itemName;
  String? _category;
  String? _location;
  String? _description;
  String? _contactEmail;
  String? _contactPhone;
  DateTime? _selectedDate;
  File? _image;
  final ImagePicker _picker = ImagePicker();

  List<String> _categories = [
    'Electronics',
    'Clothing',
    'Books',
    'Accessories',
    'Other',
  ];

  Future<void> _pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _image = File(pickedFile.path));
    }
  }

  void _removeImage() {
    setState(() => _image = null);
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      String? imageUrl;
      if (_image != null) {
        final fileName =
            'found_images/${DateTime.now().millisecondsSinceEpoch}.jpg';
        final ref = FirebaseStorage.instance.ref().child(fileName);
        await ref.putFile(_image!);
        imageUrl = await ref.getDownloadURL();
      }

      final user = FirebaseAuth.instance.currentUser;

      await FirebaseFirestore.instance.collection('pending_found_items').add({
        'itemName': _itemName,
        'category': _category,
        'location': _location,
        'description': _description,
        'email': _contactEmail,
        'phoneNo': _contactPhone,
        'date': _selectedDate,
        'imageUrl': imageUrl,
        'type': 'found',
        'status': 'pending',
        'createdBy': user?.uid,
        'createdAt': Timestamp.now(),
        'reporterName': _reporterName,
        'reporterId': _reporterId,
        'reporterDepartment': _reporterDepartment,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Your item has been submitted for review.')),
      );

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Report Found Item'),
        backgroundColor: Color(0xFFBB99CD),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Reporter\'s Name(full)',
                ),
                onSaved: (value) => _reporterName = value,
                validator:
                    (value) => value!.isEmpty ? 'Please enter your name' : null,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Reporter\'s ID'),
                onSaved: (value) => _reporterId = value,
                validator:
                    (value) => value!.isEmpty ? 'Please enter your ID' : null,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Department'),
                onSaved: (value) => _reporterDepartment = value,
                validator:
                    (value) =>
                        value!.isEmpty ? 'Please enter your department' : null,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Item Name'),
                onSaved: (val) => _itemName = val,
                validator: (val) => val!.isEmpty ? 'Enter item name' : null,
              ),
              DropdownButtonFormField<String>(
                value: _category,
                items:
                    _categories
                        .map(
                          (cat) =>
                              DropdownMenuItem(value: cat, child: Text(cat)),
                        )
                        .toList(),
                onChanged: (val) => setState(() => _category = val),
                decoration: InputDecoration(labelText: 'Category'),
                validator: (val) => val == null ? 'Select a category' : null,
              ),
              ListTile(
                title: Text(
                  _selectedDate == null
                      ? 'Select Date Found'
                      : 'Date Found: ${_selectedDate!.toLocal()}'.split(' ')[0],
                ),
                trailing: Icon(Icons.calendar_today),
                onTap: () => _pickDate(context),
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Location Found'),
                onSaved: (val) => _location = val,
                validator: (val) => val!.isEmpty ? 'Enter location' : null,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Description'),
                maxLines: 3,
                onSaved: (val) => _description = val,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Email Address'),
                keyboardType: TextInputType.emailAddress,
                onSaved: (value) => _contactEmail = value,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please provide an email address';
                  } else if (!RegExp(
                    r"^[a-zA-Z0-9]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
                  ).hasMatch(value)) {
                    return 'Please enter a valid email address';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Phone Number'),
                keyboardType: TextInputType.phone,
                onSaved: (value) => _contactPhone = value,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please provide a phone number';
                  } else if (!RegExp(r"^\+?[0-9]{10,15}$").hasMatch(value)) {
                    return 'Please enter a valid phone number';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              Text(
                'Optional: Upload Item Image',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              GestureDetector(
                onTap: _pickImage,
                child:
                    _image == null
                        ? Container(
                          height: 150,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(child: Text('Tap to select image')),
                        )
                        : Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(
                                _image!,
                                height: 150,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              top: 5,
                              right: 5,
                              child: GestureDetector(
                                onTap: _removeImage,
                                child: CircleAvatar(
                                  radius: 14,
                                  backgroundColor: Colors.black.withOpacity(
                                    0.6,
                                  ),
                                  child: Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 15),
                  textStyle: TextStyle(fontSize: 16),
                  backgroundColor: Color(0xFFBB99CD),
                ),
                child: Text(
                  'Submit',
                  style: TextStyle(color: Color(0xFF3D1860)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
