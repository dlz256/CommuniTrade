import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:communitrade/views/authentication/login.dart';
import 'package:communitrade/views/create_post.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key, required this.user});
  final String user;

  @override
  State<ProfilePage> createState() => ProfilePageState();
}

class ProfilePageState extends State<ProfilePage> {
  get user => super.widget.user;

  String selectedItemFilter = 'All'; // Default filter
  String selectedReturnItemFilter = 'All'; // Default filter
  int score = 0;

  @override
  Widget build(BuildContext context) {
    final firebaseApp = context.read<FirebaseApp>();
    final FirebaseAuth _auth = FirebaseAuth.instance;

    // Create a StreamController to convert the list of posts to a stream
    final StreamController<List<DocumentSnapshot>> _streamController =
        StreamController<List<DocumentSnapshot>>.broadcast();
    List<DocumentSnapshot> documentList = [];
    _streamController.add(documentList);
    Query<Map<String, dynamic>> baseQuery = FirebaseFirestore.instance
        .collection("posts")
        .orderBy("PostDate", descending: true)
        .where("User", isEqualTo: user);
    baseQuery.get().then(
      (querySnapshot) {
        documentList = querySnapshot.docs;
        _streamController
            .add(documentList); // Update the stream with the new list
      },
    );

    void fetchScore() async {
      final weightedScore = await getScores(user);
      setState(() {
        score = weightedScore;
      });
    }

    fetchScore();

    return Scaffold(
        appBar: AppBar(
          title: const Text('Profile'),
          actions: [
            IconButton(
                icon: const Icon(Icons.add),
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
                _auth.signOut(); // Sign out from Firebase
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
          ],
        ),
        body: Column(children: [
          const SizedBox(
            height: 20,
          ),
          Text(
            user,
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          const SizedBox(
            height: 60,
          ),
          Text('Environmental Impact Score: $score'),
          RawMaterialButton(
            onPressed: () {
              _showPopup(context); // Show the popup when the button is pressed
            },
            elevation: 2.0,
            fillColor: Colors.blue, // Change the color as needed
            padding: const EdgeInsets.all(2.0),
            shape: const CircleBorder(),
            child: const Icon(
              Icons.help_outline,
              color: Colors.white,
              size: 20.0,
            ),
          ),
          Expanded(
            child: StreamBuilder(
                stream: _streamController.stream,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const Text('Loading...');
                  List<DocumentSnapshot> data =
                      snapshot.data as List<DocumentSnapshot>;
                  return ListView.builder(
                    itemCount: data.length,
                    itemBuilder: (context, index) =>
                        _buildListItem(context, data[index]),
                  );
                }),
          )
        ]));
  }

  Widget _buildListItem(BuildContext context, DocumentSnapshot document) {
    return Card(
        elevation: 4, // Add elevation for a shadow effect
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: ListTile(
          title: Row(
            children: <Widget>[
              _leftSideTile(context, document),
              _rightSideTile(context, document),
            ],
          ),
        ));
  }

  Widget _leftSideTile(BuildContext context, DocumentSnapshot document) {
    List<dynamic> itemTagsList = document['tags'];
    return Flexible(
      flex: 2,
      child: Container(
          padding: const EdgeInsets.all(10.0),
          child: Column(
              mainAxisAlignment:
                  MainAxisAlignment.center, // Center the content vertically
              children: <Widget>[
                Text(
                  document['Item'],
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(
                    height:
                        10), // Add some spacing between the name and the square
                Center(
                  child: Container(
                      // width: 300, // You can adjust the square size as needed
                      // height: 200.0,
                      child: Image.network(
                    document['imageUrl'],
                    width: 200,
                    height: 200,
                    fit: BoxFit.cover, // Adjust the fit based on your needs

                    errorBuilder: (context, error, stackTrace) {
                      return Text('$error');
                    },
                  )),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text("Tags:"),
                    Expanded(
                      child: Text(
                        generateCommaSeparatedString(itemTagsList),
                        style: const TextStyle(
                            fontSize: 14), // Adjust the font size as needed
                      ),
                    ),
                  ],
                )
              ])),
    );
  }

  Widget _rightSideTile(BuildContext context, DocumentSnapshot document) {
    List<dynamic> itemTagsList = document['returnTags'];
    final currentUser = getUserDisplayName();
    return Flexible(
      flex: 2,
      child: Container(
        padding: const EdgeInsets.all(10.0),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Align(
                alignment: FractionalOffset.topCenter,
                child: Text(
                  document['User'],
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),

              const SizedBox(
                  height:
                      10), // Add some spacing between the name and the square
              Container(
                decoration: const BoxDecoration(
                  color:Color.fromARGB(255, 231, 243, 243), // Color of the square
                  borderRadius: BorderRadius.all(Radius.circular(15))
                ),
                child: Column(children: [
                  Text("Requested Return Item",
                   style: Theme.of(context).textTheme.headlineSmall),
                   SizedBox(height: 20,),
                  Align(
                      alignment: FractionalOffset.centerLeft,
                      child: Container(
                        // width: 300.0, // You can adjust the square size as needed
                        // height: 155.0,
                        child: Text(
                          document['ReturnItem'],
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      )),
                  const SizedBox(height: 120
                  ),
                ]),
              ),
              Align(
                alignment: FractionalOffset.bottomLeft,
                child: Row(
                    //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text("Tags:"),
                      Expanded(
                        child: Text(
                          generateCommaSeparatedString(itemTagsList),
                          style: const TextStyle(
                              fontSize: 14), // Adjust the font size as needed
                        ),
                      ),
                      if (user == currentUser)
                        IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () async {
                              try {
                                await FirebaseFirestore.instance
                                    .collection('posts') // Replace with your collection name
                                    .doc(document.id) // Replace with the ID of the document to delete
                                    .delete();
                              } catch (e) {
                                print('Error removing post: $e');
                              }
                            }),
                    ]),
              ),
            ]),
      ),
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

// Function to generate a comma-separated string
  String generateCommaSeparatedString(List<dynamic> itemList) {
    if (itemList.isEmpty) {
      return "No tags"; // Display a message if the list is empty
    }

    // Use List.generate to create a comma-separated string
    String result = itemList.first;
    List.generate(itemList.length - 1, (index) {
      result += ", ${itemList[index + 1]}";
    });

    return result;
  }

  void _showPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Score Metrics'),
          content: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Clothes: 5'),
              Text('Hardware: 8'),
              Text('Electronics: 8'),
              Text('Household: 5'),
              Text('Fitness: 6'),
              Text('Supplies: 6'),
              Text('Free: 2'),
              Text('Other: 1'),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the popup
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Future<int> getScores(username) async {
    int clothesScore = await getItemScore(username, "Clothes");
    int electricalScore = await getItemScore(username, "Electronics");
    int fitnessScore = await getItemScore(username, "Fitness");
    int houseHoldScore = await getItemScore(username, "Household");
    int hardwareScore = await getItemScore(username, "Hardware");
    int suppliesScore = await getItemScore(username, "Supplies");
    int freeScore = await getItemScore(username, "Free");
    int otherScore = await getItemScore(username, "Other");
    return clothesScore * 5 +
        electricalScore * 8 +
        fitnessScore * 2 +
        houseHoldScore * 5 +
        hardwareScore * 8 +
        suppliesScore * 6 +
        freeScore * 2 +
        otherScore;
  }

  Future<int> getItemScore(username, tag) async {
    int itemCount = 0;
    try {
      var querySnapshot = await FirebaseFirestore.instance
          .collection("posts")
          .where("User", isEqualTo: username)
          .get();

      querySnapshot.docs.forEach((doc) {
        List<dynamic> tags = doc.get("tags");
        if (tags.contains(tag)) {
          itemCount++;
        }
      });
    } catch (e) {
      print("Error: $e");
    }

    return itemCount;
  }
}
