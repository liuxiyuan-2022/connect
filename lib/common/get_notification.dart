import 'package:connect/style/app_theme_style.dart';
import 'package:connect/widgets/app_bottomsheet_box.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

class GetNotification {
  /// 显示自定义Toast
  static showToast({
    required String message,
    Duration? duration,
  }) {
    FToast fToast = FToast();

    // 清除Toast
    fToast.removeQueuedCustomToasts();

    // 提供overlay的上下文
    fToast.init(Get.overlayContext!);

    fToast.showToast(
      toastDuration: duration ?? const Duration(milliseconds: 3000),
      gravity: ToastGravity.TOP,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15),
        decoration: BoxDecoration(
          color: AppThemeStyle.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: AppThemeStyle.darkGrey,
              blurRadius: 20,
            ),
          ],
        ),
        child: Text(
          message,
          style: Theme.of(Get.context!).textTheme.subtitle1!.copyWith(
                color: AppThemeStyle.black,
                fontWeight: FontWeight.normal,
              ),
        ),
      ),
    );
  }

  /// 显示自定义的Snackbar通知
  static void showCustomSnackbar(
    String title,
    String message, {
    Widget? titleWidget,
    Widget? messageWidget,
    Widget? icon,
    IconData? tipsIcon,
    Color? tipsIconColor,
    Color? backgroundColor,
    double? tipsIconSize,
    double maxWidth = 350, // 最大宽度
    EdgeInsets? padding,
    double? borderRadius,
    Duration duration = const Duration(seconds: 3),
    Duration animationDuration = const Duration(milliseconds: 750),
    bool isDismissible = true, // 是否开启手势关闭
    DismissDirection dismissDirection = DismissDirection.up, // Snackbar关闭方向
    bool isCleanQueue = true, // 显示时是否关闭队列中的Snackbar
    Curve? animationCurve, // 弹出和消失动画
    Function(GetSnackBar)? onTap,
    Function(SnackbarStatus?)? snackbarStatus, // 通知状态监听
  }) {
    if (isCleanQueue) Get.closeCurrentSnackbar();

    Get.snackbar(
      title,
      message,
      titleText: titleWidget,
      messageText: messageWidget,
      icon: icon,
      duration: duration,
      dismissDirection: dismissDirection,
      margin: const EdgeInsets.only(top: 20),
      animationDuration: animationDuration,
      forwardAnimationCurve: animationCurve,
      reverseAnimationCurve: animationCurve,
      padding: padding,
      backgroundColor:
          backgroundColor ?? AppThemeStyle.darkGrey.withOpacity(.7),
      isDismissible: isDismissible,
      maxWidth: maxWidth,
      borderRadius: borderRadius ?? 20,
      colorText: AppThemeStyle.white,
      onTap: onTap,
      mainButton: tipsIcon != null
          ? TextButton(
              onPressed: null,
              child: FaIcon(
                tipsIcon,
                color: tipsIconColor ?? AppThemeStyle.white,
                size: tipsIconSize ?? 25,
              ),
            )
          : null,
      snackbarStatus: snackbarStatus ??
          (status) async {
            switch (status) {
              case SnackbarStatus.OPENING:
                // 播放音频
                FlutterRingtonePlayer.play(
                  fromAsset: "assets/audios/notification_fresh.ogg",
                );
                break;
              case SnackbarStatus.CLOSED:
                // 关闭音频
                FlutterRingtonePlayer.stop();
                break;
              default:
            }
          },
    );
  }

  /// 显示自定义的GetBottomSheet
  static Future<T?> showCustomBottomSheet<T>({
    required String title,
    String? message,
    String? confirmTitle,

    /// 确认按钮
    Color? confirmBorderColor,
    Color? confirmTextColor,
    required Function() confirmOnTap,

    /// 取消按钮
    Color? cancelBorderColor,
    Color? cancelTextColor,
    String? cancelTitle,
    Function()? cancelOnTap,

    /// 自定义组件
    List<Widget> children = const <Widget>[],

    /// 点击背景是否可以关闭
    bool? isDismissble,

    /// 是否可以滑动关闭
    bool? enableDrag,
  }) {
    return Get.bottomSheet(
      AppBottomSheetBox(
        title: title,
        message: message,
        confirmTitle: confirmTitle,
        confirmTextColor: confirmTextColor,
        confirmBorderColor: confirmBorderColor,
        confirmOnTap: confirmOnTap,
        cancelTitle: cancelTitle,
        cancelTextColor: cancelTextColor,
        cancelBorderColor: cancelBorderColor,
        cancelOnTap: cancelOnTap,
        children: children,
      ),
      ignoreSafeArea: true,
      isScrollControlled: true, // 是否支持全屏弹出
      barrierColor: Colors.black12,
      isDismissible: isDismissble ?? false, // 点击背景是否可以关闭
      enableDrag: enableDrag ?? true, // 是否可以滑动关闭
    );
  }
}
