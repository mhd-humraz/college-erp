import 'package:flutter/material.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() =>
      _UserManagementScreenState();
}

class _UserManagementScreenState
    extends State<UserManagementScreen> {
  final TextEditingController _searchController =
      TextEditingController();

  String selectedRole = "All";

  final List<String> roles = [
    "All",
    "Admin",
    "HOD",
    "Teacher",
    "Student",
  ];

  final List<Map<String, dynamic>> users = [
    {
      "name": "Muhammed Humraz",
      "email": "humraz@edusphere.edu",
      "role": "Student",
      "status": "Active",
    },
    {
      "name": "Rajina",
      "email": "teacher1@edusphere.edu",
      "role": "Teacher",
      "status": "Active",
    },
    {
      "name": "Nisha",
      "email": "hod@edusphere.edu",
      "role": "HOD",
      "status": "Blocked",
    },
    {
      "name": "Admin",
      "email": "admin@edusphere.edu",
      "role": "Admin",
      "status": "Active",
    },
  ];

  void _showUserDetails(Map<String, dynamic> user) {
    final bool active = user["status"] == "Active";

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor:
                    Colors.redAccent.withOpacity(.15),
                child: Text(
                  user["name"][0],
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.redAccent,
                  ),
                ),
              ),
              const SizedBox(height: 15),
              Text(
                user["name"],
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                user["email"],
                style: const TextStyle(
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 20),
              _infoTile(
                Icons.badge_outlined,
                "Role",
                user["role"],
              ),
              _infoTile(
                Icons.account_tree_outlined,
                "Department",
                "Computer Applications",
              ),
              _infoTile(
                Icons.phone_outlined,
                "Phone",
                "+91 9876543210",
              ),
              _infoTile(
                active
                    ? Icons.check_circle
                    : Icons.block,
                "Status",
                user["status"],
              ),
              const SizedBox(height: 25),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.edit),
                      label: const Text("Edit"),
                      onPressed: () {
                        Navigator.pop(context);

                        ScaffoldMessenger.of(context)
                            .showSnackBar(
                          const SnackBar(
                            content: Text(
                              "Edit User - Coming Soon",
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      style:
                          ElevatedButton.styleFrom(
                        backgroundColor: active
                            ? Colors.red
                            : Colors.green,
                        foregroundColor:
                            Colors.white,
                      ),
                      icon: Icon(
                        active
                            ? Icons.block
                            : Icons.check,
                      ),
                      label: Text(
                        active
                            ? "Block"
                            : "Unblock",
                      ),
                      onPressed: () {
                        Navigator.pop(context);

                        setState(() {
                          user["status"] =
                              active
                                  ? "Blocked"
                                  : "Active";
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  icon:
                      const Icon(Icons.lock_reset),
                  label: const Text(
                    "Reset Password",
                  ),
                  onPressed: () {
                    Navigator.pop(context);

                    ScaffoldMessenger.of(context)
                        .showSnackBar(
                      SnackBar(
                        content: Text(
                          "Password reset for ${user["name"]}",
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _infoTile(
    IconData icon,
    String title,
    String value,
  ) {
    return ListTile(
      leading: Icon(
        icon,
        color: Colors.redAccent,
      ),
      title: Text(title),
      subtitle: Text(value),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredUsers = users.where((user) {
      final matchesSearch = user["name"]
          .toLowerCase()
          .contains(
            _searchController.text.toLowerCase(),
          );

      final matchesRole =
          selectedRole == "All" ||
              user["role"] == selectedRole;

      return matchesSearch &&
          matchesRole;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "User Management",
        ),
        backgroundColor:
            Colors.redAccent,
        foregroundColor: Colors.white,
      ),
      floatingActionButton:
          FloatingActionButton(
        backgroundColor:
            Colors.redAccent,
        child:
            const Icon(Icons.person_add),
        onPressed: () {
          ScaffoldMessenger.of(context)
              .showSnackBar(
            const SnackBar(
              content: Text(
                "Add User - Coming Soon",
              ),
            ),
          );
        },
      ),
      body: Padding(
        padding:
            const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller:
                  _searchController,
              decoration:
                  InputDecoration(
                hintText:
                    "Search User",
                prefixIcon:
                    const Icon(
                        Icons.search),
                border:
                    OutlineInputBorder(
                  borderRadius:
                      BorderRadius
                          .circular(
                              12),
                ),
              ),
              onChanged: (_) {
                setState(() {});
              },
            ),
            const SizedBox(height: 15),
            DropdownButtonFormField(
              value: selectedRole,
              decoration:
                  InputDecoration(
                border:
                    OutlineInputBorder(
                  borderRadius:
                      BorderRadius
                          .circular(
                              12),
                ),
              ),
              items:
                  roles.map((role) {
                return DropdownMenuItem(
                  value: role,
                  child: Text(role),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedRole =
                      value.toString();
                });
              },
            ),
            const SizedBox(height: 20),
            Expanded(
              child:
                  ListView.builder(
                itemCount:
                    filteredUsers.length,
                itemBuilder:
                    (_, index) {
                  final user =
                      filteredUsers[
                          index];

                  return Card(
                    margin:
                        const EdgeInsets.only(
                            bottom:
                                12),
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(
                              15),
                    ),
                    child: ListTile(
                      leading:
                          CircleAvatar(
                        backgroundColor:
                            Colors.redAccent
                                .withOpacity(
                                    .15),
                        child: Text(
                          user["name"]
                              [0],
                          style:
                              const TextStyle(
                            color:
                                Colors.redAccent,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(
                        user["name"],
                        style:
                            const TextStyle(
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                      subtitle:
                          Column(
                        crossAxisAlignment:
                            CrossAxisAlignment
                                .start,
                        children: [
                          Text(
                            user["email"],
                          ),
                          Text(
                            user["role"],
                            style:
                                const TextStyle(
                              color:
                                  Colors.blue,
                            ),
                          ),
                        ],
                      ),
                      trailing:
                          Container(
                        padding:
                            const EdgeInsets.symmetric(
                          horizontal:
                              10,
                          vertical: 6,
                        ),
                        decoration:
                            BoxDecoration(
                          color: user[
                                      "status"] ==
                                  "Active"
                              ? Colors
                                  .green
                                  .withOpacity(
                                      .15)
                              : Colors
                                  .red
                                  .withOpacity(
                                      .15),
                          borderRadius:
                              BorderRadius.circular(
                                  20),
                        ),
                        child: Text(
                          user["status"],
                          style:
                              TextStyle(
                            color: user[
                                        "status"] ==
                                    "Active"
                                ? Colors
                                    .green
                                : Colors
                                    .red,
                            fontWeight:
                                FontWeight
                                    .bold,
                          ),
                        ),
                      ),
                      onTap: () {
                        _showUserDetails(
                            user);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}