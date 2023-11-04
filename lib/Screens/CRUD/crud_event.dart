import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:splitshare/Models/manage_crud_operations.dart';
import 'package:splitshare/Widgets/loading.dart';

// ignore: must_be_immutable
class CRUDEvent extends StatefulWidget {
  String? title;
  String? amount;
  String? description;
  String? provider;
  String? docID;

  CRUDEvent({
    super.key,
    this.title,
    this.amount,
    this.description,
    this.provider,
    this.docID
  });

  @override
  State<CRUDEvent> createState() => _CRUDEventState();
}

class _CRUDEventState extends State<CRUDEvent> {

  bool _isLoading = false;
  bool amountFLag = false;
  bool providerFlag = false;

  int selectedProviderFlag = -1;

  String selectedUserID = '';
  String selectedUserName = '';
  List<String>? userNames = [];
  List<String>? userIDs = [];

  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController amountController = TextEditingController();

  @override
  void initState() {
    _isLoading = true;
    loadUsers();
    super.initState();
  }

  void loadUsers() async {
    final prefs = await SharedPreferences.getInstance();

    userNames = prefs.getStringList('userNames');
    userIDs = prefs.getStringList('userIDs');

    print(userNames);
    print(userIDs);

    if(widget.title != null){
      titleController.text = widget.title!;
      descriptionController.text = widget.description!;
      amountController.text = widget.amount!;

      selectedProviderFlag = userNames!.indexOf(widget.provider!);
      selectedUserID = userIDs![selectedProviderFlag];
      selectedUserName = userNames![selectedProviderFlag];
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> uploadInfo() async {

    setState(() {
      _isLoading = true;
    });

    final messenger = ScaffoldMessenger.of(context);
    final prefs = await SharedPreferences.getInstance();

    String? tripCode = prefs.getString('tripCode');

    if(amountController.text.isEmpty){

      setState(() {
        amountFLag = true;
      });

      messenger.showSnackBar(
          const SnackBar(content: Text('Input Amount*'))
      );
    }
    else if(selectedUserID == ''){

      setState(() {
        providerFlag = true;
      });

      messenger.showSnackBar(
          const SnackBar(content: Text('Please Select A Provider'))
      );
    }
    else{

      await ManageCRUDOperations().uploadInfo(
          titleController.text,
          descriptionController.text,
          double.parse(amountController.text),
          selectedUserID,
          selectedUserName,
          widget.docID ?? 'new',
          tripCode!);

      //upload Data to Firebase
      /*if(await InternetConnectionChecker().hasConnection){
          await FirebaseFirestore
              .instance
              .collection('trips')
              .doc(tripCode)
              .collection('Events')
              .doc()
              .set({
            'title': titleController.text,
            'description': descriptionController.text,
            'amount': double.parse(amountController.text),
            'time': DateTime.now(),
            'addedBy': FirebaseAuth.instance.currentUser!.uid,
            'providedBy': selectedUserID,
          });

          Get.to(
              () => BottomBar(bottomIndex: 0),
            transition: Transition.fade
          );
      }
      else{

      }*/
      //------------------- ELSE WHAT ------------------------------
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {

    Loading loading = Loading();

    return Scaffold(
      appBar: AppBar(
        actions: [
          //Save Button
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: ElevatedButton(
              onPressed: () async {
                await uploadInfo();
              },
              style: ButtonStyle(
                  backgroundColor: MaterialStateColor.resolveWith((states) => const Color(0xFF8F00FF))
              ),
              child: const Text(
                'Save',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold
                ),
              ),
            ),
          ),

          //3Dot Icon
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: GestureDetector(
              onTap: () {},
              child: const SizedBox(
                height: 35,
                width: 35,
                child: Icon(Icons.more_horiz_rounded),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: _isLoading ?
        loading.central(context)
            :
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              const SizedBox(height: 10,),

              //title
              textFieldWidget(titleController, 'Title'),

              const SizedBox(height: 5,),

              //Amount
              SizedBox(
                height: 60,
                child: TextField(
                  controller: amountController,
                  onChanged: (value) {
                    setState(() {
                      amountFLag = false;
                    });
                  },
                  decoration: InputDecoration(
                    focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide.none
                    ),
                    enabledBorder:  const OutlineInputBorder(
                        borderSide: BorderSide.none
                    ),
                    prefixIcon: const Icon(
                      Icons.onetwothree,
                      color: Colors.grey,
                    ),
                    filled: true,
                    fillColor: amountFLag ? Colors.red.shade50 : Colors.grey[100],
                    hintText: 'Amount',
                  ),
                  cursorColor: Colors.black,
                  keyboardType: TextInputType.number,
                ),
              ),

              const SizedBox(height: 5,),

              const Text('Provider'),

              const SizedBox(height: 5,),

              //Provider Name
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  color: providerFlag ? Colors.red.shade50 : Colors.white,
                ),
                child: SizedBox(
                  height: 50,
                  //MediaQuery.of(context).size.width*0.9 - 40,
                  child: ListView.builder(
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    itemCount: userNames?.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 4),
                        child: TextButton(
                          onPressed: (){
                            setState(() {
                              selectedProviderFlag = index;

                              providerFlag = false;
                              selectedUserID = userIDs![index];
                            });
                          },
                          style: ButtonStyle(
                            backgroundColor: MaterialStateColor.resolveWith(
                                    (states) => selectedProviderFlag == index ? Colors.deepPurple : Colors.deepPurple.withOpacity(0.08)
                            ),

                          ),
                          child: Center(
                              child: Text(
                                userNames![index],
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  color: selectedProviderFlag == index ? Colors.white : Colors.black
                                ),
                              )
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              const SizedBox(height: 8,),

              //Description
              Container(
                constraints: const BoxConstraints(
                    minHeight: 135,//135
                    maxHeight: 300
                ),
                child: TextField(
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  controller: descriptionController,
                  style: const TextStyle(
                      overflow: TextOverflow.clip
                  ),
                  decoration: InputDecoration(
                    focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide.none
                    ),
                    enabledBorder:  const OutlineInputBorder(
                        borderSide: BorderSide.none
                    ),
                    prefixIcon: const Icon(
                      Icons.short_text_rounded,
                      color: Colors.grey,
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                    hintText: 'Description',
                  ),
                  cursorColor: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget textFieldWidget(TextEditingController textEditingController, String hint) {
    return SizedBox(
      height: 60,
      child: TextField(
        controller: textEditingController,
        autofocus: true,
        decoration: InputDecoration(
          focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide.none
          ),
          enabledBorder:  const OutlineInputBorder(
              borderSide: BorderSide.none
          ),
          prefixIcon: const Icon(
            Icons.short_text_rounded,
            color: Colors.grey,
          ),
          filled: true,
          fillColor: Colors.grey[100],
          hintText: hint,
        ),
        cursorColor: Colors.black,
      ),
    );
  }
}
