import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:communitrade/views/authentication/login.dart';
import 'package:provider/provider.dart';
import 'HomePage.dart';

class CreatePost extends StatelessWidget {
  final User user;

  const CreatePost({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final firebaseApp = context.read<FirebaseApp>();
    final FirebaseAuth _auth = FirebaseAuth.instance;
    final FirebaseFirestore db = FirebaseFirestore.instance;

    final TextEditingController itemNameController = TextEditingController();
    final TextEditingController returnItemController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: Text('Create New Post'),
        actions: [
          IconButton(
            icon: Icon(Icons.home),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HomePage(user: user),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _auth.signOut(); // Sign out from Firebase
              Navigator.push(
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
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TextField(
              controller: itemNameController,
              decoration: InputDecoration(labelText: 'Item'),
            ),
            TextField(
              controller: returnItemController,
              decoration: InputDecoration(labelText: 'Return Item'),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                String item = itemNameController.text;
                String returnItem = returnItemController.text;
                String postingUser = _auth.currentUser?.displayName ?? "ERROR";

                final post = <String, String>{
                  "Item": item,
                  "ReturnItem": returnItem,
                  "User": postingUser
                };
                db.collection("posts").add(post).then((documentSnapshot) =>
                  print("Added Data with ID: ${documentSnapshot.id}"));
                
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => HomePage(user: user)),
                  );});                
              },             
                
              child: const Text('Submit'),
            ),            
          ],
        ),
      ),
    );
  }
}


// Widget checkboxes(BuildContext context) {
//     return Padding(

//       padding: const EdgeInsets.all(16.0),
//       child: Column(
//         children: [
//           // Row 1
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//             children: [
//               Checkbox(
//                 value: checkboxValues[0],
//                 onChanged: (value) {
//                   setState(() {
//                     checkboxValues[0] = value!;
//                   });
//                 },
//               ),
//               Checkbox(
//                 value: checkboxValues[1],
//                 onChanged: (value) {
//                   setState(() {
//                     checkboxValues[1] = value!;
//                   });
//                 },
//               ),
//               Checkbox(
//                 value: checkboxValues[2],
//                 onChanged: (value) {
//                   setState(() {
//                     checkboxValues[2] = value!;
//                   });
//                 },
//               ),
//               Checkbox(
//                 value: checkboxValues[3],
//                 onChanged: (value) {
//                   setState(() {
//                     checkboxValues[3] = value!;
//                   });
//                 },
//               ),
//             ],
//           ),

//           // Row 2
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//             children: [
//               Checkbox(
//                 value: checkboxValues[4],
//                 onChanged: (value) {
//                   setState(() {
//                     checkboxValues[4] = value!;
//                   });
//                 },
//               ),
//               Checkbox(
//                 value: checkboxValues[5],
//                 onChanged: (value) {
//                   setState(() {
//                     checkboxValues[5] = value!;
//                   });
//                 },
//               ),
//               Checkbox(
//                 value: checkboxValues[6],
//                 onChanged: (value) {
//                   setState(() {
//                     checkboxValues[6] = value!;
//                   });
//                 },
//               ),
//               Checkbox(
//                 value: checkboxValues[7],
//                 onChanged: (value) {
//                   setState(() {
//                     checkboxValues[7] = value!;
//                   });
//                 },
//               ),
//             ],
//           ),
//         ],
//       ),
//     );