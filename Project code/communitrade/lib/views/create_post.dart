import 'dart:async';
// import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
// import 'package:path_provider/path_provider.dart';

import 'package:communitrade/views/authentication/login.dart';
import 'HomePage.dart';

class CreatePost extends StatefulWidget {
  final User user;
  const CreatePost({super.key, required this.user});

  @override
  State<CreatePost> createState() => CreatePostState();
}

class CreatePostState extends State<CreatePost> {
  CreatePostState();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore db = FirebaseFirestore.instance;
  final FirebaseStorage storage = FirebaseStorage.instance;

  String imageUrl = '';

  final TextEditingController itemNameController = TextEditingController();
  final TextEditingController returnItemController = TextEditingController();
  List<String> selectedTags = [];

  bool MensClothesChecked = false;
  bool WomensClothesChecked = false;
  bool KidsClothesChecked = false;
  bool HardwareChecked = false;

  @override
  Widget build(BuildContext context) {
    final firebaseApp = context.read<FirebaseApp>();
    final User user = _auth.currentUser as User;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Post'),
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
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
            const SizedBox(
              height: 20,
            ),
            MaterialButton(
                color: Colors.blue,
                child: const Text("Upload an Image",
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16)),
                onPressed: () async {
                  PickImageFromGallery();
                }),
            Wrap(
              spacing: 10.0, // Horizontal spacing between elements
              runSpacing: (MediaQuery.of(context).size.width < 4 * 200) ? 10.0 : 0.0, // 200 is the width of each element
              alignment: WrapAlignment.start, // Adjust alignment as needed
  
              children: [
                Checkbox(
                    value: MensClothesChecked,
                    onChanged: (value) {
                      setState(() {
                        MensClothesChecked = value!;
                        if (MensClothesChecked)
                          selectedTags.add("Mclothes");
                        else if (!MensClothesChecked) selectedTags.remove("Mclothes");
                      });
                    }),
                const Text('Mens Clothes'),
                Checkbox(
                    value: WomensClothesChecked,
                    onChanged: (value) {
                      setState(() {
                        WomensClothesChecked = value!;
                        if (WomensClothesChecked)
                          selectedTags.add("Wclothes");
                        else if (!WomensClothesChecked) selectedTags.remove("Wclothes");
                      });
                    }),
                const Text('Womens Clothes'),
                Checkbox(
                    value: KidsClothesChecked,
                    onChanged: (value) {
                      setState(() {
                        KidsClothesChecked = value!;
                        if (KidsClothesChecked)
                          selectedTags.add("Kclothes");
                        else if (!KidsClothesChecked) selectedTags.remove("Kclothes");
                      });
                    }),
                const Text('Kids Clothes'),
                Checkbox(
                    value: HardwareChecked,
                    onChanged: (value) {
                      setState(() {
                        HardwareChecked = value!;
                        if (HardwareChecked)
                          selectedTags.add("Hequip");
                        else if (!HardwareChecked) selectedTags.remove("Hequip");
                      });
                    }),
                const Text('Hardware equipment'),
              ],
            ),
            Text('Selected Tags: ${selectedTags.join(', ')}'),
            const SizedBox(
              height: 20,
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
                if (imageUrl.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Please upload an image')));
                  return;
                }
                final post = <String, String>{
                  "Item": item,
                  "ReturnItem": returnItem,
                  "User": postingUser,
                  'imageUrl': imageUrl
                };
                db.collection("posts").add(post).then((documentSnapshot) =>
                    print("Added Data with ID: ${documentSnapshot.id}"));

                WidgetsBinding.instance.addPostFrameCallback((_) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => HomePage(user: user)),
                  );
                });
              },
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }

  Future PickImageFromGallery() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );

    if (result == null || result.files.isEmpty) return;

    PlatformFile file = result.files.first;
    String uniqueFileName = DateTime.now().millisecondsSinceEpoch.toString();

    Reference referenceRoot = FirebaseStorage.instance.ref();
    Reference referenceDirImages = referenceRoot.child('Images');

    Reference referenceImageToUpload = referenceDirImages.child(uniqueFileName);

    try {
      Uint8List imageData = await file.bytes!;
      final metadata = SettableMetadata(contentType: 'image/jpeg');
      await referenceImageToUpload.putData(imageData, metadata);

      imageUrl = await referenceImageToUpload.getDownloadURL();
    } catch (error) {
      print("Error: $error");
    }
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
