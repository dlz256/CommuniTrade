// import 'package:firebase_auth/firebase_auth.dart';
import 'package:communitrade/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'package:flutter/material.dart';
// import '../../firebase_auth.dart';
import 'views/authentication/login.dart';


/*
  to run enter >> flutter run -d chrome --web-renderer html 
*/
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FirebaseApp firebaseApp = await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // runApp(MyApp(firebaseApp: firebaseApp));
  runApp(
    MultiProvider(
      providers: [
        Provider<FirebaseApp>(
          create: (_) => firebaseApp,
        ),
        // Other providers for your app's state or services
      ],
      child: MyApp(firebaseApp: firebaseApp),
    ),
  );
}

class MyApp extends StatelessWidget {
  final FirebaseApp firebaseApp;

  const MyApp({Key? key, required this.firebaseApp}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CommuniTrade',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
       debugShowCheckedModeBanner: false,
      home: LoginView(
        title: 'CommuniTrade Login Page',
        firebaseApp: firebaseApp,
      )
    );
  }
}
