import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../model/user.dart';
import '../screens/user_details_screen.dart';
import '../utils/constants.dart';
import '../widgets/drawer.dart';

Future<List<User>> _fetchUsersList() async {
  final response = await http.get(Uri.parse(URL_GET_USERS_LIST));

  if (response.statusCode == 200) {
    List jsonResponse = json.decode(response.body);
    return jsonResponse.map((user) => User.fromJson(user)).toList();
  } else {
    throw Exception('Failed to load users from API');
  }
}

ListView _usersListView(data) {
  return ListView.builder(
      itemCount: data.length,
      itemBuilder: (context, index) {
        return _userListTile(
          data[index].name,
          data[index].email,
          Icons.work,
          context,
          data[index].id,
        );
      });
}

ListTile _userListTile(
  String title,
  String subtitle,
  IconData icon,
  BuildContext context,
  int userId,
) =>
    ListTile(
      title: Text(title,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 20,
          )),
      subtitle: Text(subtitle),
      onTap: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => UserDetailsScreen(userId))),
      leading: Icon(
        icon,
        color: Colors.blue[500],
      ),
    );

class UsersListScreen extends StatefulWidget {
  const UsersListScreen({Key? key}) : super(key: key);

  @override
  _UsersListScreenState createState() => _UsersListScreenState();
}

class _UsersListScreenState extends State<UsersListScreen> {
  late Future<List<User>> futureUsersList;
  late List<User> usersListData;

  @override
  void initState() {
    super.initState();
    futureUsersList = _fetchUsersList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Список юзеров'),
      ),
      drawer: drawer(context),
      body: Center(
        child: FutureBuilder<List<User>>(
          future: futureUsersList,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              usersListData = snapshot.data!;
              return _usersListView(usersListData);
            } else if (snapshot.hasError) {
              return Text('${snapshot.error}');
            }

            return const CircularProgressIndicator();
          },
        ),
      ),
    );
  }
}
