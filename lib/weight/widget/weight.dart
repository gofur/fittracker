import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fittracker/helper/helper.dart';
import 'package:fittracker/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class WeightList extends StatelessWidget {
  WeightList({Key? key}) : super(key: key);
  final _firebaseAuth = serviceLocator<FirebaseAuthHelper>();
  final _cloudFirestore = serviceLocator<CloudFirestoreHelper>();

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
        child: Scaffold(
      appBar: AppBar(
        title: const Text("Weight List"),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (BuildContext context) {
                        return Weight(isUpdate: false);
                      },
                    ),
                  );
                },
                child: const Text("Add Weight")),
          ),
          StreamBuilder(
            // Reading Items form our Database Using the StreamBuilder widget
            stream: _cloudFirestore.cloudFireStore
                .collection('weights')
                .where('email', isEqualTo: _firebaseAuth.user.email.toString())
                .orderBy('weightDate', descending:true)
                .snapshots(),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              return ListView.builder(
                shrinkWrap: true,
                itemCount: snapshot.data?.docs.length,
                itemBuilder: (context, int index) {
                  DocumentSnapshot documentSnapshot = snapshot.data.docs[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListTile(
                          title: Text(documentSnapshot['weightDate']),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (BuildContext context) {
                                  return Weight(
                                      isUpdate: true,
                                      documentSnapshot: documentSnapshot);
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
                              _cloudFirestore.cloudFireStore
                                  .collection('users')
                                  .doc(documentSnapshot.id)
                                  .delete();
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    ));
  }
}

class Weight extends StatefulWidget {
  bool isUpdate;
  DocumentSnapshot? documentSnapshot;
  Weight({Key? key, required this.isUpdate, this.documentSnapshot})
      : super(key: key);

  @override
  State<Weight> createState() => _WeightState();
}

class _WeightState extends State<Weight> {
  final _firebaseAuth = serviceLocator<FirebaseAuthHelper>();
  final _cloudFirestore = serviceLocator<CloudFirestoreHelper>();
  TextEditingController todayDate = TextEditingController();
  TextEditingController weightController = TextEditingController();
  int? weight;

  @override
  void initState() {
    super.initState();
    if (widget.isUpdate) {
      todayDate.text = widget.documentSnapshot?['weightDate'];
      weight = widget.documentSnapshot?['weight'];
      weightController.text = weight.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
        child: Scaffold(
      appBar: AppBar(
        title: const Text("Weight"),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.9,
                  child: TextField(
                    controller: todayDate,
                    style: const TextStyle(color: Colors.black),
                    readOnly: true,
                    decoration: InputDecoration(
                      icon: const Icon(Icons.calendar_today),
                      border: const OutlineInputBorder(),
                      labelText: widget.isUpdate
                          ? 'Update WeightDate'
                          : 'Add WeightDate',
                      hintText: 'fill the weight date',
                    ),
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(
                              1900), //DateTime.now() - not to allow to choose before today.
                          lastDate: DateTime(2101));

                      if (pickedDate != null) {
                        String formattedDate =
                            DateFormat('yyyy-MM-dd').format(pickedDate);
                        //you can implement different kind of Date Format here according to your requirement

                        setState(() {
                          todayDate.text =
                              formattedDate; //set output date to TextField value.
                        });
                      } else {
                        print("Date is not selected");
                      }
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.9,
                  child: TextField(
                    controller: weightController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      labelText:
                          widget.isUpdate ? 'Update Weight' : 'Add Weight',
                      hintText: 'fill the weight',
                    ),
                    onChanged: (_val) {
                      weight = int.tryParse(_val);
                    },
                  ),
                ),
              ),
              TextButton(
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all(Colors.lightBlueAccent),
                  ),
                  onPressed: () {
                    // Check to see if isUpdate is true then update the value else add the value
                    if (widget.isUpdate) {
                      _cloudFirestore.cloudFireStore
                          .collection('weights')
                          .doc(widget.documentSnapshot?.id)
                          .update({
                        'weightDate': todayDate.text,
                        'weight': weight,
                        'email': _firebaseAuth.user.email.toString()
                      });
                    } else {
                      _cloudFirestore.cloudFireStore.collection('weights').add({
                        'weightDate': todayDate.text,
                        'weight': weight,
                        'email': _firebaseAuth.user.email.toString()
                      });
                    }
                    Navigator.pop(context);
                  },
                  child: widget.isUpdate
                      ? const Text(
                          'UPDATE',
                          style: TextStyle(color: Colors.white),
                        )
                      : const Text('ADD',
                          style: TextStyle(color: Colors.white))),
            ],
          ),
        ),
      ),
    ));
  }
}
