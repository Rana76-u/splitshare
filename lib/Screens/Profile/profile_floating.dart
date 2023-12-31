import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:splitshare/API/auth_service.dart';
import 'package:splitshare/Models/screensize.dart';
import 'package:splitshare/Screens/Login/login.dart';
import 'package:splitshare/Screens/My%20Trips/my_trips.dart';

class ProfileFloatingActionButton extends StatelessWidget {
  const ProfileFloatingActionButton({super.key});

  @override
  Widget build(BuildContext context) {

    ScreenSize screenSize = ScreenSize();

    return Padding(
      padding: EdgeInsets.only(bottom: screenSize.height(context)*0.03),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          //MyList
          SizedBox(
            width: 120,
            child: FittedBox(
              alignment: Alignment.bottomRight,
              child: FloatingActionButton.extended(
                heroTag: 'Btn1',
                onPressed: () async {
                  final messenger = ScaffoldMessenger.of(context);
                  bool result = await InternetConnectionChecker().hasConnection;

                  if(result == true){
                    Get.to(
                      () => const MyTrips(),
                      transition: Transition.fade,
                    );
                  }
                  else{
                    messenger.showSnackBar(
                      const SnackBar(content: Text("You're Not Connected"))
                    );
                  }
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100.0),
                ),
                label: const Text(
                  'My Trips',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15
                  ),
                ),
                icon: const Icon(
                    Icons.list_alt
                ),
              ),
            ),
          ),

          const SizedBox(width: 10,),

          //Logout
          SizedBox(
            width: 110,
            child: FittedBox(
              alignment: Alignment.bottomRight,
              child: FloatingActionButton.extended(
                heroTag: 'Btn2',
                onPressed: () {
                  AuthService().signOut();

                  Get.to(
                      () => const LoginPage(),
                    transition: Transition.fade
                  );
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100.0),
                ),
                label: const Text(
                  'Logout',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15
                  ),
                ),
                icon: const Icon(
                    Icons.logout_rounded
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
