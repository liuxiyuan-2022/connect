import 'dart:developer';

import 'package:connect/common/color_util.dart';
import 'package:connect/controller/media_controller.dart';
import 'package:connect/controller/services/bluetooth_controller.dart';
import 'package:connect/controller/services/tcp_service_controller.dart';
import 'package:connect/widgets/feedback_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:glass_kit/glass_kit.dart';

class MediaInterface extends GetView<MediaController> {
  const MediaInterface({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Get.put(MediaController());

    /// 基本图标样式
    Widget basicIcon(
      IconData icon, {
      Color? iconColor,
    }) {
      return FaIcon(
        icon,
        color: iconColor ?? Colors.black.withOpacity(.6),
        size: 28,
      );
    }

    /// 基本按钮
    Widget basicButton(
      Function() onTap,
      IconData icon, {
      Function(TapUpDetails)? onTapUp,
      Function()? onLongPress,
      Color? iconColor,
      Color? backgroundColor,
    }) {
      return FeedbackButton(
        onTap: onTap,
        onTapUp: onTapUp,
        onLongPress: onLongPress,
        enableVibrate: true,
        child: Container(
          decoration: BoxDecoration(
            color: backgroundColor ?? Colors.white.withOpacity(.6),
            borderRadius: BorderRadius.circular(25),
          ),
          child: Center(
            child: basicIcon(
              icon,
              iconColor: iconColor,
            ),
          ),
        ),
      );
    }

    /// 条形按钮
    Widget barButton(
      Function() onTap, {
      Function(TapDownDetails e)? onTapDown,
      Function(TapUpDetails)? onTapUp,
      Axis direction = Axis.horizontal,
      Color? backgroundColor,
      List<Widget> children = const [],
    }) {
      return FeedbackButton(
        onTap: onTap,
        onTapUp: onTapUp,
        onTapDown: onTapDown,
        child: Container(
          decoration: BoxDecoration(
            color: backgroundColor ?? Colors.white.withOpacity(.6),
            borderRadius: BorderRadius.circular(25),
          ),
          child: Padding(
            padding: direction == Axis.horizontal
                ? const EdgeInsets.symmetric(horizontal: 30)
                : const EdgeInsets.symmetric(vertical: 30),
            child: Flex(
              direction: direction,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: children,
            ),
          ),
        ),
      );
    }

    /// 分割条
    Widget strip() {
      return Container(
        width: 10,
        height: 1,
        color: Colors.grey.withOpacity(.3),
      );
    }

    return SizedBox(
      height: context.height,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // 玻璃模糊效果
          // 点击背景关闭页面
          InkWell(
            onTap: () => Get.back(),
            child: GlassContainer.clearGlass(
              height: double.infinity,
              width: double.infinity,
              blur: 10,
            ),
          ),

          Container(
            height: 330,
            width: context.width,
            color: Colors.transparent,
            child: StaggeredGrid.count(
              crossAxisCount: 4,
              mainAxisSpacing: 20,
              crossAxisSpacing: 20,
              children: [
                /// 其他
                StaggeredGridTile.count(
                  crossAxisCellCount: 2,
                  mainAxisCellCount: 1,
                  child: basicButton(
                    () => null,
                    FontAwesomeIcons.flickr,
                  ),
                ),

                /// 打开默认音乐播放器
                StaggeredGridTile.count(
                  crossAxisCellCount: 1,
                  mainAxisCellCount: 1,
                  child: basicButton(
                    () {
                      TcpServiceController.to.sendData(
                        TcpCommands.otherAction,
                        OtherAction.openApplication,
                        data: controller.launchPath.value,
                      );
                    },
                    FontAwesomeIcons.compactDisc,
                    onLongPress: () => controller.updataLaunchPath(),
                  ),
                ),

                /// 音量调节
                StaggeredGridTile.count(
                  crossAxisCellCount: 1,
                  mainAxisCellCount: 3,
                  child: barButton(
                    () => null,
                    direction: Axis.vertical,
                    backgroundColor: Colors.white,
                    onTapUp: (e) {
                      double widgetHeight = context.height * .276;
                      double position = e.localPosition.dy;
                      if (position <= widgetHeight / 3) {
                        BluetoothController.to.mediaControl(
                          MediaControl.volumeUp,
                        );
                      } else if (position >= widgetHeight / 3 &&
                          position <= widgetHeight * 2 / 3) {
                        BluetoothController.to.mediaControl(
                          MediaControl.mute,
                        );
                        controller.muteSwitch.toggle();
                      } else {
                        BluetoothController.to.mediaControl(
                          MediaControl.volumeDown,
                        );
                      }
                    },
                    children: [
                      basicIcon(FontAwesomeIcons.plus),
                      strip(),
                      Obx(
                        () => basicIcon(
                          FontAwesomeIcons.volumeXmark,
                          iconColor: controller.muteSwitch.value
                              ? ColorUtil.hex('#f65e6b')
                              : null,
                        ),
                      ),
                      strip(),
                      basicIcon(FontAwesomeIcons.minus),
                    ],
                  ),
                ),

                /// 播放器控制条
                StaggeredGridTile.count(
                  crossAxisCellCount: 3,
                  mainAxisCellCount: 1,
                  child: barButton(
                    () => null,
                    onTapUp: (e) {
                      double widgetWith = context.width * .61;
                      double position = e.localPosition.dx;
                      if (position <= widgetWith / 3) {
                        BluetoothController.to.mediaControl(
                          MediaControl.previousTrack,
                        );
                      } else if (position >= widgetWith / 3 &&
                          position <= widgetWith * 2 / 3) {
                        BluetoothController.to.mediaControl(
                          MediaControl.playOrPause,
                        );
                      } else {
                        BluetoothController.to.mediaControl(
                          MediaControl.nextTrack,
                        );
                      }
                    },
                    onTapDown: (e) {},
                    backgroundColor: Colors.white,
                    children: [
                      basicIcon(
                        FontAwesomeIcons.backwardStep,
                      ),
                      basicIcon(
                        FontAwesomeIcons.solidCircle,
                        iconColor: ColorUtil.hex('#f65e6b'),
                      ),
                      basicIcon(
                        FontAwesomeIcons.forwardStep,
                      ),
                    ],
                  ),
                ),

                /// 喜欢歌曲按钮
                StaggeredGridTile.count(
                  crossAxisCellCount: 1,
                  mainAxisCellCount: 1,
                  child: basicButton(
                    () {
                      TcpServiceController.to.sendData(
                        TcpCommands.otherAction,
                        OtherAction.loveSong,
                      );
                    },
                    FontAwesomeIcons.solidHeart,
                    backgroundColor: ColorUtil.hex('#e05163'),
                    iconColor: ColorUtil.hex('#ffdfad'),
                  ),
                ),

                /// 打开/关闭歌词
                StaggeredGridTile.count(
                  crossAxisCellCount: 1,
                  mainAxisCellCount: 1,
                  child: basicButton(
                    () {
                      TcpServiceController.to.sendData(
                        TcpCommands.otherAction,
                        OtherAction.openLyrics,
                      );
                    },
                    FontAwesomeIcons.solidClosedCaptioning,
                  ),
                ),

                /// mini模式
                StaggeredGridTile.count(
                  crossAxisCellCount: 1,
                  mainAxisCellCount: 1,
                  child: basicButton(
                    () {
                      TcpServiceController.to.sendData(
                        TcpCommands.otherAction,
                        OtherAction.miniMode,
                      );
                    },
                    FontAwesomeIcons.minimize,
                  ),
                ),
              ],
            ).paddingSymmetric(horizontal: 30, vertical: 30),
          ),

          // Media Controller标题
          Positioned(
            left: 30,
            bottom: 320,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Media Controller',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.black.withOpacity(.6),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 20,
            child: Text(
              '*Only for NetEase CloudMusic',
              style: TextStyle(
                fontSize: 10,
                color: Colors.black.withOpacity(.4),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}