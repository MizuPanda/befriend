import 'package:befriend/providers/home_provider.dart';
import 'package:befriend/views/widgets/befriend_widget.dart';
import 'package:befriend/views/widgets/home/buttons/referral_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:showcaseview/showcaseview.dart';

import '../../models/objects/home.dart';
import '../widgets/home/bubble/bubble_group.dart';
import '../widgets/home/buttons/home_button.dart';
import '../widgets/home/buttons/picture_button.dart';
import '../widgets/home/buttons/search_button.dart';
import '../widgets/home/buttons/settings_button.dart';

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
    _provider.initServices(_scaffoldKey);

    if (_provider.home.showTutorial) {
      _provider.initShowcase(context);
      _provider.home.deactivateTutorial();
    }
    _provider.initLanguage(context);
    _provider.loadFriendsAsync();
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
            return HomeStack(
                connectedHome: widget.home.connectedHome, provider: provider);
          }),
        ),
      ),
    );
  }
}

class HomeStack extends StatelessWidget {
  const HomeStack({
    super.key,
    required this.connectedHome,
    required this.provider,
  });

  final HomeProvider provider;

  final bool connectedHome;

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
        connectedHome ? const ReferralButton() : const HomeButton(),
      ],
    );
  }
}
