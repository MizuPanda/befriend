import 'package:befriend/providers/home_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/objects/friendship.dart';
import '../../models/objects/home.dart';
import '../widgets/befriend_widget.dart';
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
  late final HomeProvider _provider = HomeProvider(home: widget.home);
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    _provider.init(this);
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
                          CircularProgressIndicator()); //CHANGE THIS WITH SAMPLE SCREEN LATER (LOADING)
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
    required HomeProvider provider,
    required this.widget,
  }) : _provider = provider;

  final HomeProvider _provider;
  final HomePage widget;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GestureDetector(
          onScaleUpdate: _provider.scale,
          onDoubleTap: _provider.centerToMiddle,
          child: Transform.scale(
            scale: _provider.scaleFactor,
            child: AnimatedBuilder(
                animation: _provider.listenable,
                builder: (BuildContext context, Widget? child) {
                  return Container(
                    color: Colors.white,
                    width: double.infinity,
                    height: double.infinity,
                    child: Transform.translate(
                      offset: _provider.pageOffset(),
                      child: const BubbleGroupWidget(),
                    ),
                  );
                }),
          ),
        ),
        const BefriendWidget(),
        const SettingsButton(),
        const SearchButton(),
        const PictureButton(),
        if (!widget.home.connectedHome) const HomeButton()
      ],
    );
  }
}
