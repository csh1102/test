import 'package:flutter/material.dart';

///
///This page hold several auxiliar methods used throught the app
///////////////////////////////////////////////////////////////

///
///This method (or function) is used for the goToPage function
///
Route pageTransition(Widget pageToGo) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => pageToGo,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(1, 0);
      const end = Offset.zero;
      const curve = Curves.easeInOutCirc;
      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
  );
}

///
///Pushes a new page into the navigator stack with the animation defined in the pageTransition function
///[context] is the build context
///[pageToGo] the widget that represents the page we want to go
///
void goToPage(BuildContext context, Widget pageToGo) {
  Navigator.push(context, pageTransition(pageToGo));
}

///
///Function to encode a DateTime objet into a Map
///
Map dateToFirebase(DateTime date) {
  return {
    'Day': date.day,
    'Month': date.month,
    'Year': date.year,
  };
}

///
///Function to decode a map into a DateTime object
///
DateTime dateFromFirebase(Map<String, dynamic> encoded) {
  var day = encoded['Day'];
  var month = encoded['Month'];
  var year = encoded['Year'];
  DateTime dateTime = DateTime(year, month, day);

  return dateTime;
}
