import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fittracker/helper/helper.dart';
import 'package:fittracker/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Profile extends StatefulWidget {
  bool isUpdate;
  DocumentSnapshot? documentSnapshot;
  Profile({Key? key, required this.isUpdate, this.documentSnapshot}) : super(key: key);

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final _firebaseAuth = serviceLocator<FirebaseAuthHelper>();
  final _cloudFirestore = serviceLocator<CloudFirestoreHelper>();
  TextEditingController birthdate = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController heightController = TextEditingController();


  String? name;
  String? gender;
  int? height;

  final List<String> genderList = <String>[
    "Male",
    "Female"
  ];

  @override
  void initState() {
    super.initState();
    if(widget.isUpdate){
      nameController.text = widget.documentSnapshot?['name'];
      birthdate.text = widget.documentSnapshot?['birthdate'];
      height = widget.documentSnapshot?['height'];
      heightController.text = height.toString();
      gender = widget.documentSnapshot?['gender'];
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(child: Scaffold(
      appBar: AppBar(title: const Text("Profile"),),
      body: SafeArea(child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                child: TextField(
                  controller: nameController,
                  style: const TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    labelText: widget.isUpdate ? 'Update Name' : 'Add Name',
                    hintText: 'fill the name',
                  ),
                  onChanged: (String _val) {
                    // Storing the value of the text entered in the variable value.
                    name = _val;
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                child: DropdownButtonFormField(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
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
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                child: TextField(
                  controller: birthdate,
                  style: const TextStyle(color: Colors.black),
                  readOnly: true,
                  decoration: InputDecoration(
                    icon: const Icon(Icons.calendar_today),
                    border: const OutlineInputBorder(),
                    labelText: widget.isUpdate ? 'Update Birthdate' : 'Add Birthdate',
                    hintText: 'fill the birthdate',
                  ),
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                        context: context, initialDate: DateTime.now(),
                        firstDate: DateTime(1900), //DateTime.now() - not to allow to choose before today.
                        lastDate: DateTime(2101)
                    );

                    if(pickedDate != null ){
                      String formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
                      //you can implement different kind of Date Format here according to your requirement

                      setState(() {
                        birthdate.text = formattedDate; //set output date to TextField value.
                      });
                    }else{
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
                  controller: heightController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    labelText: widget.isUpdate ? 'Update Height' : 'Add Height',
                    hintText: 'fill the height',
                  ),
                  onChanged: (_val) {
                    height =  int.tryParse(_val);
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
                    _cloudFirestore.cloudFireStore.collection('users').doc(widget.documentSnapshot?.id).update({
                      'name': name, 'gender': gender, 'birthdate': birthdate.text, 'height': height,'email': _firebaseAuth.user.email.toString()
                    });
                  } else {
                    _cloudFirestore.cloudFireStore.collection('users').add({'name': name, 'gender': gender, 'birthdate': birthdate.text, 'height': height, 'email': _firebaseAuth.user.email.toString()});
                  }
                  Navigator.pop(context);
                },
                child: widget.isUpdate
                    ? const Text(
                  'UPDATE',
                  style: TextStyle(color: Colors.white),
                )
                    : const Text('ADD', style: TextStyle(color: Colors.white))),
          ],
        ),
      ),),
    ));
  }
}
