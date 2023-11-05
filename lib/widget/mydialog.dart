import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tracer/data/model/filtermodel.dart';

class MyDialog extends StatefulWidget {
  final List<FilterModel> filterData;
  String titleStr;

  MyDialog({required this.filterData, required this.titleStr});

  @override
  _MyDialogState createState() => _MyDialogState();
}

class _MyDialogState extends State<MyDialog> {
  String selectedFilter = "0";
  void updateDriverType(int index) {
    setState(() {
      widget.filterData[index].isFav = true;
      selectedFilter = widget.filterData[index].id.toString();
    });
  }

  void updateAllDriverType(bool allSaved) {
    setState(() {
      for (int i = 0; i < widget.filterData.length; i++) {
        widget.filterData[i].isFav = allSaved;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
        data: Theme.of(context)
            .copyWith(dialogBackgroundColor: const Color(0xff105064)),
        child: AlertDialog(
          title: Text(widget.titleStr),
          titleTextStyle: TextStyle(color: Color(0xffffffff)),
          content: Container(
            width: double.minPositive,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: widget.filterData.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  title: Text(widget.filterData[index].name.toString(),
                      style: const TextStyle(
                          fontFamily: 'RRegular',
                          fontSize: 16,
                          color: Color(0xffbcc0cb))),
                  trailing: StatefulBuilder(
                    builder: (BuildContext context, StateSetter setState) {
                      return Icon(
                        widget.filterData[index].isFav!
                            ? Icons.check_box_rounded
                            : Icons.check_box_outline_blank_outlined,
                        color: widget.filterData[index].isFav!
                            ? Colors.green
                            : Color(0xffb0edff),
                      );
                    },
                  ),
                  onTap: () {
                    updateAllDriverType(false);
                    updateDriverType(index);
                  },
                );
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                selectedFilter = "0";
                Navigator.of(context).pop(selectedFilter);
              },
              child: const Text("Cancel",
                  style: const TextStyle(color: Color(0xffb0edff))),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(selectedFilter);
              },
              child: const Text("Save",
                  style: const TextStyle(color: Color(0xffb0edff))),
            ),
          ],
        ));
  }
}
