import 'package:flutter/material.dart';
import 'package:instant_aid/main.dart';
import 'package:instant_aid/models/user_model.dart';
import 'package:instant_aid/pages/edit_profile.dart';
import 'package:instant_aid/pages/emergency_page.dart';
import 'package:instant_aid/pages/history_page.dart';
import 'package:instant_aid/pages/homepage.dart';
import 'package:instant_aid/pages/settings_page.dart';
import 'package:instant_aid/services/injury_classifier.dart';
import 'package:instant_aid/services/profile_service.dart';
import 'package:instant_aid/services/whisper_service.dart';

class UserPage extends StatefulWidget {
  final UserModel user;
  const UserPage({super.key, required this.user});

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  int _selectedIndex = 0;
  final InjuryClassifier classifier = InjuryClassifier();
  final WhisperService whisper = WhisperService();
  String? _imageUrl;

  Map<String, dynamic>? profile;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final data = await ProfileService().getUserProfile(widget.user.id);
    setState(() {
      profile = data;
      loading = false;
    });
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);

    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => HomePage(user: widget.user),
        ),
      );
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EmergencyModeScreen(classifier: classifier, whisper: whisper,),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          _Header(profile, widget.user),
          const SizedBox(height: 20),
          _InfoCard(profile),
          const SizedBox(height: 20),
          _QuickActions(
            onEditProfile: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => EditProfileScreen(user: widget.user)),
              );
            },
            onHistory: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => HistoryPage(historyItems: [],)),
              );
            },
            onSettings: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => SettingsPage()),
              );
            },
          ),

        ],
      ),

      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 10, left: 10, right: 10),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(60),
          child: BottomNavigationBar(
            backgroundColor: Colors.black,
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            showSelectedLabels: false,
            showUnselectedLabels: false,
            selectedIconTheme:
            const IconThemeData(color: Colors.white, size: 32),
            unselectedItemColor: Colors.grey,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.person), label: ''),
              BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
              BottomNavigationBarItem(icon: Icon(Icons.warning_rounded), label: ''),            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final UserModel user;
  final Map<String, dynamic>? profile;
  const _Header(this.profile, this.user);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.30,
      width: MediaQuery.of(context).size.width * 1,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xff0043ba), Color(0xff006df1)],
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(50),
          bottomRight: Radius.circular(50),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          CircleAvatar(
            radius: 55,
            backgroundImage: (user.avatarUrl != null && user.avatarUrl!.isNotEmpty)
                ? NetworkImage(user.avatarUrl!)
                : const NetworkImage("https://encrypted-tbn3.gstatic.com/images?q=tbn:ANd9GcQIy4d7P3mJN5n44jxkUjp24w5W1FF2ro43MBxyZqTV2EOB9hVgw1ZW3m9kFoxqA6TD2AqigsYj")
            as ImageProvider,
          ),
          const SizedBox(height: 10),
          Text(
            profile?['full_name'] ?? "User",
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            profile?['email'] ?? "No email",
            style: const TextStyle(color: Colors.white70, fontSize: 16),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final Map<String, dynamic>? profile;
  const _InfoCard(this.profile);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
          )
        ],
      ),
      child: Column(
        children: [
          _infoRow(Icons.phone, "Phone", profile?['phone'] ?? "Not provided"),
          const Divider(),
          _infoRow(Icons.location_on, "Address",
              profile?['address'] ?? "Not provided"),
          const Divider(),
          _infoRow(Icons.bloodtype, "Blood Group",
              profile?['blood_group'] ?? "Not set"),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String title, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.blue, size: 28),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
        Text(value, style: const TextStyle(fontSize: 16)),
      ],
    );
  }
}

class ContactsCard extends StatelessWidget {
  final Map<String, dynamic>? profile;
  const ContactsCard(this.profile);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
          )
        ],
      ),
      child: Column(
        children: [
          _infoRow(Icons.phone, "Phone", profile?['phone'] ?? "Not provided"),
          const Divider(),
          _infoRow(Icons.location_on, "Address",
              profile?['address'] ?? "Not provided"),
          const Divider(),
          _infoRow(Icons.bloodtype, "Blood Group",
              profile?['blood_group'] ?? "Not set"),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String title, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.blue, size: 28),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
        Text(value, style: const TextStyle(fontSize: 16)),
      ],
    );
  }
}

class _QuickActions extends StatelessWidget {
  final VoidCallback onEditProfile;
  final VoidCallback onHistory;
  final VoidCallback onSettings;

  const _QuickActions({
    required this.onEditProfile,
    required this.onHistory,
    required this.onSettings,
  });


  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          "Quick Actions",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 15),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _actionButton(Icons.edit, "Edit Profile", onEditProfile),
            _actionButton(Icons.history, "History", onHistory),
            _actionButton(Icons.settings, "Settings", onSettings),
          ],
        ),
      ],
    );
  }

  Widget _actionButton(IconData icon, String title, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.blue[100],
            child: Icon(icon, size: 28, color: Colors.blue),
          ),
          const SizedBox(height: 8),
          Text(title),
        ],
      ),
    );
  }
}



