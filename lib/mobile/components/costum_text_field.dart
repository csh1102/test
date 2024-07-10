import 'package:amplify/services/media_query_helpers.dart';
import 'package:flutter/material.dart';

///
///TextFields used in login page and register page
///
///
// ignore: must_be_immutable
class CostumTextField extends StatefulWidget {
  final TextEditingController textController;
  final String hintText;
  final bool isPassword;
  bool showText;
  CostumTextField({
    required this.textController,
    required this.hintText,
    required this.isPassword,
  }) : showText = isPassword;

  @override
  State<CostumTextField> createState() => _CostumTextField();
}

class _CostumTextField extends State<CostumTextField> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: displayHeight(context) * 0.074,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.tertiary,
        borderRadius: const BorderRadius.all(Radius.circular(30)),
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, 0),
            blurRadius: 8.0,
            spreadRadius: 0.5,
            color: const Color.fromARGB(255, 59, 59, 59).withOpacity(0.2),
          ),
        ],
      ),
      child: TextField(
        controller: widget.textController,
        obscureText: widget.showText,
        style: TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: Theme.of(context).colorScheme.primary,
        ),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.all(20),
          hintText: widget.hintText,
          hintStyle: const TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Color.fromARGB(255, 178, 178, 178)),
          suffixIcon: widget.isPassword
              ? IconButton(
                  onPressed: () {
                    setState(() {
                      widget.showText = !widget.showText;
                    });
                  },
                  icon: const Icon(
                    Icons.remove_red_eye_rounded,
                    size: 19,
                  ),
                  splashRadius: 1.0,
                )
              : null,
          border: InputBorder.none,
        ),
      ),
    );
  }
}
