import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CreateRoom extends StatefulWidget {
  const CreateRoom({super.key});

  @override
  State<CreateRoom> createState() => _CreateRoomState();
}

class _CreateRoomState extends State<CreateRoom> {
  final roomNameController = TextEditingController();
  String? selectedCategory; // New variable to store the selected category

  // Initialize selectedFriends list
  List<Map<String, dynamic>> selectedFriends = [];

  // Function to add friend with debt to selectedFriends
  void addFriendWithDebt(Map<String, dynamic> friend) {
    friend['status'] = 'pending';
    selectedFriends.add(friend);
  }

  // Calculate total debt
  double calculateTotalDebt() {
    return selectedFriends.fold(
        0.0, (sum, friend) => sum + friend['debtAmount']);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Create a Room'),
      content: StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return RefreshIndicator(
            onRefresh: () {
              return Future.delayed(Duration(seconds: 1), () {
                setState(() {
                  selectedFriends.clear(); // Clear selectedFriends list
                  roomNameController.clear(); // Clear room name
                });
              });
            },
            child: SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Room name',
                    ),
                    controller: roomNameController,
                  ),
                  SizedBox(height: 16),
                  DropdownButtonFormField(
                    value: selectedCategory,
                    onChanged: (newValue) {
                      setState(() {
                        selectedCategory = newValue as String?;
                      });
                    },
                    items: [
                      DropdownMenuItem(
                        value: 'Movie',
                        child: Text('Movie'),
                      ),
                      DropdownMenuItem(
                        value: 'Leisure',
                        child: Text('Leisure'),
                      ),
                      DropdownMenuItem(
                        value: 'Food',
                        child: Text('Food'),
                      ),
                      DropdownMenuItem(
                        value: 'Utilities',
                        child: Text('Utilities'),
                      ),
                      DropdownMenuItem(
                        value: 'House Rent',
                        child: Text('House Rent'),
                      ),
                      DropdownMenuItem(
                        value: 'Vacation',
                        child: Text('Vacation'),
                      ),
                      DropdownMenuItem(
                        value: 'Hobbies',
                        child: Text('Hobbies'),
                      ),
                    ],
                    decoration: InputDecoration(
                      labelText: 'Category',
                    ),
                  ),
                  SizedBox(height: 16),
                  AddPeopleForm(
                    selectedFriends: selectedFriends,
                    addFriendWithDebt: addFriendWithDebt,
                    calculateTotalDebt: calculateTotalDebt,
                  ),
                ],
              ),
            ),
          );
        },
      ),
      actions: [
        ElevatedButton(
          onPressed: () {
            final roomName = roomNameController.text.trim();
            final currentUser = FirebaseAuth.instance.currentUser;
            final currentUsername = currentUser?.displayName;

            FirebaseFirestore.instance
                .collection('debtRoom')
                .doc(roomName)
                .set({
              'roomName': roomName,
              'roomMaster': currentUsername,
              'selectedFriends': selectedFriends.map((friend) {
                return {
                  'friendName': friend['friendName'],
                  'debtAmount': friend['debtAmount'],
                  'debtDetails': friend['debtDetails'], // Include debt details
                  'status': 'pending',
                };
              }).toList(),
              'totalDebt': calculateTotalDebt(),
              'category': selectedCategory,
              // Add other relevant data as needed
            }).then((value) {
              // Success
              print('Room created successfully!');
            }).catchError((error) {
              // Error
              print('Failed to create room: $error');
            });

            Navigator.pop(context);
          },
          child: Text('Create'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text('Cancel'),
        ),
      ],
    );
  }
}

class AddPeopleForm extends StatefulWidget {
  final List<Map<String, dynamic>> selectedFriends;
  final Function addFriendWithDebt;
  final Function calculateTotalDebt;

  const AddPeopleForm({
    Key? key,
    required this.selectedFriends,
    required this.addFriendWithDebt,
    required this.calculateTotalDebt,
  }) : super(key: key);

  @override
  _AddPeopleFormState createState() => _AddPeopleFormState();
}

class _AddPeopleFormState extends State<AddPeopleForm> {
  final _friendNameController = TextEditingController();
  final _itemController = TextEditingController();
  final _itemCostController = TextEditingController();

  List<Map<String, dynamic>> debtDetails = [];
  String? selectedFriendName;
  List<String> friendNames = [];

  @override
  void initState() {
    super.initState();
    fetchFriendNames();
  }

  Future<void> fetchFriendNames() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    final currentUsername = currentUser?.displayName;

    final docSnapshot = await FirebaseFirestore.instance
        .collection('friends')
        .doc(currentUsername)
        .get();

    final friendList = docSnapshot.data()?['friendLists'];

    setState(() {
      friendNames = friendList != null
          ? (friendList as List<dynamic>)
              .map((item) => item['friendName'].toString())
              .toList()
          : [];
    });

    if (friendNames.isNotEmpty) {
      setState(() {
        selectedFriendName =
            friendNames[0]; // Set the initial selected friend name
      });
    }
  }

  void addDebtDetail() {
    final item = _itemController.text.trim();
    final itemCost = double.tryParse(_itemCostController.text) ?? 0.0;

    if (item.isNotEmpty && itemCost > 0) {
      final debtDetail = {
        'item': item,
        'itemCost': itemCost,
      };

      setState(() {
        debtDetails.add(debtDetail);
      });

      // Clear the text fields
      _itemController.clear();
      _itemCostController.clear();
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Please enter a valid item and item cost.'),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DropdownButtonFormField(
          value: selectedFriendName,
          onChanged: (newValue) {
            setState(() {
              selectedFriendName = newValue as String?;
            });
          },
          items: friendNames.map((friendName) {
            return DropdownMenuItem(
              value: friendName,
              child: Text(friendName),
            );
          }).toList(),
          decoration: InputDecoration(
            labelText: 'Select a Friend',
          ),
        ),
        SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          itemCount: debtDetails.length,
          itemBuilder: (BuildContext context, int index) {
            final debtDetail = debtDetails[index];
            return ListTile(
              title: Text(debtDetail['item']),
              subtitle: Text(
                  'Item Cost: \$${debtDetail['itemCost'].toStringAsFixed(2)}'),
            );
          },
        ),
        Row(
          children: [
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Item',
                ),
                controller: _itemController,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Item Cost',
                ),
                controller: _itemCostController,
                keyboardType: TextInputType.number,
              ),
            ),
            IconButton(
              onPressed: addDebtDetail,
              icon: Icon(Icons.add),
            ),
          ],
        ),
        SizedBox(height: 16),
        ElevatedButton(
          onPressed: () {
            final friendName = selectedFriendName;

            if (friendName!.isNotEmpty && debtDetails.isNotEmpty) {
              final friend = {
                'friendName': friendName,
                'debtAmount': debtDetails.fold(
                    0.0, (sum, detail) => sum + detail['itemCost']),
                'debtDetails': debtDetails,
              };

              // Call the addFriendWithDebt function from the parent widget
              widget.addFriendWithDebt(friend);

              // Clear the text fields and debt details
              _friendNameController.clear();
              _itemController.clear();
              _itemCostController.clear();
              setState(() {
                debtDetails = [];
              });
            } else {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Error'),
                    content: Text(
                        'Please enter a valid friend name and debt details.'),
                    actions: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text('OK'),
                      ),
                    ],
                  );
                },
              );
            }
          },
          child: Text('Add Friend'),
        ),
        SizedBox(height: 16),
        Text(
          'Total Debt: \$${widget.calculateTotalDebt().toStringAsFixed(2)}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          itemCount: widget.selectedFriends.length,
          itemBuilder: (BuildContext context, int index) {
            final friend = widget.selectedFriends[index];
            return ListTile(
              title: Text(friend['friendName']),
              subtitle: Text(
                  'Debt Amount: \$${friend['debtAmount'].toStringAsFixed(2)}'),
              trailing: Text('Status: ${friend['status']}'),
            );
          },
        ),
      ],
    );
  }
}
