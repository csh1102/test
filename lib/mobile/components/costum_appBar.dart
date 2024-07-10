import 'package:amplify/mobile/pages/Profile.dart';
import 'package:amplify/mobile/pages/settings.dart';
import 'package:amplify/models/user_model.dart';
import 'package:amplify/services/firebase_users.dart';
import 'package:amplify/services/helpers.dart';
import 'package:amplify/services/media_query_helpers.dart';
import 'package:flutter/material.dart';

AppBar costumAppBar(
  BuildContext context,
) {
  return AppBar(
    title: Image.asset("assets/images/logo.png"),
    titleSpacing: 0,
    bottom: PreferredSize(
      preferredSize: const Size.fromHeight(0.0),
      child: Container(
        color: Theme.of(context)
            .colorScheme
            .primary
            .withOpacity(0.2), // choose your desired color
        height: 1.5, // choose your desired height
      ),
    ),
    actions: [
      FutureBuilder<UserData?>(
        future: FirebaseUsers().getUserData(FirebaseUsers().currentUserUID),
        builder: (BuildContext context, AsyncSnapshot<UserData?> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SizedBox();
          } else if (snapshot.hasError) {
            return const Text('Error');
          } else {
            final currentUserData = snapshot.data;
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 10, 0),
              child: GestureDetector(
                onTap: () {
                  goToPage(context, Profile());
                },
                child: Row(
                  children: [
                    FutureBuilder<String?>(
                      future: FirebaseUsers()
                          .getProfileImageURL(FirebaseUsers().currentUserUID),
                      builder: (BuildContext context,
                          AsyncSnapshot<String?> snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const SizedBox();
                        } else {
                          final imageUrl = snapshot.data;
                          return CircleAvatar(
                            radius: 18,
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
                            backgroundImage: imageUrl != null
                                ? Image.network(imageUrl).image
                                : Image.network(
                                    "https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png",
                                  ).image,
                          );
                        }
                      },
                    ),
                    SizedBox(
                      width: displayWidth(context) * 0.02,
                    ),
                    currentUserData == null
                        ? const SizedBox()
                        : Text(
                            "${currentUserData.firstName} ${currentUserData.lastName}",
                          ),
                  ],
                ),
              ),
            );
          }
        },
      ),
      IconButton(
          onPressed: () {
            goToPage(context, SettingsPage());
          },
          icon: Icon(
            Icons.settings_rounded,
            size: 30,
            color: Theme.of(context).colorScheme.primary,
          ))
    ],
  );
}
