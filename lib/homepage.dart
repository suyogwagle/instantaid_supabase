import 'package:flutter/material.dart';
import 'package:instant_aid/main.dart';
import 'models/user_model.dart';
import 'widget/state_transition.dart';

class HomePage extends StatelessWidget {
  final UserModel user;

  const HomePage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ListView(
            children: [
              const SizedBox(height: 16),

              // Greeting and profile
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hello, ${user.fullName ?? user.username ?? 'User'}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text('Welcome to InstantAID'),
                    ],
                  ),
                  PopupMenuButton<int>(
                    onSelected: (value) async {
                      if (value == 0) {
                        // Profile page
                        Navigator.pushNamed(context, '/profile');
                      } else if (value == 1) {
                        // Settings page
                        Navigator.pushNamed(context, '/settings');
                      } else if (value == 2) {
                        // Logout
                        await supabase.auth.signOut();

                        // After logout, redirect user to login page
                        Navigator.pushReplacementNamed(context, '/login');
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 0,
                        child: Text("Profile"),
                      ),
                      const PopupMenuItem(
                        value: 1,
                        child: Text("Settings"),
                      ),
                      const PopupMenuItem(
                        value: 2,
                        child: Text("Logout"),
                      ),
                    ],
                    child: CircleAvatar(
                      radius: 22,
                      backgroundImage: (user.avatarUrl != null && user.avatarUrl!.isNotEmpty)
                          ? NetworkImage(user.avatarUrl!)
                          : const AssetImage('assets/images/default_avatar.png')
                      as ImageProvider,
                    ),
                  )



                ],
              ),

              const SizedBox(height: 24),

              // Search bar
              TextField(
                decoration: InputDecoration(
                  hintText: 'Search',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.filter_alt),
                    onPressed: () {},
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
              ),

              const SizedBox(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 24), // Only top margin
                    child: Text(
                      "Current Progress",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SlidingTrainingProgress(
                    progressItems: [
                      TrainingProgress(0.7, "CPR Training"),
                      TrainingProgress(0.4, "Burn Treatment"),
                      TrainingProgress(0.9, "Shock Management"),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 40),
              // More content can go here
            ],
          ),
        ),
      ),

      // Custom bottom navigation bar
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 5, left: 10, right: 10),
        child: Container(
          height: 70,
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 9, 9, 9),
            borderRadius: BorderRadius.circular(60),
            boxShadow: const [
              BoxShadow(
                color: Color.fromARGB(31, 0, 0, 0),
                blurRadius: 10,
                offset: Offset(0, -2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(80),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),

              child: SizedBox(
                height: 40,
                child: Theme(
                  data: Theme.of(context).copyWith(
                    splashColor: const Color.fromARGB(
                      55,
                      98,
                      108,
                      105,
                    ), // white with ~25% opacity
                    highlightColor: const Color.fromARGB(
                      51,
                      255,
                      255,
                      255,
                    ), // white with ~20% opacity
                    splashFactory: InkRipple.splashFactory,
                  ),
                  child: BottomNavigationBar(
                    backgroundColor: const Color.fromARGB(255, 9, 9, 9),
                    selectedIconTheme: const IconThemeData(
                      color: Color.fromARGB(255, 255, 255, 255),
                      size: 40, // slightly larger to emphasize
                    ),
                    unselectedItemColor: const Color.fromARGB(
                      255,
                      168,
                      166,
                      166,
                    ),
                    type: BottomNavigationBarType.fixed,
                    currentIndex: 1,
                    showSelectedLabels: false,
                    showUnselectedLabels: false,
                    selectedFontSize: 0,
                    unselectedFontSize: 0,
                    iconSize: 30,
                    onTap: (index) {},
                    items: const [
                      BottomNavigationBarItem(
                        icon: Icon(Icons.home),
                        label: '',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.person_sharp),
                        label: '',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.emergency),
                        label: '',
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
