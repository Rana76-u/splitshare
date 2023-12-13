import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:get/get.dart';
import 'package:splitshare/Screens/Profile/profile.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool connected;
  final bool isLoading;

  const HomeAppBar({
    super.key,
    required this.connected,
    required this.isLoading,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  void backupSystem() {

  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      title: GestureDetector(
        onTap: () {
          FlutterOverlayWindow.showOverlay(height: 100, width: 100);
        },
        child: const Text(
          'SPLITSHARE',
          style: TextStyle(
            fontFamily: 'Anurati',
            fontSize: 25,
            letterSpacing: 3,
          ),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 15),
          child: isLoading && connected ?
          GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Backup In Progress')
                  )
              );
            },
            child: const SizedBox(
              width: 50,
              child: LinearProgressIndicator(),
            ),
          )
              : connected ?
          GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('All Data Backup Successfully')
                )
              );
            },
            child: const Icon(
              Icons.cloud_done_rounded,
              color: Colors.green,
            ),
          )
              :
          GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Backup Is Pending')
                  )
              );
            },
            child: const Icon(
              Icons.cloud_done_rounded,
              color: Colors.grey,
            ),
          ),
        ),

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
                    const Icon(Icons.person)
                    : GestureDetector(
                        onTap: () {
                          Get.to(() => const Profile(),
                              transition: Transition.fade);
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
