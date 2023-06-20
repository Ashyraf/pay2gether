import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManageReportDialog extends StatefulWidget {
  final String friendName;
  final Map<String, dynamic> roomData;

  const ManageReportDialog({required this.friendName, required this.roomData});

  @override
  _ManageReportDialogState createState() => _ManageReportDialogState();
}

class _ManageReportDialogState extends State<ManageReportDialog> {
  double debtAmount = 0.0;
  final CollectionReference _debtRoomCollection =
      FirebaseFirestore.instance.collection('debtRoom');

  @override
  void initState() {
    super.initState();
    final selectedFriends = widget.roomData['selectedFriends'] as List<dynamic>;

    for (final friend in selectedFriends) {
      if (friend['friendName'] == widget.friendName) {
        debtAmount = friend['debtAmount'] ?? 0.0;
        break;
      }
    }
  }

  void _updateDebtAmount() async {
    final selectedFriends = widget.roomData['selectedFriends'] as List<dynamic>;
    final reports = widget.roomData['reports'] as List<dynamic>?;

    for (final friend in selectedFriends) {
      if (friend['friendName'] == widget.friendName) {
        friend['debtAmount'] = debtAmount;
        break;
      }
    }

    // Remove the corresponding report from reports document
    if (reports != null) {
      reports
          .removeWhere((report) => report['reporterName'] == widget.friendName);
    }

    // Update the debt amount and reports in Firebase
    final debtRoomRef = _debtRoomCollection.doc(widget.roomData['roomName']);
    await debtRoomRef.update({
      'selectedFriends': selectedFriends,
      'reports': reports,
    });

    Navigator.pop(context);
  }

  void _removeUser() async {
    final selectedFriends = widget.roomData['selectedFriends'] as List<dynamic>;
    final reports = widget.roomData['reports'] as List<dynamic>?;

    selectedFriends
        .removeWhere((friend) => friend['friendName'] == widget.friendName);

    // Remove the reports document of the user
    if (reports != null) {
      reports
          .removeWhere((report) => report['reporterName'] == widget.friendName);
    }

    // Update the selected friends list and reports in Firebase
    final debtRoomRef = _debtRoomCollection.doc(widget.roomData['roomName']);
    await debtRoomRef.update({
      'selectedFriends': selectedFriends,
      'reports': reports,
    });

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final reports = widget.roomData['reports'] as List<dynamic>?;

    final filteredReports = reports?.where((report) {
      final reporterName = report['reporterName'];
      return reporterName == widget.friendName;
    }).toList();

    return AlertDialog(
      title: Text('Reports for ${widget.friendName}'),
      content: filteredReports != null && filteredReports.isNotEmpty
          ? ListView.builder(
              itemCount: filteredReports.length,
              itemBuilder: (context, index) {
                final report = filteredReports[index];
                final reporterName = report['reporterName'];
                final reason = report['reason'];
                final optionalReason = report['optionalReason'];

                return ListTile(
                  title: Text('Reporter: $reporterName'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Reason: $reason'),
                      Text('Optional Reason: $optionalReason'),
                    ],
                  ),
                );
              },
            )
          : Text('No reports found.'),
      actions: [
        ElevatedButton(
          child: Text('Edit Debt'),
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: Text('Edit Debt Amount'),
                  content: TextField(
                    decoration: InputDecoration(hintText: 'Debt Amount'),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      setState(() {
                        debtAmount = double.tryParse(value) ?? 0.0;
                      });
                    },
                  ),
                  actions: [
                    ElevatedButton(
                      child: Text('Save Change'),
                      onPressed: () {
                        _updateDebtAmount();
                      },
                      style: ElevatedButton.styleFrom(
                        primary: Colors.green,
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
        ElevatedButton(
          child: Text('Remove User'),
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: Text('Confirm Removal'),
                  content: Text('Are you sure you want to remove this user?'),
                  actions: [
                    ElevatedButton(
                      child: Text('Cancel'),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    ElevatedButton(
                      child: Text('Remove'),
                      onPressed: () {
                        _removeUser();
                      },
                      style: ElevatedButton.styleFrom(
                        primary: Colors.red,
                      ),
                    ),
                  ],
                );
              },
            );
          },
          style: ElevatedButton.styleFrom(
            primary: Colors.red,
          ),
        ),
      ],
    );
  }
}
