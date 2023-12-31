import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:splitshare/Screens/Home/home_appbar.dart';
import 'package:splitshare/Screens/My%20Trips/my_trips.dart';
import 'package:splitshare/Widgets/bottom_nav_bar.dart';

class InfoPage extends StatefulWidget {
  const InfoPage({super.key});

  @override
  State<InfoPage> createState() => _InfoPageState();
}

class _InfoPageState extends State<InfoPage> {
  bool connection = false;
  bool _isLoading = false;

  String tripCreator = '';
  String tripDate = '';
  String tripName = '';
  String tripCode = '';
  List<String> userIDs = [];
  List<String> userNames = [];
  List<String> providerIDs = [];

  String versionName = '';

  @override
  void initState() {
    _isLoading = true;
    checkConnection();
    loadInfo();
    super.initState();
  }

  Future<void> checkConnection() async {
    bool hasConnection = await InternetConnectionChecker().hasConnection;
    if (hasConnection != connection) {
      // The connection status has changed.
      setState(() {
        connection = hasConnection;
      });
    }
  }

  void loadInfo() async {
    final prefs = await SharedPreferences.getInstance();

    tripCreator = prefs.getString('tripCreator')!;
    tripDate = prefs.getString('tripDate')!;
    tripName = prefs.getString('tripName')!;
    tripCode = prefs.getString('tripCode')!;
    userIDs = prefs.getStringList('userIDs')!;
    userNames = prefs.getStringList('userNames')!;

    providerIDs = prefs.getStringList('providerIDs')!;

    parseTimestampString(tripDate);

    setState(() {
      _isLoading = false;
    });
  }

  void parseTimestampString(String timestampString) {
    int seconds =
        int.parse(timestampString.split('seconds=')[1].split(',').first.trim());
    int nanoseconds = int.parse(
        timestampString.split('nanoseconds=')[1].split(')').first.trim());

    DateTime tempDateTime = DateTime.fromMillisecondsSinceEpoch(
      seconds * 1000 + nanoseconds ~/ 1000000,
    );
    tripDate =
        DateFormat('hh:mm a EE, dd MMM, yyyy').format(tempDateTime).toString();
  }

  void _generateQR() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        // NEW lines from here...
        builder: (BuildContext context) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('QR Code'),
            ),
            body: Center(
              child: RepaintBoundary(
                child: QrImageView(
                  data: tripCode,
                  version: 1,
                  size: 320,
                  gapless: true,
                  errorStateBuilder: (cxt, err) {
                    return const Center(
                      child: Text(
                        'Uh oh! Something went wrong...',
                        textAlign: TextAlign.center,
                      ),
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void deleteUser(int index) async {
    final messenger = ScaffoldMessenger.of(context);

    // Dismiss the dialog
    if (mounted) {
      Navigator.pop(context);
    }

    //Internet connection needed for deletion
    if (await InternetConnectionChecker().hasConnection) {

      //can't remove tripCreator
      if (userIDs[index] == tripCreator) {
        messenger.showSnackBar(
            const SnackBar(content: Text('Can not remove trip creator')));
      }
      else {
        //checks if theres any contribution remains for the user to delete
        if(providerIDs.contains(userIDs[index])){
          messenger.showSnackBar(const SnackBar(
            duration: Duration(seconds: 3),
              content: Text('This person has contributions in this trip remove/edit them first, then try again.'))
          );
          /*showDialog(
            context: infoContext,
            builder: (context) {
              return AlertDialog(
                title: const Text("Deletion Failed"),
                content: const Text('This person has contributions in this trip remove/edit them first, then try again.'),
                actions: [
                  TextButton(
                    onPressed: () {
                      // Dismiss the dialog
                      Navigator.pop(context);
                    },
                    child: const Text("Cancel"),
                  ),
                ],
              );
            },
          );*/
        }
        else{
          setState(() {
            _isLoading = true;
          });

          //Delete from trip
          FirebaseFirestore.instance.collection('trips').doc(tripCode).update({
            'users': FieldValue.arrayRemove([userIDs[index]]),
          });

          //Delete from userData
          FirebaseFirestore.instance
              .collection('userData')
              .doc(userIDs[index])
              .update({
            'tripCodes': FieldValue.arrayRemove([tripCode])
          });


          //If removes person himself
          if (userIDs[index] == FirebaseAuth.instance.currentUser!.uid) {
            messenger
                .showSnackBar(const SnackBar(content: Text('You left the trip')));

            Get.to(() => const MyTrips(), transition: Transition.fade);
          }
          else {
            //Delete from lists
            userIDs.removeAt(index);
            userNames.removeAt(index);

            //Delete from SharedPreferences
            final prefs = await SharedPreferences.getInstance();
            prefs.setStringList('userIDs', userIDs);

            prefs.setStringList('userNames', userNames);

            messenger.showSnackBar(const SnackBar(content: Text('User Removed')));
          }

          setState(() {
            _isLoading = false;
          });
        }

      }

    }
    else {
      messenger.showSnackBar(const SnackBar(
          content: Text('Internet Connection Required To Perform Deletion')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Get.to(() => BottomBar(bottomIndex: 0), transition: Transition.fade);

        return false;
      },
      child: Scaffold(
        appBar: HomeAppBar(
          connected: connection,
          isLoading: false,
        ),
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Trip Name",
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      Text(
                        tripName,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 25,
                            color: Colors.purple),
                      ),

                      //Trip info & TripCode
                      _tripInfoWidget(),

                      const SizedBox(
                        height: 15,
                      ),

                      //users
                      Text('Total ${userIDs.length} Person'),
                      const SizedBox(
                        height: 10,
                      ),
                      userBuilder(),

                      //version
                      version()
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _tripInfoWidget() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        //Trip Info
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.5 - 30,
          child: Text.rich(TextSpan(
              text: 'Created by ',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
              children: [
                TextSpan(
                    text: userNames[userIDs.indexOf(tripCreator)],
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        overflow: TextOverflow.clip,
                        color: Colors.black,
                        fontSize: 15)),
                const TextSpan(
                    text: " at ",
                    style: TextStyle(
                        overflow: TextOverflow.clip,
                        color: Colors.grey,
                        fontSize: 12)),
                TextSpan(
                    text: tripDate,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        overflow: TextOverflow.clip,
                        color: Colors.black,
                        fontSize: 14)),
              ])),
        ),

        //Space
        const SizedBox(
          width: 15,
        ),

        //Trip Code
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "#Access Code",
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
            SelectableText(tripCode,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    overflow: TextOverflow.clip,
                    fontSize: 40)),
            Row(
              children: [
                //copy
                GestureDetector(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Trip Code Copied')));
                    Clipboard.setData(ClipboardData(text: tripCode));
                  },
                  child: Container(
                    height: 37,
                    width: 37,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      border: Border.all(color: Colors.grey),
                      shape: BoxShape.circle,
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(5),
                      child: Icon(
                        Icons.copy,
                        size: 20,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),

                const SizedBox(
                  width: 10,
                ),

                //QR Code
                GestureDetector(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('QR Code Generated')));
                    _generateQR();
                  },
                  child: Container(
                    height: 37,
                    width: 37,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      border: Border.all(color: Colors.grey),
                      shape: BoxShape.circle,
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(5),
                      child: Icon(
                        Icons.qr_code_rounded,
                        size: 20,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),

                const SizedBox(
                  width: 10,
                ),

                //Share Code
                GestureDetector(
                  onTap: () async {
                    await Share.share(
                        'SplitShare: ( $tripName) Trip Joining Code: $tripCode');
                  },
                  child: Container(
                    height: 37,
                    width: 37,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      border: Border.all(color: Colors.grey),
                      shape: BoxShape.circle,
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(5),
                      child: Icon(
                        Icons.share_rounded,
                        size: 20,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ],
            )
          ],
        )
      ],
    );
  }

  Widget userBuilder() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: userIDs.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 5),
          child: ListTile(
              title: Text(
                userNames[index],
                style: const TextStyle(overflow: TextOverflow.clip),
              ),
              tileColor: Colors.blue.shade50,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              trailing: GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text("Confirm Delete"),
                        content: const Text("Are you sure you want to delete?"),
                        actions: [
                          TextButton(
                            onPressed: () {
                              // Dismiss the dialog
                              Navigator.pop(context);
                            },
                            child: const Text("Cancel"),
                          ),
                          TextButton(
                            onPressed: () async {
                              // Perform the delete action
                              deleteUser(index = index);
                            },
                            child: const Text("Delete"),
                          ),
                        ],
                      );
                    },
                  );
                },
                child: const SizedBox(
                  height: 37,
                  width: 37,
                  child: Padding(
                    padding: EdgeInsets.all(5),
                    child: Icon(
                      Icons.delete,
                      size: 20,
                      color: Colors.redAccent,
                    ),
                  ),
                ),
              )),
        );
      },
    );
  }

  Widget version() {
    return const Padding(
      padding: EdgeInsets.only(top: 50),
      child: Center(
        child: Text(
          'Version 2.0.0',
          style: TextStyle(color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
