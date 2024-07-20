import 'package:befriend/providers/home_provider.dart';
import 'package:befriend/views/widgets/befriend_widget.dart';
import 'package:befriend/views/widgets/home/buttons/referral_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:showcaseview/showcaseview.dart';

import '../../models/objects/friendship.dart';
import '../../models/objects/home.dart';
import '../../models/services/notification_service.dart';
import '../widgets/home/bubble/bubble_group.dart';
import '../widgets/home/buttons/home_button.dart';
import '../widgets/home/buttons/picture_button.dart';
import '../widgets/home/buttons/search_button.dart';
import '../widgets/home/buttons/settings_button.dart';
import '../widgets/shimmers/loading_screen.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key, required this.home});

  final Home home;

  @override
  Widget build(BuildContext context) {
    return ShowCaseWidget(builder: (context) => HomeView(home: home));
  }
}

class HomeView extends StatefulWidget {
  final Home home;

  const HomeView({super.key, required this.home});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> with TickerProviderStateMixin {
  late final HomeProvider _provider;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _provider = HomeProvider.init(this, home: widget.home);
    NotificationService.initNotifications(_scaffoldKey, _provider.notify);
    MobileAds.instance.initialize();

    debugPrint('(HomePage) _showTutorial=${_provider.home.showTutorial}');
    //_provider.home.activeTutorial(); // For testing
    if (_provider.home.showTutorial) {
      _provider.initShowcase(context);
      _provider.home.deactivateTutorial();
    }
    _provider.initLanguage(context);
  }

  @override
  void dispose() {
    _provider.doDispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: widget.home.connectedHome ? false : true,
      child: ChangeNotifierProvider.value(
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
                    return const LoadingScreen();
                  });
            } else {
              return HomeStack(provider: provider, widget: widget);
            }
          }),
        ),
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

  final HomeView widget;

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
            child: SizedBox(
                height: provider.viewerSize,
                width: provider.viewerSize,
                child: const BubbleGroupWidget()),
          ),
        ),
        BefriendWidget(
          one: provider.one,
          four: provider.four,
        ),
        const SettingsButton(),
        const SearchButton(),
        PictureButton(
          three: provider.three,
        ),
        widget.home.connectedHome ? const ReferralButton() : const HomeButton(),
      ],
    );
  }
}
