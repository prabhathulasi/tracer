import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tracer/data/model/filtermodel.dart';
import 'package:tracer/data/model/locationmodel.dart';

class LocationDialog extends StatefulWidget {
  final List<LocationModel> locData;

  LocationDialog({required this.locData});

  @override
  _LocationDialogState createState() => _LocationDialogState();
}

class _LocationDialogState extends State<LocationDialog> {
  String selectedFilter = "0";
  int _sqlindex = 1;
  void updateSelectedLocation(int index) {
    _showUpdateDialog(index);
    setState(() {
      widget.locData[index].isFav = true;
    });
  }

  void updateUnselectedLocation(int index) {
    setState(() {
      widget.locData[index].isFav = false;
      widget.locData[index].halt_dur = "0";
    });
  }

  void updateHaltDuration(int index, String value) {
    setState(() {
      widget.locData[index].halt_dur = value;
    });
  }

  void _showUpdateDialog(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enter Halt Duration'),
          content: TextField(
            decoration: const InputDecoration(labelText: "Enter halt duration"),
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly
            ],
            onChanged: (value) {
              updateHaltDuration(index, value);
            },
          ),
          actions: <Widget>[
            ElevatedButton(
              child: const Text('Save'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
        data: Theme.of(context)
            .copyWith(dialogBackgroundColor: const Color(0xff105064)),
        child: AlertDialog(
          content: Container(
            width: double.minPositive,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: widget.locData.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  title: Text(
                    widget.locData[index].loc.toString(),
                    style: const TextStyle(
                        fontFamily: 'RRegular',
                        fontSize: 16,
                        color: Color(0xffbcc0cb)),
                  ),
                  trailing: StatefulBuilder(
                    builder: (BuildContext context, StateSetter setState) {
                      return Icon(
                        widget.locData[index].isFav
                            ? Icons.check_box_rounded
                            : Icons.check_box_outline_blank_outlined,
                        color: widget.locData[index].isFav
                            ? Colors.green
                            : Color(0xffb0edff),
                      );
                    },
                  ),
                  onTap: () {
                    if (widget.locData[index].isFav) {
                      updateUnselectedLocation(index);
                    } else {
                      updateSelectedLocation(index);
                    }
                  },
                );
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(widget.locData);
              },
              child: const Text("Cancel",
                  style: const TextStyle(color: Color(0xffb0edff))),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(widget.locData);
              },
              child: const Text("Save",
                  style: const TextStyle(color: Color(0xffb0edff))),
            ),
          ],
        ));
  }
}
