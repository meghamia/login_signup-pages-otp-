import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;


import 'package:flutter/material.dart';

import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:my_chat/pages/login.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  File? _imageFile;
  bool _changesMade = false;
  bool _saving = false;
  TextEditingController _nameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            _handleBackButton();
          },
        ),
        actions: [
          if (_changesMade)
            IconButton(
              icon: Icon(Icons.save),
              onPressed: () {
                _saveChanges();
              },
            ),

          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              _logout();
            },
          ),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundImage: _imageFile != null
                        ? FileImage(_imageFile!)
                        : null,
                    child: _imageFile == null
                        ? Icon(
                      Icons.person,
                      size: 50,
                    )
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () {
                        _showImageSourceDialog(context);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 20),
          // User details
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'User Name',
              ),
              onChanged: (value) {
                setState(() {
                  _changesMade = true;
                });
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
              ),
              onChanged: (value) {
                setState(() {
                  _changesMade = true;
                });
              },
            ),
          ),
          if (_saving)
            CircularProgressIndicator()
          else
            if (_changesMade)
              ElevatedButton(
                onPressed: () {
                  _saveChanges();
                },
                child: Text('Save Changes'),
              ),
        ],
      ),
    );
  }

  Future<void> _showImageSourceDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Image Source'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                ListTile(
                  leading: Icon(Icons.photo_camera),
                  title: Text('Take a Photo'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _pickImage(ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.photo),
                  title: Text('Select from Gallery'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _pickImage(ImageSource.gallery);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
        _changesMade = true;
      });
    }
  }

  void _handleBackButton() {
    if (_changesMade) {
      // Show confirmation dialog or handle back navigation logic
    } else {
      Navigator.pop(context);
    }
  }

  Future<void> _saveChanges() async {
    setState(() {
      _saving = true;
    });

    if (_imageFile != null) {
      String fileName = DateTime
          .now()
          .millisecondsSinceEpoch
          .toString();
      final firebase_storage.Reference ref =
      firebase_storage.FirebaseStorage.instance.ref().child(
          'profile_images/$fileName.jpg');
      await ref.putFile(_imageFile!);
      String downloadURL = await ref.getDownloadURL();
      print('Image uploaded. Download URL: $downloadURL');
    }

    // Save the user's name and email wherever appropriate
    String fullName = _nameController.text;
    String email = _emailController.text;
    print('Saving changes for $fullName, Email: $email');

    // Simulate a delay to mimic saving process
    await Future.delayed(Duration(seconds: 2));

    setState(() {
      _changesMade = false;
      _saving = false;
      // Show a confirmation message or update the UI accordingly
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Changes saved successfully!'),
        ),
      );
    });
  }


  void _logout() async {
    bool logoutConfirmed = await showLogoutConfirmationDialog(context);
    if (logoutConfirmed) {
      await FirebaseAuth.instance.signOut();
      Navigator.of(context).popUntil((route) => route.isFirst);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LogIn()),
      );
    }
  }

  Future<bool> showLogoutConfirmationDialog(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Logout'),
          content: Text('Are you sure you want to log out?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: Text('Logout'),
            ),
          ],
        );
      },
    ) ?? false;
  }
}