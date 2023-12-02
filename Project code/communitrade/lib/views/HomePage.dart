import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:communitrade/views/authentication/login.dart';
import 'package:communitrade/views/create_post.dart';
import 'package:provider/provider.dart';

import 'ProfilePage.dart';

// import 'package:http/http.dart' as http;
// import 'dart:typed_data';
class HomePageView extends StatefulWidget {
  const HomePageView({Key? key, required this.user, required this.filter}) : super(key: key);
  final User user;
  final String filter;

  @override
  State<HomePageView> createState() => HomePage();
}

class HomePage extends State<HomePageView> {
  get user => super.widget.user;
  get Returnfilter => super.widget.filter;

  String selectedItemFilter = 'All'; // Default filter
  late String selectedReturnItemFilter;

  @override
  void initState() {
    super.initState();
    selectedReturnItemFilter = widget.filter; // Set selectedReturnItemFilter in initState
  }
  
  @override
  Widget build(BuildContext context) {
    final firebaseApp = context.read<FirebaseApp>();
    final FirebaseAuth _auth = FirebaseAuth.instance;
    final username = getUserDisplayName() as String;

// Create a StreamController to convert the list to a stream
    final StreamController<List<DocumentSnapshot>> _streamController =
        StreamController<List<DocumentSnapshot>>.broadcast();
    List<DocumentSnapshot> documentList = [];

    _streamController.add(documentList);

    Query<Map<String, dynamic>> baseQuery = FirebaseFirestore.instance
        .collection("posts")
        .orderBy("PostDate", descending: true);

    if (selectedItemFilter != 'All') {
      baseQuery = baseQuery.where("tags", arrayContains: selectedItemFilter);
    } else if (selectedReturnItemFilter != 'All') {
      baseQuery = baseQuery.where("returnTags",
          arrayContains: selectedReturnItemFilter);
    }

    baseQuery.get().then(
      (querySnapshot) {
        print("Successfully completed");
        documentList = querySnapshot.docs;
        _streamController
            .add(documentList); // Update the stream with the new list
      },
      onError: (e) => print("Error completing: $e"),
    );
    return Scaffold(
        appBar: AppBar(
          title: const Text('Dashboard'),
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
              icon: const Icon(Icons.person),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ProfilePage(user: username)),
                );
              },
            ),
          ],
        ),
        body: Column(children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(width: 20), // Add some spacing between the items
              Row(
                children: [
                  const Text('Filter Items:'),
                  const SizedBox(
                      width: 10), // Add some spacing between the items
                  _filterItemOptions(),
                ],
              ),
              Row(
                children: [
                  const Text('Filter Return Items:'),
                  const SizedBox(
                      width: 10), // Add some spacing between the items
                  _filterReturnItemOptions(),
                ],
              ),
              const SizedBox(width: 20), // Add some spacing between the items
            ],
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
              _dividorLine(),
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
                    const Text("Tags: "),
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
    String user = document['User'];
    return Flexible(
      flex: 2,
      child: Container(
        padding: const EdgeInsets.all(10.0),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              GestureDetector(
                onTap: () {
                  // Navigate to the profile page using your preferred navigation method
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ProfilePage(
                              user: user,
                            )),
                  );
                },
                child: Align(
                  alignment: FractionalOffset.topCenter,
                  child: Text(
                    document['User'],
                    style: Theme.of(context).textTheme.titleSmall!.copyWith(
                          decoration: TextDecoration.underline,
                        ),
                  ),
                ),
              ),

              const SizedBox(
                  height:
                      10), // Add some spacing between the name and the square
              Container(
                decoration: const BoxDecoration(
                    color: Color.fromARGB(
                        255, 231, 243, 243), // Color of the square
                    borderRadius: BorderRadius.all(Radius.circular(15))),
                child: Column(children: [
                  Text("Requested Return Item",
                      style: Theme.of(context).textTheme.headlineSmall),
                  SizedBox(
                    height: 20,
                  ),
                  Align(
                      alignment: FractionalOffset.centerLeft,
                      child: Container(
                        // width: 300.0, // You can adjust the square size as needed
                        // height: 155.0,
                        child: Text(
                          document['ReturnItem'],
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                      )),
                  const SizedBox(height: 120),
                ]),
              ),
              Align(
                alignment: FractionalOffset.bottomLeft,
                child: Row(
                  //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text("Tags: "),
                    Expanded(
                      child: Text(
                        generateCommaSeparatedString(itemTagsList),
                        style: const TextStyle(
                            fontSize: 14), // Adjust the font size as needed
                      ),
                    ),
                  ],
                ),
              ),
            ]),
      ),
    );
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

  Widget _filterItemOptions() {
    return Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: DropdownButton<String>(
          value: selectedItemFilter,
          onChanged: (String? newValue) {
            setState(() {
              selectedItemFilter = newValue!;
            });
          },
          items: [
            'All',
            'Clothes',
            'Fitness',
            'Hardware',
            'Electronics',
            'Household',
            'Supplies',
            'Free',
            'Other'
          ].map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
      ),
    ]);
  }

  Widget _filterReturnItemOptions() {
    return Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: DropdownButton<String>(
          value: selectedReturnItemFilter,
          onChanged: (String? newValue) {
            setState(() {
              selectedReturnItemFilter = newValue!;
            });
          },
          items: [
            'All',
            'Clothes',
            'Fitness',
            'Hardware',
            'Electronics',
            'Household',
            'Supplies',
            'Free',
            'Other'
          ].map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
      ),
    ]);
  }
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
