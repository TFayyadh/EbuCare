import 'package:flutter/material.dart';
import 'package:ebucare_app/pages/manage_profile.dart';

class Header extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onLogout;

  const Header({super.key, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ManageProfile(),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.only(top: 10.0, left: 20),
          child: SizedBox(
            width: 30,
            height: 30,
            child: CircleAvatar(
              backgroundColor: Colors.blueGrey,
              child: Icon(Icons.person, color: Colors.white, size: 30),
            ),
          ),
        ),
      ),
      automaticallyImplyLeading: false,
      backgroundColor: const Color.fromARGB(255, 207, 241, 238),
      actions: [
        IconButton(
          onPressed: onLogout,
          icon: const Icon(Icons.logout),
        )
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
