import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class User {
  final String id;
  final String image;
  final String title;
  final String text;
  final String data;

  User({
    required this.id,
    required this.image,
    required this.title,
    required this.text,
    required this.data,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      image: json['image'],
      title: json['title'],
      text: json['text'],
      data: json['data'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'image': image,
      'title': title,
      'text': text,
      'data': data,
    };
  }
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mock API Users',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: UserListScreen(),
    );
  }
}

class UserListScreen extends StatefulWidget {
  @override
  _UserListScreenState createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  List<User> users = [];
  bool isLoading = false;
  bool isAddingUser = false;

  final TextEditingController _imageController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _dataController = TextEditingController();

  void showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> fetchUsers() async {
    setState(() {
      isLoading = true;
    });
    try {
      final response = await http.get(
        Uri.parse('https://6939834cc8d59937aa082275.mockapi.io/project'),
      );
      if (response.statusCode == 200) {
        setState(() {
          users = (json.decode(response.body) as List)
              .map((userJson) => User.fromJson(userJson))
              .toList();
        });
      } else {
        showErrorSnackBar("Ошибка при загрузке данных!");
      }
    } catch (e) {
      print("Ошибка загрузки: $e");
      showErrorSnackBar("Не удалось загрузить данные.");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> addUser() async {
    if (_imageController.text.isEmpty) {
      showErrorSnackBar("Изображение не может быть пустым");
      return;
    }

    setState(() {
      isAddingUser = true;
    });

    final newUser = User(
      id: '',
      image: _imageController.text,
      title: _titleController.text,
      text: _textController.text,
      data: _dataController.text,
    );

    try {
      final response = await http.post(
        Uri.parse('https://6939834cc8d59937aa082275.mockapi.io/project'),
        headers: {"Content-Type": "application/json"},
        body: json.encode(newUser.toJson()),
      );
      if (response.statusCode == 201 || response.statusCode == 200) {
        setState(() {
          users.add(User.fromJson(json.decode(response.body)));
        });
      }
    } catch (e) {
      print("Ошибка добавления пользователя: $e");
      showErrorSnackBar("Ошибка при добавлении пользователя.");
    } finally {
      setState(() {
        isAddingUser = false;
      });
    }
  }

  Future<void> deleteUser(id) async {
    try {
      final response = await http.delete(
        Uri.parse(
            'https://6939834cc8d59937aa082275.mockapi.io/project/$id'),
      );
      if (response.statusCode == 200) {
        fetchUsers();
      }
    } catch (e) {
      print("Ошибка удаления пользователя: $e");
      showErrorSnackBar("Ошибка при удалении пользователя.");
    }
  }

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Список пользователей')),
      body: SingleChildScrollView(
        child: Column(
          children: [

            Padding(
              padding: EdgeInsets.all(8.0),
              child: TextField(
                controller: _imageController,
                decoration: InputDecoration(labelText: 'Изображение'),
              ),
            ),

            Padding(
              padding: EdgeInsets.all(8.0),
              child: TextField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Заголовок'),
              ),
            ),

            Padding(
              padding: EdgeInsets.all(8.0),
              child: TextField(
                controller: _textController,
                decoration: InputDecoration(labelText: 'Текст'),
              ),
            ),

            ElevatedButton(
              onPressed: isAddingUser ? null : addUser,
              child: isAddingUser
                  ? CircularProgressIndicator()
                  : Text('Добавить пользователя'),
            ),

            SizedBox(height: 20),

            Container(
              height: 400,
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: users.length,
                      itemBuilder: (context, index) {
                        final user = users[index];
                        return Card(
                          margin: const EdgeInsets.all(8),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [

                                Image.network(
                                  user.image,
                                  width: double.infinity,
                                  height: 150,
                                  fit: BoxFit.cover,
                                  errorBuilder:
                                      (context, error, stackTrace) {
                                    return const Icon(Icons.broken_image);
                                  },
                                ),

                                const SizedBox(height: 8),

                                Text(
                                  user.title,
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),

                                const SizedBox(height: 4),

                                Text(
                                  user.text,
                                  style:
                                      const TextStyle(fontSize: 14),
                                ),

                                const SizedBox(height: 4),

                                Text(
                                  user.data,
                                  style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey),
                                ),

                                Align(
                                  alignment: Alignment.centerRight,
                                  child: IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.black),
                                    onPressed: () {
                                      deleteUser(user.id);
                                    },
                                  ),
                                ),

                              ],
                            ),
                          ),
                        );
                      },
                    ),
            )
        
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: fetchUsers,
        child: Icon(Icons.refresh),
      ),
    );
  }
}
