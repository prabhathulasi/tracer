import 'package:flutter/material.dart';

class CustomSegmentedControl extends StatefulWidget {
  final List<String> options;
  final int selectedIndex;
  final ValueChanged<int> onPress;

  const CustomSegmentedControl({
    Key? key,
    required this.options,
    required this.selectedIndex,
    required this.onPress,
  }) : super(key: key);

  @override
  _CustomSegmentedControlState createState() => _CustomSegmentedControlState();
}

class _CustomSegmentedControlState extends State<CustomSegmentedControl> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.selectedIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Color(0xffb0edff),
            width: 1.0,
          ),
          left: BorderSide(
            color: Color(0xffb0edff),
            width: 1.0,
          ),
          top: BorderSide(
            color: Color(0xffb0edff),
            width: 1.0,
          ),
        ),
      ),
      child: Row(
        children: widget.options.map((option) {
          int index = widget.options.indexOf(option);
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedIndex = index;
                  widget.onPress(index);
                });
              },
              child: Container(
                height: 30,
                decoration: BoxDecoration(
                  border: Border(
                    right: BorderSide(
                      color: Colors.grey[300]!,
                      width: 1.0,
                    ),
                  ),
                  color: _selectedIndex == index
                      ? Color(0xffb0edff)
                      : Colors.transparent,
                ),
                alignment: Alignment.center,
                child: Text(
                  option,
                  style: TextStyle(
                    color: _selectedIndex == index
                        ? Colors.black
                        : Color(0xffb0edff),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
