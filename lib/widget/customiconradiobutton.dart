import 'package:flutter/material.dart';

class CustomIconRadioButton extends StatefulWidget {
  final IconData iconData;
  final Color selectedColor;
  final Color unselectedColor;
  final bool isSelected;
  final VoidCallback onTap;

  CustomIconRadioButton(
      {required this.iconData,
      required this.selectedColor,
      required this.unselectedColor,
      required this.isSelected,
      required this.onTap});

  @override
  _CustomIconRadioButtonState createState() => _CustomIconRadioButtonState();
}

class _CustomIconRadioButtonState extends State<CustomIconRadioButton> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        width: 70.0,
        height: 70.0,
        decoration: BoxDecoration(
          border: Border.all(width: 0.0, color: Colors.black),
          borderRadius: BorderRadius.circular(50.0),
          color:
              widget.isSelected ? widget.selectedColor : widget.unselectedColor,
        ),
        child: Icon(
          widget.iconData,
          color: widget.isSelected
              ? const Color(0xffaeeeff)
              : Color.fromARGB(255, 101, 129, 135),
          size: 30.0,
        ),
      ),
    );
  }
}
