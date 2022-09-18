import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fittracker/auth/widget/login.dart';
import 'package:fittracker/auth/widget/profile.dart';
import 'package:fittracker/helper/helper.dart';
import 'package:fittracker/service_locator.dart';
import 'package:fittracker/weight/widget/weight.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _firebaseAuth = serviceLocator<FirebaseAuthHelper>();
  final _cloudFirestore = serviceLocator<CloudFirestoreHelper>();


  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text("Welcome  ${_firebaseAuth.user.email.toString()},"),
              SizedBox(
                child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (BuildContext context) {
                            return WeightList();
                          },
                        ),
                      );
                    },
                    child: const Text("List Weight")),
              ),
              StreamBuilder(
                // Reading Items form our Database Using the StreamBuilder widget
                stream: _cloudFirestore.cloudFireStore.collection('users').where('email', isEqualTo: _firebaseAuth.user.email.toString()).snapshots(),
                builder: (BuildContext context, AsyncSnapshot snapshot) {

                  if(snapshot.connectionState == ConnectionState.waiting){
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data?.docs.length <= 0) {
                    return  SizedBox(
                      child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (BuildContext context) {
                                  return Profile(isUpdate: false);
                                },
                              ),
                            );
                          },
                          child: const Text("Add Profile")),
                    );
                  }
                  return Expanded(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: snapshot.data?.docs.length,
                      itemBuilder: (context, int index) {
                        DocumentSnapshot documentSnapshot = snapshot.data.docs[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Data Profile"),
                              ListTile(
                                title: Text(documentSnapshot['name']),
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (BuildContext context) {
                                        return Profile(isUpdate: true, documentSnapshot: documentSnapshot);
                                      },
                                    ),
                                  );
                                },
                                trailing: IconButton(
                                  icon: const Icon(
                                    Icons.delete_outline,
                                  ),
                                  onPressed: () {
                                    // Here We Will Add The Delete Feature
                                    _cloudFirestore.cloudFireStore.collection('users').doc(documentSnapshot.id).delete();
                                  },
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _firebaseAuth
              .signOut()
              .then((_) => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const Login()),
          ));
        },
        child: const Icon(Icons.logout),
        tooltip: 'Logout',
      ),
    );
  }

}

