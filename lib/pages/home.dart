import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../services/auth.dart';
import 'profile.dart';

class Home extends StatefulWidget {
  final currentUser = FirebaseAuth.instance;

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final AuthMethods _authMethods = AuthMethods();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? userName;
  String? userEmail;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("We Chat"),
        actions: [
          IconButton(onPressed: () {}, icon: Icon(Icons.search)),
          IconButton(onPressed: () {}, icon: Icon(Icons.more_vert)),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: UserAccountsDrawerHeader(
                decoration: BoxDecoration(color: Colors.grey),
                accountEmail: userEmail != null ? Text(userEmail!) : null,
                accountName: userName != null ? Text(userName!) : null,
                currentAccountPictureSize: Size.square(50),
                currentAccountPicture: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Text(
                    userName != null && userName!.isNotEmpty
                        ? (userName!.toUpperCase().substring(0, 1))
                        : "",
                  ),
                ),
              ),
            ),
            ListTile(
              title: Text('Logout'),
              onTap: () async {
                await _authMethods.signOut(context);
              },
            ),
          ],
        ),
      ),
      body: Container(), // Placeholder body content
    );
  }

  @override
  void initState() {
    super.initState();
    getUserData();
  }

  void getUserData() async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection("users")
          .doc(_auth.currentUser!.uid)
          .get();

      if (userDoc.exists) {
        setState(() {
          userName = userDoc.get('name');
          userEmail = userDoc.get('email');
        });
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }
}
