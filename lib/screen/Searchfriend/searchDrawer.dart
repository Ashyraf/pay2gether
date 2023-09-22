import 'package:flutter/material.dart';

class SearchDrawer extends StatefulWidget {
  const SearchDrawer({
    Key? key,
    required this.usernameController,
    required this.usernames,
    required this.onUsernameChanged,
    required this.onFriendRequest,
    required this.currentUserID,
  }) : super(key: key);

  final TextEditingController usernameController;
  final List<String> usernames;
  final Function(String) onUsernameChanged;
  final Function(String) onFriendRequest;
  final String currentUserID;

  @override
  State<SearchDrawer> createState() => _SearchDrawerState();
}

class _SearchDrawerState extends State<SearchDrawer> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 80),
      child: Column(
        children: [
          TextField(
            controller: widget.usernameController,
            onChanged: widget.onUsernameChanged,
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide.none,
              ),
              hintText: "Insert your friend's username",
              prefixIcon: Icon(Icons.search),
              prefixIconColor: Colors.black,
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            itemCount: widget.usernames.length,
            itemBuilder: (context, index) {
              final username = widget.usernames[index];
              return Card(
                child: ListTile(
                  title: Text(username),
                  trailing: ElevatedButton(
                    onPressed: () => widget.onFriendRequest(username),
                    child: Text('Request'),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
