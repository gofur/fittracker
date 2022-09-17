import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fittracker/auth/widget/login.dart';
import 'package:fittracker/helper/helper.dart';
import 'package:fittracker/service_locator.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _firebaseAuth = serviceLocator<FirebaseAuthHelper>();

  final _cloudFirestore = serviceLocator<CloudFirestoreHelper>();

  String? name;
  String? gender;
  String? birthdate;
  int? height;

  final List<String> genderList = <String>[
    "Male",
    "Female"
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Welcome  ${_firebaseAuth.user.email.toString()},"),
              ElevatedButton(
                      onPressed: () {
                        showModalBottomSheet(
                        context: context,
                        builder: (context) {
                          return showBottomSheet(context, false, null, gender);
                        });
                        },
                      child: const Text("Add Profile")),

              // StreamBuilder(
              //   // Reading Items form our Database Using the StreamBuilder widget
              //   stream: _cloudFirestore.cloudFireStore.collection('users').snapshots(),
              //   builder: (BuildContext context, AsyncSnapshot snapshot) {
              //
              //     if(snapshot.connectionState == ConnectionState.waiting){
              //       return const Center(
              //         child: CircularProgressIndicator(),
              //       );
              //     }
              //
              //     if (!snapshot.hasData || snapshot.data?.docs.length <= 0) {
              //       return Center(
              //         child: ElevatedButton(
              //             onPressed: () {
              //               showModalBottomSheet(
              //               context: context,
              //               builder: (context) {
              //                 return showBottomSheet(context, false, null);
              //               });
              //               },
              //             child: Text("Setting")),
              //       );
              //     }
              //     return ListView.builder(
              //       itemCount: snapshot.data?.docs.length,
              //       itemBuilder: (context, int index) {
              //         DocumentSnapshot documentSnapshot = snapshot.data.docs[index];
              //         return ListTile(
              //           title: Text(documentSnapshot['todo']),
              //           onTap: () {
              //             // Here We Will Add The Update Feature and passed the value 'true' to the is update
              //             // feature.
              //             showModalBottomSheet(
              //               context: context,
              //               builder: (BuildContext context) {
              //                 return showBottomSheet(context, true, documentSnapshot);
              //               },
              //             );
              //           },
              //           trailing: IconButton(
              //             icon: const Icon(
              //               Icons.delete_outline,
              //             ),
              //             onPressed: () {
              //               // Here We Will Add The Delete Feature
              //               _cloudFirestore.cloudFireStore.collection('todos').doc(documentSnapshot.id).delete();
              //             },
              //           ),
              //         );
              //       },
              //     );
              //   },
              // ),
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

  showBottomSheet(
      BuildContext context, bool isUpdate, DocumentSnapshot? documentSnapshot, String? gender) {
    // Added the isUpdate argument to check if our item has been updated
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Column(
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.9,
            child: TextField(
              style: const TextStyle(color: Colors.black),
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: isUpdate ? 'Update Name' : 'Add Name',
                hintText: 'fill the name',
              ),
              onChanged: (String _val) {
                // Storing the value of the text entered in the variable value.
                name = _val;
              },
            ),
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.9,
            child: DropdownButton(
              value: (gender == 'Male' || gender == 'Female') ? gender : null,
              onChanged: (String? _val) {
                setState(() {
                  gender = _val;
                });

              },
              items: genderList.map(
                    (item) {
                  return DropdownMenuItem(
                    value: item,
                    child: Text(item),
                  );
                },
              ).toList(),
            ),
          ),
          TextButton(
              style: ButtonStyle(
                backgroundColor:
                MaterialStateProperty.all(Colors.lightBlueAccent),
              ),
              onPressed: () {
                // Check to see if isUpdate is true then update the value else add the value
                if (isUpdate) {
                  _cloudFirestore.cloudFireStore.collection('users').doc(documentSnapshot?.id).update({
                    'name': name,
                  });
                } else {
                  _cloudFirestore.cloudFireStore.collection('users').add({'name': name});
                }
                Navigator.pop(context);
              },
              child: isUpdate
                  ? const Text(
                'UPDATE',
                style: TextStyle(color: Colors.white),
              )
                  : const Text('ADD', style: TextStyle(color: Colors.white))),
        ],
      ),
    );
  }
}



