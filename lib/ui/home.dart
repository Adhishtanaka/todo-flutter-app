import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo_app/model/Todo.dart';
import 'package:todo_app/service/todoService.dart';
import 'package:todo_app/ui/component/UserProfileButton.dart';
import 'package:todo_app/ui/component/AddTodoForm.dart';
import 'package:todo_app/ui/component/TodoItemWidget.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  bool _isAuthenticated = false;
  List<Todo> todos = [];
  List<Todo> filteredTodos = [];
  bool isLoading = true;
  String searchTerm = '';
  DateTime? dateFilter;
  bool isAddTodoOpen = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkAuth();
    dateFilter = null;
    fetchTodos();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> fetchTodos() async {
    setState(() {
      isLoading = true;
    });

    final fetchedTodos = await TodoService.fetchTodos();

    setState(() {
      todos = fetchedTodos;
      isLoading = false;
    });

    filterTodos();
  }

  Future<void> _checkAuth() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    setState(() {
      _isAuthenticated = token != null;
    });

    if (!_isAuthenticated) {
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed('/signin');
    }
  }

  void filterTodos() {
    List<Todo> filtered = List.from(todos);

    if (searchTerm.isNotEmpty) {
      final term = searchTerm.toLowerCase();
      filtered =
          filtered.where((todo) {
            return todo.title.toLowerCase().contains(term) ||
                (todo.description?.toLowerCase().contains(term) ?? false);
          }).toList();
    }

    if (dateFilter != null) {
      filtered =
          filtered.where((todo) {
            if (todo.createdAt == null) return false;
            return _isSameDay(todo.createdAt!, dateFilter!);
          }).toList();
    }

    setState(() {
      filteredTodos = filtered;
    });
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  Future<void> addTodo(
      String title,
      String? description,
      DateTime? deadline,
      ) async {
    final newTodo = await TodoService.addTodo(title, description, deadline);
    if (newTodo != null) {
      setState(() {
        todos.add(newTodo);
        isAddTodoOpen = false;
        filterTodos();
      });
     await fetchTodos();
    }
  }

  Future<void> toggleTodo(String id, bool completed) async {
    final success = await TodoService.toggleTodo(id, completed);
    if (success) {
      setState(() {
        final index = todos.indexWhere((todo) => todo.id == id);
        if (index != -1) {
          todos[index].completed = completed;
        }
      });
      filterTodos();
    }
  }

  Future<void> deleteTodo(String id) async {
    final success = await TodoService.deleteTodo(id);
    if (success) {
      setState(() {
        todos.removeWhere((todo) => todo.id == id);
      });
      filterTodos();
    }
  }

  void clearFilters() {
    setState(() {
      searchTerm = '';
      dateFilter = null;
      _searchController.clear();
    });
    filterTodos();
  }

  void _showDatePicker() async {
    final now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: dateFilter ?? now,
      firstDate: DateTime(2020),
      lastDate: DateTime(now.year + 1, 12, 31),
    );

    if (picked != null) {
      setState(() {
        dateFilter = picked;
      });
      filterTodos();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF0A0A0A),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        title: const Text(
          'Todo List',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        actions: [
          // Filter button
          if (dateFilter != null)
            IconButton(
              icon: const Icon(Icons.filter_list_off, size: 22),
              tooltip: 'Clear date filter',
              onPressed: () {
                setState(() {
                  dateFilter = null;
                });
                filterTodos();
              },
            ),
          // Date picker button

          // Profile button
          UserProfileButton()
        ],
      ),
      body: RefreshIndicator(
        onRefresh: fetchTodos,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Search bar
                      // Search bar
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4.0,
                          vertical: 8.0,
                        ),
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade800.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: Colors.grey.shade800,
                              width: 0.5,
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _searchController,
                                  onChanged: (value) {
                                    setState(() {
                                      searchTerm = value;
                                    });
                                    filterTodos();
                                  },
                                  style: const TextStyle(fontSize: 14),
                                  decoration: InputDecoration(
                                    hintText: 'Search tasks...',
                                    hintStyle: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade400,
                                    ),
                                    prefixIcon: const Icon(
                                      Icons.search,
                                      size: 20,
                                    ),
                                    suffixIcon:
                                        searchTerm.isNotEmpty
                                            ? IconButton(
                                              icon: const Icon(
                                                Icons.clear,
                                                size: 18,
                                              ),
                                              onPressed: () {
                                                setState(() {
                                                  searchTerm = '';
                                                  _searchController.clear();
                                                });
                                                filterTodos();
                                              },
                                            )
                                            : null,
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(
                                      vertical: 10,
                                    ),
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.calendar_today,
                                  size: 22,
                                  color:
                                      dateFilter != null
                                          ? Theme.of(
                                            context,
                                          ).colorScheme.primary
                                          : null,
                                ),
                                tooltip:
                                    dateFilter != null
                                        ? 'Filter: ${DateFormat('MM/dd').format(dateFilter!)}'
                                        : 'Filter by date',
                                onPressed: _showDatePicker,
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Add Todo Button
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4.0,
                          vertical: 8.0,
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                isAddTodoOpen = !isAddTodoOpen;
                              });
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade800.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.grey.shade700,
                                  width: 0.5,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.add_circle_outline,
                                    size: 20,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                  const SizedBox(width: 12),
                                  const Text(
                                    'Add New Task',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const Spacer(),
                                  Icon(
                                    isAddTodoOpen
                                        ? Icons.keyboard_arrow_up
                                        : Icons.keyboard_arrow_down,
                                    size: 20,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Add Todo Form
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        height: isAddTodoOpen ? null : 0,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: Card(
                            color: Theme.of(context).colorScheme.surface,
                            elevation: 2,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: AddTodoForm(onAdd: addTodo),
                            ),
                          ),
                        ),
                      ),

                      // Tasks header
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 8.0,
                          right: 8.0,
                          top: 16.0,
                          bottom: 8.0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.task_alt, size: 16),
                                const SizedBox(width: 8),
                                const Text(
                                  'Your Tasks',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade800.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${filteredTodos.length}',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey.shade300,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Filter chips
                      if (searchTerm.isNotEmpty || dateFilter != null)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8.0,
                            vertical: 4.0,
                          ),
                          child: Wrap(
                            spacing: 8,
                            children: [
                              if (searchTerm.isNotEmpty)
                                Chip(
                                  label: Text(
                                    '"$searchTerm"',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  deleteIcon: const Icon(Icons.close, size: 16),
                                  onDeleted: () {
                                    setState(() {
                                      searchTerm = '';
                                      _searchController.clear();
                                    });
                                    filterTodos();
                                  },
                                  backgroundColor:
                                      Theme.of(context).colorScheme.surface,
                                  padding: const EdgeInsets.all(0),
                                  visualDensity: VisualDensity.compact,
                                ),
                              if (dateFilter != null)
                                Chip(
                                  label: Text(
                                    DateFormat(
                                      'MM/dd/yyyy',
                                    ).format(dateFilter!),
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  deleteIcon: const Icon(Icons.close, size: 16),
                                  onDeleted: () {
                                    setState(() {
                                      dateFilter = null;
                                    });
                                    filterTodos();
                                  },
                                  backgroundColor:
                                      Theme.of(context).colorScheme.surface,
                                  padding: const EdgeInsets.all(0),
                                  visualDensity: VisualDensity.compact,
                                ),
                            ],
                          ),
                        ),

                      // Task list
                      if (filteredTodos.isEmpty)
                        Container(
                          width: double.infinity,
                          margin: const EdgeInsets.all(8.0),
                          padding: const EdgeInsets.all(24.0),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade800.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.grey.shade800,
                              width: 0.5,
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                todos.isEmpty
                                    ? Icons.assignment
                                    : Icons.search_off,
                                size: 48,
                                color: Colors.grey.shade600,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                todos.isEmpty
                                    ? 'No tasks yet. Add one above!'
                                    : 'No matching tasks found.',
                                style: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontSize: 14,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        )
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: filteredTodos.length,
                          separatorBuilder:
                              (context, index) => const SizedBox(height: 8),
                          padding: const EdgeInsets.all(8.0),
                          itemBuilder: (context, index) {
                            final todo = filteredTodos[index];
                            return TodoItemWidget(
                              todo: todo,
                              onToggle: toggleTodo,
                              onDelete: deleteTodo,
                            );
                          },
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
