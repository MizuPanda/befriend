import 'package:befriend/providers/home_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/home.dart';
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
        body: Stack(
          children: [
            Consumer<HomeProvider>(builder:
                (BuildContext context, HomeProvider provider, Widget? child) {
              return GestureDetector(
                onPanUpdate: _provider.drag,
                onDoubleTap: _provider.centerToMiddle,
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
              );
            }),
            const BefriendWidget(),
            const SettingsButton(),
            const SearchButton(),
            const PictureButton(),
            if (!widget.home.connectedHome) const HomeButton()
          ],
        ),
      ),
    );
  }
}
