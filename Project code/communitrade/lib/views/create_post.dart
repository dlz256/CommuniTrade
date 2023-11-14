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
  List<String> selectedReturnTags = [];

  bool clothesChecked = false;
  bool fitnessChecked = false;
  bool houseChecked = false;
  bool hardwareChecked = false;
  bool electricalChecked = false;
  bool suppliesChecked = false;
  bool freeChecked = false;
  bool otherChecked = false; 
  bool returnclothesChecked = false;
  bool returnfitnessChecked = false;
  bool returnhouseChecked = false;
  bool returnhardwareChecked = false;
  bool returnelectricalChecked = false;
  bool returnsuppliesChecked = false;
  bool returnfreeChecked = false;
  bool returnotherChecked = false;

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
                  builder: (context) => HomePageView(user: user),
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
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.pushNamed(context, '/page2');
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TextField(
              controller: itemNameController,
              decoration: const InputDecoration(labelText: 'Item'),
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
                if (imageUrl != '') Image.network(
                        imageUrl,
                        errorBuilder: (context, error, stackTrace) {
                          return Text('$error');
                        }
                      ),
            Row(
              children: [
                Expanded(
                    child: Column(
                  children: [
                    Row(children: <Widget>[
                      Checkbox(
                          value: clothesChecked,
                          onChanged: (value) {
                            setState(() {
                              clothesChecked = value!;
                              if (clothesChecked) {
                                selectedTags.add("Clothes");
                              } else if (!clothesChecked)
                                selectedTags.remove("Clothes");
                            });
                          }),
                      const Text('Clothes')
                    ]),
                    Row(children: [Checkbox(
                        value: fitnessChecked,
                        onChanged: (value) {
                          setState(() {
                            fitnessChecked = value!;
                            if (fitnessChecked)
                              selectedTags.add("Fitness");
                            else if (!fitnessChecked)
                              selectedTags.remove("Fitness");
                          });
                        }),
                    const Text('Fitness Equipment'),],) ,
                    Row(children: [Checkbox(
                        value: hardwareChecked,
                        onChanged: (value) {
                          setState(() {
                            hardwareChecked = value!;
                            if (hardwareChecked)
                              selectedTags.add("Hardware");
                            else if (!hardwareChecked)
                              selectedTags.remove("Hardware");
                          });
                        }),
                    const Text('Hardware equipment'),],) ,
                   Row(children: [Checkbox(
                        value: freeChecked,
                        onChanged: (value) {
                          setState(() {
                            freeChecked = value!;
                            if (freeChecked)
                              selectedTags.add("Free");
                            else if (!freeChecked) selectedTags.remove("Free");
                          });
                        }),
                    const Text('Free'),],) 
                  ],
                )),
                Expanded(
                    child: Column(
                  children: [
                   Row(children: [Checkbox(
                        value: electricalChecked,
                        onChanged: (value) {
                          setState(() {
                            electricalChecked = value!;
                            if (electricalChecked)
                              selectedTags.add("Electronics");
                            else if (!electricalChecked)
                              selectedTags.remove("Electronics");
                          });
                        }),
                    const Text('Electrical Equipment'),],) ,
                   Row(children: [Checkbox(
                        value: houseChecked,
                        onChanged: (value) {
                          setState(() {
                            houseChecked = value!;
                            if (houseChecked)
                              selectedTags.add("Household");
                            else if (!houseChecked)
                              selectedTags.remove("Household");
                          });
                        }),
                    const Text('Household Items'),],) ,
                   Row(children: [Checkbox(
                        value: suppliesChecked,
                        onChanged: (value) {
                          setState(() {
                            suppliesChecked = value!;
                            if (suppliesChecked)
                              selectedTags.add("Supplies");
                            else if (!suppliesChecked)
                              selectedTags.remove("Supplies");
                          });
                        }),
                    const Text('Supplies'),],) ,
                  Row(children: [Checkbox(
                        value: otherChecked,
                        onChanged: (value) {
                          setState(() {
                            otherChecked = value!;
                            if (otherChecked)
                              selectedTags.add("Other");
                            else if (!otherChecked)
                              selectedTags.remove("Other");
                          });
                        }),
                    const Text('Other'),],) ,
                  ],
                ))
              ],
            ),
            //ext('Selected Tags: ${selectedTags.join(', ')}'),
            const SizedBox(
              height: 20,
            ),
            TextField(
              controller: returnItemController,
              decoration: const InputDecoration(labelText: 'Return Item'),
            ),
            const SizedBox(height: 16.0),
            Row(
              children: [
                Expanded(
                    child: Column(
                  children: [
                    Row(children: <Widget>[
                      Checkbox(
                          value: returnclothesChecked,
                          onChanged: (value) {
                            setState(() {
                              returnclothesChecked = value!;
                              if (returnclothesChecked) {
                                selectedReturnTags.add("Clothes");
                              } else if (!returnclothesChecked)
                                selectedReturnTags.remove("Clothes");
                            });
                          }),
                      const Text('Clothes')
                    ]),
                    Row(children: [Checkbox(
                        value: returnfitnessChecked,
                        onChanged: (value) {
                          setState(() {
                            returnfitnessChecked = value!;
                            if (returnfitnessChecked)
                              selectedReturnTags.add("Fitness");
                            else if (!returnfitnessChecked)
                              selectedReturnTags.remove("Fitness");
                          });
                        }),
                    const Text('Fitness Equipment'),],) ,
                    Row(children: [Checkbox(
                        value: returnhardwareChecked,
                        onChanged: (value) {
                          setState(() {
                            returnhardwareChecked = value!;
                            if (returnhardwareChecked)
                              selectedReturnTags.add("Hardware");
                            else if (!returnhardwareChecked)
                              selectedReturnTags.remove("Hardware");
                          });
                        }),
                    const Text('Hardware equipment'),],) ,
                   Row(children: [Checkbox(
                        value: returnfreeChecked,
                        onChanged: (value) {
                          setState(() {
                            returnfreeChecked = value!;
                            if (returnfreeChecked)
                              selectedReturnTags.add("Free");
                            else if (!returnfreeChecked) selectedReturnTags.remove("Free");
                          });
                        }),
                    const Text('Free'),],) 
                  ],
                )),
                Expanded(
                    child: Column(
                  children: [
                   Row(children: [Checkbox(
                        value: returnelectricalChecked,
                        onChanged: (value) {
                          setState(() {
                            returnelectricalChecked = value!;
                            if (returnelectricalChecked)
                              selectedReturnTags.add("Electronics");
                            else if (!returnelectricalChecked)
                              selectedReturnTags.remove("Electronics");
                          });
                        }),
                    const Text('Electronics'),],) ,
                   Row(children: [Checkbox(
                        value: returnhouseChecked,
                        onChanged: (value) {
                          setState(() {
                            returnhouseChecked = value!;
                            if (returnhouseChecked)
                              selectedReturnTags.add("Household");
                            else if (!houseChecked)
                              selectedReturnTags.remove("Household");
                          });
                        }),
                    const Text('Household Items'),],) ,
                   Row(children: [Checkbox(
                        value: returnsuppliesChecked,
                        onChanged: (value) {
                          setState(() {
                            returnsuppliesChecked = value!;
                            if (returnsuppliesChecked)
                              selectedReturnTags.add("Supplies");
                            else if (!returnsuppliesChecked)
                              selectedReturnTags.remove("Supplies");
                          });
                        }),
                    const Text('Supplies'),],) ,
                  Row(children: [Checkbox(
                        value: returnotherChecked,
                        onChanged: (value) {
                          setState(() {
                            returnotherChecked = value!;
                            if (returnotherChecked)
                              selectedReturnTags.add("Other");
                            else if (!otherChecked)
                              selectedReturnTags.remove("Other");
                          });
                        }),
                    const Text('Other'),],) ,
                  ],
                ))
              ],
            ),
            //Text('Selected Tags: ${selectedReturnTags.join(', ')}'),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                String item = itemNameController.text;
                String returnItem = returnItemController.text;
                String postingUser = _auth.currentUser?.displayName ?? "ERROR";
                if (imageUrl.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please upload an image')));
                  return;
                }
                final post = {
                  "Item": item,
                  "ReturnItem": returnItem,
                  "User": postingUser,
                  "imageUrl": imageUrl,
                  "tags": selectedTags,
                  "returnTags": selectedReturnTags,
                  "PostDate": Timestamp.now(),
                };
                db.collection("posts").add(post).then((documentSnapshot) =>
                    //print("Added Data with ID: ${documentSnapshot.id}"),
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => HomePageView(user: user)),
                  );
                })
                );
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
