import 'package:befriend/models/objects/bubble.dart';
import 'package:befriend/providers/profile_provider.dart';
import 'package:flutter/material.dart';

class MutualPage extends StatefulWidget {
  const MutualPage({super.key});

  @override
  State<MutualPage> createState() => _MutualPageState();
}

class _MutualPageState extends State<MutualPage> {
  List<Bubble> filteredUsers = [];
  final List<Bubble> users = ProfileProvider.commonFriends;

  @override
  void initState() {
    super.initState();
    // Initially, all users are shown
    filteredUsers = users;
  }

  void _filterUsers(String searchTerm) {
    final lowerCaseSearchTerm = searchTerm.toLowerCase();
    setState(() {
      filteredUsers = users.where((user) {
        return user.username.toLowerCase().contains(lowerCaseSearchTerm) ||
            user.name.toLowerCase().contains(lowerCaseSearchTerm);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mutual'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: _filterUsers,
              decoration: InputDecoration(
                labelText: 'Search',
                suffixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredUsers.length,
              itemBuilder: (context, index) {
                final user = filteredUsers[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: filteredUsers[index].avatar,
                  ),
                  title: Text(user.username),
                  subtitle: Text(user.name),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
