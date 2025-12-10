import 'package:flutter/material.dart';
import 'package:instant_aid/main.dart';
import 'package:instant_aid/pages/emergency_page.dart';
import 'package:instant_aid/pages/notifications_page.dart';
import 'package:instant_aid/pages/userpage.dart';
import 'package:instant_aid/services/injury_classifier.dart';
import 'package:instant_aid/services/whisper_service.dart';
import 'package:instant_aid/pages/training_page.dart';
import 'package:instant_aid/widget/recommended_section_card.dart';
import '../models/user_model.dart';
import '../widget/state_transition.dart';

class HomePage extends StatefulWidget {
  final UserModel user;
  const HomePage({super.key, required this.user});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 1;
  final InjuryClassifier classifier = InjuryClassifier();
  final WhisperService whisper = WhisperService();

  // Handle bottom nav taps
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 0) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => UserPage(user: widget.user)),
      );
    } else if (index == 2) {
      Future.microtask(() {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EmergencyModeScreen(
              classifier: classifier,
              whisper: whisper,
            ),
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: HomeContent(user: widget.user),  // DEFAULT PAGE
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 10, left: 10, right: 10),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(60),
          child: BottomNavigationBar(
            elevation: 10.0,
            backgroundColor: Colors.black,
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            showSelectedLabels: false,
            showUnselectedLabels: false,
            selectedIconTheme: const IconThemeData(color: Colors.white, size: 32),
            unselectedItemColor: Colors.grey,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.person), label: ''),
              BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
              BottomNavigationBarItem(icon: Icon(Icons.warning_rounded), label: ''),
            ],
          ),
        ),
      ),

    );
  }
}

class HomeContent extends StatelessWidget {
  final UserModel user;
  const HomeContent({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: ListView(
          padding: const EdgeInsets.only(bottom: 90),
          children: [
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hello, ${user.fullName ?? user.username ?? 'User'}',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const Text('Welcome to InstantAID'),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 40.0),
                  child: IconButton(
                    icon: const Icon(Icons.notifications_active_sharp, color: Colors.black54),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const NotificationsPage()),
                      );
                    },                  ),
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
                        : const NetworkImage("https://encrypted-tbn3.gstatic.com/images?q=tbn:ANd9GcQIy4d7P3mJN5n44jxkUjp24w5W1FF2ro43MBxyZqTV2EOB9hVgw1ZW3m9kFoxqA6TD2AqigsYj")
                    as ImageProvider,
                  ),
                )
              ],
            ),
            const SizedBox(height: 24),
            TextField(
              decoration: InputDecoration(
                hintText: 'Search',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                filled: true,
                fillColor: const Color(0xFF006DBF).withValues(alpha: 0.1),
              ),
            ),

            const SizedBox(height: 20),
            Row(
              children: [
                const Text(
                  "Current Progress",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Padding(
                    padding: EdgeInsets.only(right: 10.0),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TrainingPage(),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.only(bottom: 0.25),
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Colors.black,
                              width: 1.5,
                            ),
                          ),
                        ),
                        child: const Text(
                          "Keep Learning",
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    )
                ),
              ],
            ),


            SlidingTrainingProgress(
              progressItems: [
                TrainingProgress(0.7, "CPR Training"),
                TrainingProgress(0.4, "Burn Treatment"),
                TrainingProgress(0.9, "Shock Management"),
              ],
            ),
            const SizedBox(height: 10),
            const Text(
              "Recommended Lessons",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            RecommendedSectionCard(),
            RecommendedSectionCard(),
            RecommendedSectionCard(),
            RecommendedSectionCard(),
          ],
        ),
      ),
    );
  }
}





