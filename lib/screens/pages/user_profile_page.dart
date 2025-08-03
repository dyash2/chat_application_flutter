import 'package:flutter/material.dart';

class UserProfilePage extends StatelessWidget {
  final Map<String, dynamic> userData;

  const UserProfilePage({super.key, required this.userData});

  @override
  Widget build(BuildContext context) {
    bool hasProfilePic =
        userData['profilePicUrl'] != null &&
        userData['profilePicUrl'].isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        centerTitle: false,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_ios_rounded),
          color: Theme.of(context).colorScheme.onPrimary,
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Profile Picture
            const SizedBox(height: 30),
            CircleAvatar(
              radius: 60,
              backgroundImage: hasProfilePic
                  ? NetworkImage(userData['profilePicUrl'])
                  : null,
              backgroundColor: Colors.grey[300],
              child: !hasProfilePic
                  ? const Icon(Icons.person, size: 60, color: Colors.grey)
                  : null,
            ),

            // Name
            const SizedBox(height: 16),
            Text(
              userData["name"] ?? userData["email"].split('@')[0],
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            // Email
            const SizedBox(height: 6),
            Text(
              userData["email"] ?? "No Email",
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),

            // Status
            const SizedBox(height: 20),
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              elevation: 2,
              child: ListTile(
                leading: const Icon(Icons.info_outline, color: Colors.blue),
                title: const Text("Status"),
                subtitle: Text(userData['status'] ?? 'Available'),
              ),
            ),

            // Phone Number
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              elevation: 2,
              child: ListTile(
                leading: const Icon(Icons.phone, color: Colors.green),
                title: const Text("Phone"),
                subtitle: Text(userData['phone'] ?? 'Not Provided'),
              ),
            ),

            // Last Seen
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              elevation: 2,
              child: ListTile(
                leading: const Icon(Icons.access_time, color: Colors.orange),
                title: const Text("Last Seen"),
                subtitle: Text(userData['lastSeen'] ?? 'Recently Active'),
              ),
            ),

            // Online Status
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    userData['isOnline'] == true
                        ? Icons.circle
                        : Icons.circle_outlined,
                    color: userData['isOnline'] == true
                        ? Colors.green
                        : Colors.red,
                    size: 14,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    userData['isOnline'] == true ? "Online" : "Offline",
                    style: TextStyle(
                      fontSize: 16,
                      color: userData['isOnline'] == true
                          ? Colors.green
                          : Colors.red,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
