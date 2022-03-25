import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'device_avatar.dart';
import 'main_actions_dialog.dart';
import 'main_drawer.dart';
import 'no_device_screen.dart';
import 'device_info_screen.dart';
import '../models.dart';
import '../state.dart';
import '../../fido/views/fido_screen.dart';
import '../../oath/views/oath_screen.dart';
import '../../management/views/management_screen.dart';

class MainPage extends ConsumerWidget {
  final Key _scaffoldKey = GlobalKey();
  MainPage({Key? key}) : super(key: key);

  Widget _buildSubPage(Application app, YubiKeyData deviceData) {
    if (app.getAvailability(deviceData) != Availability.enabled) {
      return const Center(
        child: Text('This application is disabled'),
      );
    }

    switch (app) {
      case Application.oath:
        return OathScreen(deviceData);
      case Application.management:
        return ManagementScreen(deviceData);
      case Application.fido:
        return FidoScreen(deviceData);
      default:
        return DeviceInfoScreen(deviceData);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) => LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 540) {
            // Single column layout
            return _buildScaffold(context, ref, true);
          } else {
            // Two-column layout
            return Scaffold(
              body: Row(
                children: [
                  const SizedBox(
                    width: 240,
                    child: MainPageDrawer(shouldPop: false),
                  ),
                  Expanded(
                    child: _buildScaffold(context, ref, false),
                  ),
                ],
              ),
            );
          }
        },
      );

  Scaffold _buildScaffold(BuildContext context, WidgetRef ref, bool hasDrawer) {
    final deviceNode = ref.watch(currentDeviceProvider);
    final deviceData = ref.watch(currentDeviceDataProvider);
    final subPage = ref.watch(currentAppProvider);

    Widget deviceWidget;
    if (deviceNode != null) {
      if (deviceData != null) {
        deviceWidget = DeviceAvatar.yubiKeyData(
          deviceData,
          selected: true,
        );
      } else {
        deviceWidget = DeviceAvatar.deviceNode(
          deviceNode,
          selected: true,
        );
      }
    } else {
      deviceWidget = const DeviceAvatar(
        child: Icon(Icons.more_horiz),
      );
    }
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        /*
        The following can be used to customize the appearence of the app bar,
        should we wish to do so. More advanced changes may require using a
        custom Widget instead.

        backgroundColor: Colors.grey.shade900,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.all(Radius.circular(40)),
          side: BorderSide(
              width: 8, color: Theme.of(context).scaffoldBackgroundColor),
        ),
        */
        title: Focus(
          canRequestFocus: false,
          onKeyEvent: (node, event) {
            if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
              node.focusInDirection(TraversalDirection.down);
              return KeyEventResult.handled;
            }
            return KeyEventResult.ignored;
          },
          child: Builder(builder: (context) {
            return TextField(
              decoration: const InputDecoration(
                hintText: 'Search...',
                border: InputBorder.none,
              ),
              onChanged: (value) {
                ref.read(searchProvider.notifier).setFilter(value);
              },
              textInputAction: TextInputAction.next,
              onSubmitted: (value) {
                Focus.of(context).focusInDirection(TraversalDirection.down);
              },
            );
          }),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              icon: OverflowBox(
                maxHeight: 44,
                maxWidth: 44,
                child: deviceWidget,
              ),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => const MainActionsDialog(),
                );
              },
            ),
          ),
        ],
      ),
      drawer: hasDrawer ? const MainPageDrawer() : null,
      body: deviceData == null
          ? NoDeviceScreen(deviceNode)
          : _buildSubPage(subPage, deviceData),
    );
  }
}
