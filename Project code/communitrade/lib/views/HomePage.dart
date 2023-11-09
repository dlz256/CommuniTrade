import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:communitrade/views/authentication/login.dart';
import 'package:communitrade/views/create_post.dart';
import 'package:provider/provider.dart';
// import 'package:http/http.dart' as http;
// import 'dart:typed_data';

class HomePage extends StatelessWidget {
  final User user;

  const HomePage({super.key, required this.user});

  Widget _leftSideTile(BuildContext context, DocumentSnapshot document) {

    return Expanded(
      flex: 2,
      child: Container(
          decoration: BoxDecoration(
            color: const Color(0xffddddff),
            borderRadius: BorderRadius.circular(10.0),
          ),
          padding: const EdgeInsets.all(10.0),
          child: Column(
              mainAxisAlignment:
                  MainAxisAlignment.center, // Center the content vertically
              children: <Widget>[
                Text(
                  document['Item'],
                  style: Theme.of(context).textTheme.labelMedium,
                ),
                const SizedBox(
                    height:
                        10), // Add some spacing between the name and the square
                Center(
                  child: Container(
                      width: 300, // You can adjust the square size as needed
                      height: 200.0,
                      // child: Image.network(
                      //   document['imageUrl'],
                      //   errorBuilder: (context, error, stackTrace) {
                      //     return Text('$error');
                      //   },
                      // )
                      // child: Text(document['imageUrl'])
                     //child: Image(image: AssetImage('assets/images/WhiteTshirt')),

                  ),
                ),
              ])),
    );
  }

  Widget _rightSideTile(BuildContext context, DocumentSnapshot document) {
    return Expanded(
      flex: 2,
      child: Container(
          decoration: BoxDecoration(
            color: Color(0xffddddff),
            borderRadius: BorderRadius.circular(10.0),
          ),
          padding: const EdgeInsets.all(10.0),
          child: Column(
              mainAxisAlignment:
                  MainAxisAlignment.center, // Center the content vertically
              children: <Widget>[
                Text(
                  document['User'],
                  style: Theme.of(context).textTheme.labelSmall,
                ),
                const SizedBox(
                    height:
                        10), // Add some spacing between the name and the square
                Center(
                  child: Container(
                      width: 300.0, // You can adjust the square size as needed
                      height: 200.0,
                      decoration: const BoxDecoration(
                        color: Colors.lightBlueAccent, // Color of the square
                      ),
                      child: Text(
                        document['ReturnItem'],
                        style: Theme.of(context).textTheme.labelMedium,
                      )),
                ),
              ])),
    );
  }

  Widget _buildListItem(BuildContext context, DocumentSnapshot document) {
    return Card(
        elevation: 4, // Add elevation for a shadow effect
        margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: ListTile(
          title: Row(
            children: <Widget>[
              _leftSideTile(context, document),
              _dividorLine(),
              _rightSideTile(context, document),
            ],
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    final firebaseApp = context.read<FirebaseApp>();
    final FirebaseAuth _auth = FirebaseAuth.instance;

    return Scaffold(
        appBar: AppBar(
          title: Text('Dashboard'),
          actions: [
            IconButton(
                icon: Icon(Icons.add),
                onPressed: () async {
                  try {
                    Future.delayed(Duration.zero, () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => CreatePost(user: user)),
                      );
                    });
                  } catch (e) {
                    print('Navigation error: $e');
                  }
                }),
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                await _auth.signOut(); // Sign out from Firebase
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LoginView(
                      title: 'CommuniTrade Login Page',
                      firebaseApp: firebaseApp,
                    ),
                  ),
                );
              },
            ),
            IconButton(
              icon: Icon(Icons.person),
              onPressed: () {
                Navigator.pushNamed(context, '/page2');
              },
            ),
          ],
        ),
        body: Center(
          child: StreamBuilder(
              stream:
                  FirebaseFirestore.instance.collection('posts').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Text('Loading...');
                return ListView.builder(
                  //itemExtent: 100.0,
                  itemCount: snapshot.data?.docs.length,
                  itemBuilder: (context, index) =>
                      _buildListItem(context, snapshot.data!.docs[index]),
                );
              }),
        ));
  }
}

Widget _dividorLine() {
  return const VerticalDivider(
    // Add this to create a vertical line
    color: Colors.black, // Customize the line color
    width: 1.0, // Adjust the width of the line
    thickness: 10.0, // You can also use 'thickness' for width
    indent: 10, // Indent from the left side
    endIndent: 10, // Indent from the right side
  );
}

String? getUserDisplayName() {
  final user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    return user.displayName;
  } else {
    return 'User Display Name Not Available';
  }
}
