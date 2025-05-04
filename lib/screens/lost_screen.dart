import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';

class LostScreen extends StatefulWidget {
  static String id = 'lost_screen';

  @override
  _LostScreenState createState() => _LostScreenState();
}

class _LostScreenState extends State<LostScreen> {
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

  List<String> _categories = [
    'Electronics',
    'Clothing',
    'Books',
    'Accessories',
    'Other',
  ];

  Future<void> _pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate)
      setState(() {
        _selectedDate = picked;
      });
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      try {
        await FirebaseFirestore.instance.collection('lost_items').add({
          'reporterName': _reporterName,
          'reporterId': _reporterId,
          'reporterDepartment': _reporterDepartment,
          'itemName': _itemName,
          'category': _category,
          'dateLost': _selectedDate?.toIso8601String(),
          'location': _location,
          'description': _description,
          'email': _contactEmail,
          'phoneNo': _contactPhone,
          'imagePath': _image?.path, // Optional local path
          'timestamp': FieldValue.serverTimestamp(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lost item reported successfully!')),
        );

        setState(() {
          _formKey.currentState?.reset();
          _image = null;
          _selectedDate = null;
          _category = null;
        });
      } catch (e) {
        print('Error saving to Firestore: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit. Please try again.')),
        );
      }
    }
  }

  File? _image;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5EDF7),
      appBar: AppBar(
        title: Text('Report Lost Item'),
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
                onSaved: (value) => _itemName = value,
                validator:
                    (value) => value!.isEmpty ? 'Please enter item name' : null,
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
                onChanged: (value) => setState(() => _category = value),
                decoration: InputDecoration(labelText: 'Category'),
                validator:
                    (value) =>
                        value == null ? 'Please select a category' : null,
              ),
              SizedBox(height: 10),
              ListTile(
                title: Text(
                  _selectedDate == null
                      ? 'Select Date Lost'
                      : 'Date Lost: ${_selectedDate!.toLocal()}'.split(' ')[0],
                ),
                trailing: Icon(Icons.calendar_today),
                onTap: () => _pickDate(context),
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Last Seen Location'),
                onSaved: (value) => _location = value,
                validator:
                    (value) => value!.isEmpty ? 'Please enter location' : null,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Description'),
                maxLines: 3,
                onSaved: (value) => _description = value,
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child:
                        _image == null
                            ? Container(
                              height: 150,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(child: Text('Tap to select image')),
                            )
                            : ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(
                                _image!,
                                height: 150,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                  ),
                  if (_image != null)
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: () {
                          setState(() {
                            _image = null;
                          });
                        },
                        icon: Icon(Icons.delete, color: Colors.red),
                        label: Text(
                          'Remove Image',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ),
                ],
              ),
              SizedBox(height: 30),
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
