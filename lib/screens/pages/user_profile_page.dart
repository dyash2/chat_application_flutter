import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserProfilePage extends StatefulWidget {
  final Map<String, dynamic> userData;

  const UserProfilePage({super.key, required this.userData});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final supabase = Supabase.instance.client;

  bool isUploading = false;

  // Pick & upload profile picture to Supabase
  Future<void> _pickAndUploadProfilePic() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile == null) return;

    setState(() => isUploading = true);

    try {
      File file = File(pickedFile.path);

      // Generate file name using date and time in minutes
      final now = DateTime.now();
      final formattedName =
          '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}';
      final extension = file.path.split('.').last;
      final fileName = '$formattedName.$extension';
      final filePath = 'uploads/$fileName';

      // Upload to Supabase
      await supabase.storage.from('chat-files').upload(filePath, file);
      String publicUrl =
          supabase.storage.from('chat-files').getPublicUrl(filePath);

      // Update Firestore with new profile picture URL
      await firestore.collection("Users").doc(auth.currentUser!.uid).update({
        "profilePicUrl": publicUrl,
      });

      setState(() {
        widget.userData['profilePicUrl'] = publicUrl;
      });
    } catch (e) {
      print("Error uploading profile picture: $e");
    } finally {
      setState(() => isUploading = false);
    }
  }

  // Update any field (status, phone, etc.)
  Future<void> _updateField(String field, String value) async {
    await firestore.collection("Users").doc(auth.currentUser!.uid).update({
      field: value,
    });
    setState(() {
      widget.userData[field] = value;
    });
  }

  // Dialog to edit a field
  Future<String?> _showEditDialog(String title, String field) async {
    TextEditingController controller =
        TextEditingController(text: widget.userData[field] ?? '');
    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: TextField(controller: controller),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
            TextButton(
                onPressed: () => Navigator.pop(context, controller.text),
                child: const Text("Save")),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    bool hasProfilePic =
        widget.userData['profilePicUrl'] != null &&
        widget.userData['profilePicUrl'].isNotEmpty;
    String email = widget.userData["email"] ?? "No Email";
    String displayName =
        widget.userData["name"]?.isNotEmpty == true ? widget.userData["name"] : email.split('@')[0];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 30),

            // Profile Picture with Upload Option
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundImage: hasProfilePic
                      ? NetworkImage(widget.userData['profilePicUrl'])
                      : null,
                  backgroundColor: Colors.grey[300],
                  child: !hasProfilePic
                      ? const Icon(Icons.person, size: 60, color: Colors.grey)
                      : null,
                ),
                if (auth.currentUser!.uid == widget.userData['id'])
                  Positioned(
                    bottom: 0,
                    right: 4,
                    child: CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.blue,
                      child: IconButton(
                        icon: const Icon(Icons.camera_alt, color: Colors.white),
                        onPressed: isUploading ? null : _pickAndUploadProfilePic,
                      ),
                    ),
                  ),
              ],
            ),
            if (isUploading) const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),

            // Name
            const SizedBox(height: 16),
            Text(displayName,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),

            // Email
            const SizedBox(height: 6),
            Text(email, style: TextStyle(fontSize: 16, color: Colors.grey[600])),

            // Status
            const SizedBox(height: 20),
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              elevation: 2,
              child: ListTile(
                leading: const Icon(Icons.info_outline, color: Colors.blue),
                title: const Text("Status"),
                subtitle: Text(widget.userData['status'] ?? 'Available'),
                trailing: auth.currentUser!.uid == widget.userData['id']
                    ? IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () async {
                          final newStatus =
                              await _showEditDialog("Update Status", "status");
                          if (newStatus != null && newStatus.isNotEmpty) {
                            _updateField("status", newStatus);
                          }
                        },
                      )
                    : null,
              ),
            ),

            // Phone
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              elevation: 2,
              child: ListTile(
                leading: const Icon(Icons.phone, color: Colors.green),
                title: const Text("Phone"),
                subtitle: Text(widget.userData['phone'] ?? 'Not Provided'),
                trailing: auth.currentUser!.uid == widget.userData['id']
                    ? IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () async {
                          final newPhone =
                              await _showEditDialog("Update Phone", "phone");
                          if (newPhone != null && newPhone.isNotEmpty) {
                            _updateField("phone", newPhone);
                          }
                        },
                      )
                    : null,
              ),
            ),

            // Last Seen
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              elevation: 2,
              child: ListTile(
                leading: const Icon(Icons.access_time, color: Colors.orange),
                title: const Text("Last Seen"),
                subtitle: Text(widget.userData['lastSeen'] ?? 'Recently Active'),
              ),
            ),

            // Online Status
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    widget.userData['isOnline'] == true
                        ? Icons.circle
                        : Icons.circle_outlined,
                    color: widget.userData['isOnline'] == true
                        ? Colors.green
                        : Colors.red,
                    size: 14,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    widget.userData['isOnline'] == true ? "Online" : "Offline",
                    style: TextStyle(
                      fontSize: 16,
                      color: widget.userData['isOnline'] == true
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
