import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'login_page.dart'; // Asegúrate de importar la pantalla de login

const String apiKey =
    'yLXwLEq2acs0WX5IpzVnEuuFxWnB2jn2xj1NTUGAaQF2PTwmvaF9n3w6';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const LoginPage(), // Cambia a la pantalla de login
    );
  }
}

class Task {
  final String title;
  final String time;
  final String category;
  final IconData icon;
  final String imageUrl;
  bool isFavorite;

  Task({
    required this.title,
    required this.time,
    required this.category,
    required this.icon,
    required this.imageUrl,
    this.isFavorite = false,
  });
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;
  List<Task> tasks = [];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _addTask(Task task) {
    setState(() {
      tasks.add(task);
      _selectedIndex = 0; // Vuelve al home después de agregar la tarea
    });
  }

  void _logout() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  void _removeTask(Task task) {
    setState(() {
      tasks.remove(task);
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> widgetOptions = <Widget>[
      TaskListPage(tasks: tasks, onRemoveTask: _removeTask),
      AddTaskPage(onAddTask: _addTask),
      FavoritesPage(tasks: tasks),
      const ProfilePage(),
    ];

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.logout),
          onPressed: _logout,
        ),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle, size: 40), // botón central más grande
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}

class TaskListPage extends StatefulWidget {
  final List<Task> tasks;
  final Function(Task) onRemoveTask;

  const TaskListPage(
      {super.key, required this.tasks, required this.onRemoveTask});

  @override
  _TaskListPageState createState() => _TaskListPageState();
}

class _TaskListPageState extends State<TaskListPage> {
  String _searchText = '';

  @override
  Widget build(BuildContext context) {
    List<Task> filteredTasks = widget.tasks
        .where((task) =>
            task.title.toLowerCase().contains(_searchText.toLowerCase()))
        .toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search Tasks',
              prefixIcon: const Icon(Icons.search),
              border: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(30.0)),
              ),
              enabledBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(30.0)),
                borderSide: BorderSide(color: Colors.grey),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: const BorderRadius.all(Radius.circular(30.0)),
                borderSide: BorderSide(color: Colors.amber[800]!),
              ),
            ),
            onChanged: (text) {
              setState(() {
                _searchText = text;
              });
            },
          ),
        ),
        Expanded(
          child: filteredTasks.isEmpty
              ? const Center(
                  child: Text(
                    'No tasks available',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(8.0),
                  itemCount: filteredTasks.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              content:
                                  Image.network(filteredTasks[index].imageUrl),
                              actions: <Widget>[
                                TextButton(
                                  child: const Text("Close"),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      },
                      child: TaskCard(
                        task: filteredTasks[index],
                        onFavoriteToggle: () {
                          setState(() {
                            filteredTasks[index].isFavorite =
                                !filteredTasks[index].isFavorite;
                          });
                        },
                        onRemoveTask: () {
                          widget.onRemoveTask(filteredTasks[index]);
                        },
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback onFavoriteToggle;
  final VoidCallback onRemoveTask;

  const TaskCard({
    super.key,
    required this.task,
    required this.onFavoriteToggle,
    required this.onRemoveTask,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: task.isFavorite ? Colors.amber[100] : Colors.blueAccent,
      child: ListTile(
        leading: Icon(task.icon, color: Colors.white),
        title: Text(
          task.title,
          style:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          task.time,
          style: const TextStyle(color: Colors.white70),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                task.isFavorite ? Icons.favorite : Icons.favorite_border,
                color: task.isFavorite ? Colors.red : Colors.white,
              ),
              onPressed: onFavoriteToggle,
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.white),
              onPressed: onRemoveTask,
            ),
          ],
        ),
      ),
    );
  }
}

class AddTaskPage extends StatefulWidget {
  final Function(Task) onAddTask;

  const AddTaskPage({super.key, required this.onAddTask});

  @override
  _AddTaskPageState createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  String _time = "-";
  String _date = "-";
  String? _selectedCategory;
  String? _selectedImageUrl;
  List<String> _imageUrls = [];
  bool _isLoading = false;

  final Map<String, IconData> _categoryIcons = {
    'Meeting': Icons.group,
    'Call': Icons.phone,
    'Work': Icons.web,
  };

  Future<void> _pickDate() async {
    DateTime? selectedDate = await showDatePicker(
      context: context,
      helpText: 'Select a Date',
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2050),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).colorScheme.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (selectedDate != null) {
      setState(() {
        _date =
            Utils.getFormattedDateSimple(selectedDate.millisecondsSinceEpoch);
      });
    }
  }

  Future<void> _pickTime() async {
    TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).colorScheme.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (selectedTime != null) {
      setState(() {
        _time = "${selectedTime.hour}:${selectedTime.minute}";
      });
    }
  }

  Future<void> _searchImages(String query) async {
    setState(() {
      _isLoading = true;
    });

    final response = await http.get(
      Uri.parse('https://api.pexels.com/v1/search?query=$query'),
      headers: {
        'Authorization': apiKey,
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _imageUrls = List<String>.from(
            data['photos'].map((photo) => photo['src']['medium']));
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
      throw Exception('Failed to load images');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _pickDate,
                    child: const Text('Pick Date'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _pickTime,
                    child: const Text('Pick Time'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Text('Selected Date: $_date'),
                const Spacer(),
                Text('Selected Time: $_time'),
              ],
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Category'),
              items: _categoryIcons.keys.map((String category) {
                return DropdownMenuItem<String>(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value;
                });
              },
              validator: (value) {
                if (value == null) {
                  return 'Please select a category';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search Images',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    _searchImages(_searchController.text);
                  },
                ),
              ),
              onFieldSubmitted: (value) {
                _searchImages(value);
              },
            ),
            const SizedBox(height: 16),
            _isLoading
                ? const SizedBox(
                    height: 200,
                    child: Center(child: CircularProgressIndicator()),
                  )
                : Expanded(
                    child: SizedBox(
                      height: 200,
                      child: GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 4.0,
                          mainAxisSpacing: 4.0,
                        ),
                        itemCount: _imageUrls.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedImageUrl = _imageUrls[index];
                              });
                            },
                            child: Stack(
                              children: [
                                Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    side: BorderSide(
                                      color:
                                          _selectedImageUrl == _imageUrls[index]
                                              ? Colors.blue
                                              : Colors.transparent,
                                      width: 2,
                                    ),
                                  ),
                                  clipBehavior: Clip.antiAlias,
                                  child: Image.network(
                                    _imageUrls[index],
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: double.infinity,
                                    loadingBuilder: (BuildContext context,
                                        Widget child,
                                        ImageChunkEvent? loadingProgress) {
                                      if (loadingProgress == null) {
                                        return child;
                                      } else {
                                        return Center(
                                          child: CircularProgressIndicator(
                                            value: loadingProgress
                                                        .expectedTotalBytes !=
                                                    null
                                                ? loadingProgress
                                                        .cumulativeBytesLoaded /
                                                    (loadingProgress
                                                            .expectedTotalBytes ??
                                                        1)
                                                : null,
                                          ),
                                        );
                                      }
                                    },
                                  ),
                                ),
                                if (_selectedImageUrl == _imageUrls[index])
                                  const Positioned(
                                    top: 8,
                                    right: 8,
                                    child: Icon(
                                      Icons.check_circle,
                                      color: Colors.green,
                                      size: 24,
                                    ),
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate() &&
                    _selectedImageUrl != null) {
                  final newTask = Task(
                    title: _titleController.text,
                    time: '$_date $_time',
                    category: _selectedCategory!,
                    icon: _categoryIcons[_selectedCategory!]!,
                    imageUrl: _selectedImageUrl!,
                  );
                  widget.onAddTask(newTask);
                }
              },
              child: const Text('Add Task'),
            ),
          ],
        ),
      ),
    );
  }
}

class FavoritesPage extends StatelessWidget {
  final List<Task> tasks;

  const FavoritesPage({super.key, required this.tasks});

  @override
  Widget build(BuildContext context) {
    List<Task> favoriteTasks = tasks.where((task) => task.isFavorite).toList();

    return favoriteTasks.isEmpty
        ? const Center(
            child: Text(
              'No favorite tasks available',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          )
        : ListView.builder(
            itemCount: favoriteTasks.length,
            itemBuilder: (context, index) {
              return ListTile(
                leading: Image.network(
                  favoriteTasks[index].imageUrl,
                  fit: BoxFit.cover,
                ),
                title: Text(favoriteTasks[index].title),
                subtitle: Text(favoriteTasks[index].time),
              );
            },
          );
  }
}

// profile page widget
class ProfilePage extends StatelessWidget {
  final String _name = 'Fernando Flores';
  final String _email = 'fernando@itSolutions.com';
  final String _bio = 'Software Developer, Music Lover, Travel Enthusiast';
  final String _imageUrl = 'https://randomuser.me/api/portraits/men/75.jpg';

  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            elevation: 10,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage(_imageUrl),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _email,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _bio,
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const MyHomePage(title: 'My Task')),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 50, vertical: 15),
                    ),
                    child: const Text(
                      'Go to Home',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class Utils {
  static String getFormattedDateSimple(int time) {
    DateFormat newFormat = DateFormat("MMMM dd, yyyy");
    return newFormat.format(DateTime.fromMillisecondsSinceEpoch(time));
  }
}
