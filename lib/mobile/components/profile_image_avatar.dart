import 'package:amplify/services/firebase_users.dart';
import 'package:flutter/material.dart';

///
///This is used for every profile image avatar that is not the current users
///
class ProfileImageAvatar extends StatefulWidget {
  String userUID;
  double radius;
  ProfileImageAvatar({Key? key, required this.userUID, required this.radius})
      : super(key: key);

  @override
  State<ProfileImageAvatar> createState() => _ProfileImageAvatarState();
}

class _ProfileImageAvatarState extends State<ProfileImageAvatar> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: FirebaseUsers().getProfileImageURL(widget.userUID),
      builder: ((context, AsyncSnapshot<String> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
          // return SkeletonAvatar(
          //   style: SkeletonAvatarStyle(
          //       width: widget.radius * 2,
          //       height: widget.radius * 2,
          //       borderRadius: BorderRadius.circular(30)),
          // );
        }
        return CircleAvatar(
            radius: widget.radius,
            backgroundColor: Theme.of(context).colorScheme.primary,
            backgroundImage: snapshot.data != null
                ? Image.network(snapshot.data!).image
                : Image.network(
                        "https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png")
                    .image);
      }),
    );
  }
}
