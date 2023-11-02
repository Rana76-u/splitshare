import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:splitshare/Screens/Profile/profile.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {

  final bool connected;
  const HomeAppBar({super.key, required this.connected,});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      title: const Text(
        'SPLITSHARE',
        style: TextStyle(
          fontFamily: 'Anurati',
          fontSize: 25,
          letterSpacing: 3,
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 20),
          child: GestureDetector(
            onTap: () {},
            child: SizedBox(
              height: 35,
              width: 35,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: !connected
                    ?
                /*Lottie.asset(
                    'assets/lottie/profile.json'
                    )*/
                const Text('Profile Photo')
                    :
                GestureDetector(
                  onTap: () {
                    Get.to(
                        () => const Profile(),
                      transition: Transition.fade
                    );
                  },
                      child: Image.network(
                  FirebaseAuth.instance.currentUser!.photoURL ?? '',
                  ),
                ),
              ),
            ),
          ),
        )
      ],
    );
  }
}
