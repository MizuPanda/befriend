import 'package:befriend/views/widgets/befriend_widget.dart';
import 'package:befriend/views/widgets/notification_button.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/bubble_user.dart';
import '../widgets/users/profile_photo.dart';

class ProfilePage extends StatelessWidget {
  final BubbleUser user;

  const ProfilePage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const BefriendTitle(),
          foregroundColor: Colors.black,
          backgroundColor: Colors.white),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white, // Replace with your desired color
              child: SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        //ERROR - I can't tap anymore on a bubble when I move the screen. Only for those that were outside of the screen. - ERROR
                        Badge(
                          backgroundColor: Colors.transparent,
                          isLabelVisible: user.main,
                          padding: EdgeInsets.zero,
                          largeSize: 50,
                          offset: const Offset(30, -15),
                          label: IconButton(
                            onPressed: user.main ? () {} : null,
                            icon: const Icon(
                              Icons.mode_edit_outline_outlined,
                              size: 30,
                            ),
                          ),
                          child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.black,
                                  width: 1.0,
                                ),
                              ),
                              child: ProfilePhoto(
                                radius: 50,
                                user: user,
                              )),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.bubble().name,
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '@${user.bubble().username}',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        if(!user.main)
                          const Spacer(),
                        if(!user.main)
                          Container(height: 75, alignment: Alignment.topCenter,child: const NotificationButton()),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.yellow),
                        const SizedBox(width: 8),
                        Text('${user.levelText()}: ${user.levelNumberText()}',
                            style: GoogleFonts.firaMono(
                              textStyle: const TextStyle(
                                  fontSize: 16, color: Colors.black),
                            )),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Pictures',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(
              //NEW PICS ON TOP, WITH MAXIMAL HEIGHT/DESIRED FORM, THEN LIST VIEW OF ROWS OF 3 PICTURES
              height: 200,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  Container(
                    width: 200,
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(child: Text('Picture 1')),
                  ),
                  Container(
                    width: 200,
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(child: Text('Picture 2')),
                  ),
                  Container(
                    width: 200,
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(child: Text('Picture 3')),
                  ),
                  // Add more pictures here as needed
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/*
import 'package:befriend/models/schrodinger.dart';
import 'package:befriend/views/widgets/users/profile_photo.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/bubble.dart';

class ProfilePage extends StatefulWidget {
  final Schrodinger user;
  const ProfilePage({super.key, required this.user});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {

  @override
  void initState() {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(backgroundColor: Colors.white, foregroundColor: Colors.black, shadowColor: Colors.transparent,),
      body: Column(
        children: [
          const SizedBox(height: 16),
          ProfileHeader(user: widget.user,),
          const Expanded(
            child: DraggableBottomSheet(),
          ),
        ],
      ),
    );
  }
}

class ProfileHeader extends StatefulWidget {
  final Schrodinger user;
  const ProfileHeader({Key? key, required this.user}) : super(key: key);

  @override
  State<ProfileHeader> createState() => _ProfileHeaderState();
}

class _ProfileHeaderState extends State<ProfileHeader> {
  late Bubble bubble;
  @override
  void initState() {
    bubble = widget.user.bubble();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      color: Colors.white,
      child: Column(
        children: [
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    bubble.name,
                    style: GoogleFonts.openSans(
                      textStyle: const TextStyle(
                        color: Colors.black,
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '@${bubble.username}',
                    style: GoogleFonts.openSans(
                      textStyle: const TextStyle(
                        color: Colors.black54,
                        fontSize: 18,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Badge(
                backgroundColor: Colors.transparent,
                padding: EdgeInsets.zero,
                largeSize: 50,
                  offset: const Offset(25, -15),
                  label: IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.mode_edit_outline_outlined, size: 30,),
                  ),
                  child: ProfilePhoto(
                    bubble: bubble,
                    radius: 40,
                  )),
              const SizedBox(
                width: 16,
              ),
            ],
          ),
          Container(
            alignment: Alignment.centerLeft,
            width: double.infinity,
            child: Text(
              widget.user.levelText(),
              style: GoogleFonts.openSans(
                textStyle: const TextStyle(
                  color: Colors.black,
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          Container(
            width: double.infinity,
            alignment: Alignment.bottomRight,
            child: Text(
              widget.user.levelNumberText(),
              style: GoogleFonts.firaMono(
                textStyle: const TextStyle(
                  color: Colors.greenAccent,
                  fontSize: 35,
                  fontWeight: FontWeight.w800,
                  shadows: [
                    Shadow(
                      color: Colors.black,
                      blurRadius: 10.0
                    )
                  ]
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class DraggableBottomSheet extends StatefulWidget {
  const DraggableBottomSheet({Key? key}) : super(key: key);

  @override
  State<DraggableBottomSheet> createState() => _DraggableBottomSheetState();
}

class _DraggableBottomSheetState extends State<DraggableBottomSheet> {
  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.5,
      maxChildSize: 1.0,
      builder: (BuildContext context, ScrollController scrollController) {
        return Container(
          padding: const EdgeInsets.only(top: 16),
          decoration: const BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
          ),
          child: ListView(
            controller: scrollController,
            children: [
              Center(
                child: Container(
                  width: 30,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Center(child: Text('No pictures yet', style: TextStyle(color: Colors.white),),)
            ],
          ),
        );
      },
    );
  }
}
*/
