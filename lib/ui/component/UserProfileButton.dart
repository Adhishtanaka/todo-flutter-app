import 'package:flutter/material.dart';
import 'package:todo_app/ui/signin.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProfileButton extends StatefulWidget {
  const UserProfileButton({super.key});

  @override
  State<UserProfileButton> createState() => _UserProfileButtonState();
}

class _UserProfileButtonState extends State<UserProfileButton> {
  Map<String, dynamic>? user;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showProfileDialog(context),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16.0),
        child: CircleAvatar(
          radius: 16,
          backgroundColor: Colors.yellow[200],
          child: const Icon(
            Icons.person,
            size: 18,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  Future<dynamic> getUserInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');
      if (token == null) return null;

      final dio = Dio();
      final response = await dio.get(
        'https://thetodaytodo.netlify.app/api/auth',
        options: Options(
          headers: {
            'Cookie': 'token=$token',
          },
        ),
      );

      if (response.statusCode == 200) {
        return response.data;
      }
      return null;
    } catch (e) {
      print('Error getting user info: $e');
      return null;
    }
  }


  Future<void> _showProfileDialog(BuildContext context) async {
    user ??= await getUserInfo();

    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            constraints: const BoxConstraints(maxWidth: 320),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'User Profile',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                if (user != null) ...[
                  CircleAvatar(
                    radius: 48,
                    backgroundColor: Colors.transparent,
                    backgroundImage: NetworkImage(
                      'https://ui-avatars.com/api/?name=${Uri.encodeComponent(user!['name'] ?? 'Unknown')}&background=555&color=fff&size=128&format=png',
                    ),
                  ),

                  const SizedBox(height: 12),
                  Text(
                    user!['name'] ?? 'User',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    user!['email'] ?? 'No email',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade400,
                    ),
                  ),
                ] else
                  const Text(
                    'Loading user info...',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.remove('token');
                        if (!context.mounted) return;
                        Navigator.pop(context);
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const SignInScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade600,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Logout'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('Close'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}