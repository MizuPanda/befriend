import 'package:befriend/providers/home_provider.dart';
import 'package:befriend/utilities/constants.dart';
import 'package:befriend/views/widgets/befriend_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../models/objects/friendship.dart';
import '../../models/objects/home.dart';
import '../../models/services/notification_service.dart';
import '../widgets/home/bubble/bubble_group.dart';
import '../widgets/home/buttons/home_button.dart';
import '../widgets/home/buttons/picture_button.dart';
import '../widgets/home/buttons/search_button.dart';
import '../widgets/home/buttons/settings_button.dart';

class HomePage extends StatefulWidget {
  final Home home;

  const HomePage({super.key, required this.home});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  final NotificationService _notificationService = NotificationService();
  late final HomeProvider _provider = HomeProvider(home: widget.home);
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    _provider.init(this);
    _notificationService.initTokenListener(_scaffoldKey, _provider.notify);

    super.initState();
  }

  @override
  void dispose() {
    _provider.doDispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _provider,
      child: Scaffold(
        key: _scaffoldKey,
        body: Consumer<HomeProvider>(builder:
            (BuildContext context, HomeProvider provider, Widget? child) {
          if (!provider.home.user.friendshipsLoaded) {
            return FutureBuilder(
                future: provider.loadFriendships(),
                builder: (BuildContext context,
                    AsyncSnapshot<List<Friendship>> friendships) {
                  if (friendships.hasData) {
                    return HomeStack(provider: provider, widget: widget);
                  }
                  return const Center(
                      child:
                          CircularProgressIndicator()); // CHANGE THIS WITH SAMPLE SCREEN LATER (LOADING)
                });
          } else {
            return HomeStack(provider: provider, widget: widget);
          }
        }),
      ),
    );
  }
}

class HomeStack extends StatelessWidget {
  const HomeStack({
    super.key,
    required this.widget,
    required this.provider,
  });

  final HomeProvider provider;

  final HomePage widget;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        InteractiveViewer(
          panEnabled: true,
          scaleEnabled: true,
          clipBehavior: Clip.none,
          minScale: 0.5,
          maxScale: 5.0,
          onInteractionStart: provider.onInteractionStart,
          transformationController: provider.transformationController,
          constrained: false,
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onDoubleTap: () async {
              provider.centerToMiddle();
              await HapticFeedback.mediumImpact();
            },
            child: const SizedBox(
                height: Constants.viewerSize,
                width: Constants.viewerSize,
                child: BubbleGroupWidget()),
          ),
        ),
        const BefriendWidget(),
        const SettingsButton(),
        const SearchButton(),
        const PictureButton(),
        if (!widget.home.connectedHome) const HomeButton(),
      ],
    );
  }
}
