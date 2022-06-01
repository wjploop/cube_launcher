import 'dart:ui';

import 'package:cube_launcher/components/app_state.dart';
import 'package:cube_launcher/components/cube.dart';
import 'package:cube_launcher/components/popup_menu.dart';
import 'package:cube_launcher/data/AppInfo.dart';
import 'package:cube_launcher/data/event.dart';
import 'package:cube_launcher/screen/area_top_bottom.dart';
import 'package:cube_plugin/cube_plugin.dart';
import 'package:event_bus/event_bus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../generated/l10n.dart';

class AppGalley extends StatefulWidget {
  const AppGalley({Key? key}) : super(key: key);

  @override
  _AppGalleyState createState() => _AppGalleyState();
}

class _AppGalleyState extends State<AppGalley> {
  bool showAction = false;

  @override
  void initState() {
    super.initState();
    loading();
  }

  void loading() async {
    await context.read<AppData>().loaded();
    Future.delayed(Duration(seconds: 2), () {
      context.read<MenuState>().update(MenuPosition.middle, false);
    });
  }

  Widget menuActionToWidget(MenuState state, MenuAction action) {
    var icon = action == MenuAction.action_arrow_up
        ? Icons.arrow_circle_up_rounded
        : action == MenuAction.action_arrow_down
            ? Icons.arrow_circle_down_rounded
            : action == MenuAction.action_editing_cube
                ? Icons.edit_rounded
                : action == MenuAction.action_choose_color
                    ? Icons.color_lens_rounded
                    : action == MenuAction.action_choose_wallpaper
                        ? Icons.wallpaper_rounded
                        : action == MenuAction.action_start_rotating
                            ? Icons.rotate_right
                            : throw Exception("no support action");

    void statePrev() {
      state.update(prev(state.position), false);
      setState(() {
        showAction = false;
      });
    }

    void stateNext() {
      state.update(next(state.position), false);
      setState(() {
        showAction = false;
      });
    }

    void stateEdit() {
      if (!context.read<MenuState>().editingApp) {
        context.read<EventBus>().fire(RotateToEditEvent());
      }
      state.update(state.position, !state.editingApp);
    }

    void stateColorSelect() async {
      var menuState = context.read<MenuState>();
      var eventBus = context.read<EventBus>();
      if (!menuState.editingFaceColor) {
        // showDialog(
        //   context: context,
        //   builder: (context) => AlertDialog(
        //     content: Text("配色需要还原魔方，是否继续"),
        //     actions: [
        //       TextButton(
        //           onPressed: () {
        //             Navigator.of(context).pop();
        //           },
        //           child: Text("取消")),
        //       TextButton(
        //           onPressed: () {
        //             if (!menuState.editingFaceColor) {
        //               eventBus.fire(ResetCubeAndRotateToEditEvent());
        //             }
        //             menuState.toggleEditFaceColor();
        //             Navigator.of(context).pop();
        //           },
        //           child: Text("继续")),
        //     ],
        //   ),
        // );
        if (!menuState.editingFaceColor) {
          eventBus.fire(ResetCubeAndRotateToEditEvent());
        }
        menuState.toggleEditFaceColor();
      } else {
        menuState.toggleEditFaceColor();
      }
    }

    void stateWallpaperChoose() async {
      context.read<MenuState>().toggleChoosingWallpaper();
    }

    void stateStartRotate() {
      var menuState = context.read<MenuState>();
      menuState.updatePlaying(!menuState.playing);
    }

    void emptyAction() {}

    var actionFun = action == MenuAction.action_arrow_up
        ? statePrev
        : action == MenuAction.action_arrow_down
            ? stateNext
            : action == MenuAction.action_editing_cube
                ? stateEdit
                : action == MenuAction.action_choose_color
                    ? stateColorSelect
                    : action == MenuAction.action_choose_wallpaper
                        ? stateWallpaperChoose
                        : action == MenuAction.action_start_rotating
                            ? stateStartRotate
                            : emptyAction;

    return IconButton(
        onPressed: () {
          actionFun();
        },
        icon: Icon(icon, color: Colors.white));
  }

  void updateFaceColor(FaceColor face, Color color) {
    var colorMap = context.select((AppData value) => value.colorMap);
    var newMap = Map.of(colorMap)..[face] = color;
    context.read<AppData>().updateColor(newMap);
  }

  var menuDownDy = 0.0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onPanDown: (details) {
            menuDownDy = details.localPosition.dy;
          },
          onPanUpdate: (details) {},
          onPanEnd: (details) {
            var dy = details.velocity.pixelsPerSecond.dy;
            if (dy.abs() < 10) {
              return;
            }

            // var deltaY = details.localPosition.dy - menuDownDy;
            var lastPos = context.read<MenuState>().position;
            MenuPosition nextPos;
            if (dy > 0) {
              nextPos = next(lastPos);
            } else {
              nextPos = prev(lastPos);
            }
            context.read<MenuState>().update(nextPos, false);
          },
          child: Container(
            height: menuHeight,
            color: Colors.deepPurple,
            child: Stack(
              children: [
                Center(
                  child: Text(S.of(context).app_name),
                ),
                Row(
                  children: [
                    Expanded(
                        child: Visibility(
                      visible: showAction,
                      child: Container(
                        color: Colors.deepPurple,
                        child: Row(mainAxisAlignment: MainAxisAlignment.end, children: context.read<MenuState>().actions().map((e) => menuActionToWidget(context.read<MenuState>(), e)).toList()),
                      ),
                    )),
                    IconButton(
                        onPressed: () {
                          setState(() {
                            var menuState = context.read<MenuState>();
                            // if (menuState.editingApp ||
                            //     menuState.editingFaceColor ||
                            //     menuState.pickingWallpaper) {
                            //   return;
                            // }
                            showAction = !showAction;
                          });
                        },
                        icon: Icon(
                          Icons.more_horiz,
                          size: 26,
                        )),
                  ],
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: Consumer<AppData>(
            builder: (context, appdata, child) {
              if (!appdata.hadLoad) {
                return Container(
                  child: Center(
                    child: Text(
                      S.of(context).loading,
                      style: Theme.of(context).textTheme.headline3?.copyWith(color: Colors.white),
                    ),
                  ),
                );
              }
              return GridView.count(
                  crossAxisCount: 5,
                  childAspectRatio: 0.6,
                  padding: EdgeInsets.all(8),
                  mainAxisSpacing: 18,
                  crossAxisSpacing: 10,
                  children: context.select((AppData value) => value.apps).map((e) => GalleryItem(app: e)).toList());
            },
          ),
        ),
      ],
    );
  }
}

class GalleryItem extends StatefulWidget {
  final AppInfo app;

  const GalleryItem({Key? key, required this.app}) : super(key: key);

  @override
  _GalleryItemState createState() => _GalleryItemState();
}

class _GalleryItemState extends State<GalleryItem> with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> scale;
  var tween = Tween<double>(begin: 1.0, end: 1.2);

  @override
  void initState() {
    super.initState();
    controller = AnimationController(vsync: this, duration: Duration(milliseconds: 500));
    scale = CurvedAnimation(parent: controller, curve: Curves.ease);
  }

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    var iconSize = screenSize.width / 5 - 26;
    var attachKey = GlobalKey();

    OverlayEntry? entry;

    var popupActionItems = [
      {
        "key": GlobalKey(),
        "occupyRect": Rect.zero,
        "icon": Icons.delete_forever,
        "text": S.of(context).uninstall,
        "action": () {
          CubePlugin.unstall(widget.app.packageName);
        }
      },
      {
        "key": GlobalKey(),
        "occupyRect": Rect.zero,
        "icon": Icons.info_outline,
        "text": S.of(context).app_info,
        "action": () {
          widget.app.rawApp.openSettingsScreen();
        }
      },
    ];

    var itemWidget = GestureDetector(
      key: attachKey,
      onTap: () {
        widget.app.rawApp.openApp();
      },
      onTapDown: (detail) {
        controller.forward();
      },
      onTapUp: (detail) {
        print('tap up');
        controller.animateBack(0);
      },
      onTapCancel: () {
        print('tap cancel');
        controller.animateBack(0);
      },
      onLongPressUp: () {
        print('long press up');
        controller.animateBack(0);
      },
      onLongPressMoveUpdate: (detail) {
        print('long press move update');
        // 判断是否弹出菜单
        // 获取菜单的action坐标？？
        // 触发
        if (entry != null && entry?.mounted == true) {
          popupActionItems.forEach((element) {
            var rect = element["occupyRect"] as Rect;
            if (rect == Rect.zero) {
              var key = element["key"]! as GlobalKey;
              var renderBox = key.currentContext?.findRenderObject() as RenderBox;
              var offset = renderBox.localToGlobal(Offset.zero);
              var actionRect = Rect.fromLTWH(offset.dx, offset.dy, renderBox.size.width, renderBox.size.height);
              element["occupyRect"] = actionRect;
              print('compute rect $actionRect');
              rect = actionRect;
            }

            if (rect.contains(detail.globalPosition)) {
              var action = element["action"] as Function;
              print('do action ${element["text"]}');
              action();
              entry?.remove();
              return;
            }
          });
        }
      },
      onLongPressStart: (details) {
        print('on presss start');
        HapticFeedback.selectionClick();
      },
      onLongPress: () {
        RenderBox renderBox = attachKey.currentContext?.findRenderObject() as RenderBox;
        var size = renderBox.size;
        var position = renderBox.localToGlobal(Offset.zero);

        var attachedRect = Rect.fromLTWH(position.dx, position.dy, size.width, size.height);

        print('renderBox: $renderBox');
        print('size :$size');
        print('position :$position');

        var statusBarHeight = MediaQuery.of(context).padding.top;
        print('statusBarHeight: $statusBarHeight');

        // var popupRenderBox = popupKey.currentContext!.findRenderObject()
        // as RenderBox;
        // var popupSize = popupRenderBox.size;
        // print('popup size $popupSize');
        // var popupRect = Rect.fromLTWH(left, top, width, height)

        Size childSize = Size.zero;

        print('child size $childSize');

        var arrowHeight = 15.0;

        var popupActionItemsWidgets = popupActionItems
            .map(
              (Map e) => ClipOval(
                child: Material(
                  shape: CircleBorder(),
                  color: Colors.transparent,
                  shadowColor: Colors.red,
                  child: InkWell(
                    key: e["key"],
                    onTap: () {
                      e["action"]();
                      entry?.remove();
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        children: [
                          Icon(
                            e["icon"],
                            color: Theme.of(context).primaryColor,
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Text(e["text"], style: Theme.of(context).textTheme.bodyText2?.copyWith(fontSize: 10)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            )
            .toList();

        var popup = GestureDetector(
          onTap: () {
            entry?.remove();
          },
          onPanStart: (detail) {
            entry?.remove();
          },
          child: Container(
            color: Colors.transparent,
            child: CustomSingleChildLayout(
              delegate: LayoutPopupMenu(attachedRect),
              child: CustomPaint(
                painter: ArrowDialogPainter(attachedRect, arrowHeight: arrowHeight),
                child: Container(
                  constraints: BoxConstraints.tightFor(),
                  padding: EdgeInsets.only(left: 20, right: 20, bottom: arrowHeight + 5, top: 5),
                  child: Row(children: popupActionItemsWidgets),
                ),
              ),
            ),
          ),
        );
        entry = OverlayEntry(builder: (context) => popup, opaque: false);
        Overlay.of(context)?.insert(entry!);
      },
      child: Container(
        height: iconSize * 2,
        width: iconSize,
        child: Center(
          child: Column(
            children: [
              SizedBox(
                height: 10,
              ),
              ScaleTransition(
                scale: tween.animate(scale),
                child: ClipOval(
                  child: Image.memory(
                    widget.app.icon,
                    width: iconSize,
                    height: iconSize,
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                child: Text(
                  "${widget.app.name}",
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.caption?.copyWith(color: Colors.white),
                ),
              )
            ],
          ),
        ),
      ),
    );
    var draggableWidget = Draggable(
      data: widget.app,
      feedback: ClipOval(
        child: Image.memory(
          widget.app.icon,
          width: iconSize,
          height: iconSize,
        ),
      ),
      child: Container(decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(8)), child: itemWidget),
    );
    var editingApp = context.read<MenuState>().editingApp;

    return editingApp ? draggableWidget : itemWidget;
  }
}
