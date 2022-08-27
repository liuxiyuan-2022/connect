import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'package:connect/common/color_util.dart';
import 'package:connect/common/get_notification.dart';
import 'package:connect/controller/services/face_verification_controller.dart';
import 'package:connect/style/color_palette.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:huawei_ml_body/huawei_ml_body.dart';

/// 隐藏相机控制器, 用于面部解锁
class HideCameraController extends GetxController {
  static HideCameraController get to => Get.find();

  /// 相机引擎
  late MLBodyLensEngine cameraEngine;

  /// 为镜头纹理创建一个变量。
  /// 这个变量将把本地纹理与应用程序的纹理绑定起来。
  RxInt textureId = 0.obs;

  /// 检测到面部的指示器
  RxInt debounceCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    initCameraEngine();
  }

  /// 初始化相机
  Future<void> initCameraEngine() async {
    // 创建一个镜头控制器。
    final controller = MLBodyLensController(
      // 设置类型
      transaction: BodyTransaction.skeleton, // face识别bug, 用skeleton(骨架)代替
      // 将镜头设置为正面
      lensType: MLBodyLensController.frontLens,
    );

    // 创建一个镜头引擎对象并指定控制器。
    cameraEngine = MLBodyLensEngine(controller: controller);

    // 为了获得实时的识别结果，创建一个监听器回调。
    void onTransaction({dynamic result}) {
      // 判断相机返回结果是否识别到面部
      if (result.toString() == "[Instance of 'MLSkeleton']") {
        debounceCount++;
      }
    }

    // 然后将回调传递给引擎的setTransactor方法。
    cameraEngine.setTransactor(onTransaction);

    // 初始化相机流的纹理。
    await cameraEngine.init().then((value) {
      // 将textureId变量设置为返回值。
      // 然后，纹理将准备好流。
      textureId.value = value;
    });
  }

  /// 启动相机
  Future<void> openCamera() async {
    await initCameraEngine();

    cameraEngine.run();
    debounceCount.value = 0; // 将指示器的值清零

    // 设置延时器, 如果5秒内未检测到面部则关闭相机
    Future.delayed(const Duration(seconds: 5), () {
      if (debounceCount.value == 0) {
        cameraEngine.release();
        GetNotification.showSnackbar(
          'Face Unlock',
          'No face is detected !',
          tipsIcon: FontAwesomeIcons.solidFaceMehBlank,
          tipsIconColor: ColorUtil.hex("#495057"),
        );
      }
    });

    // 当相机检测到面部时
    // 当[debounceCount]第一次改变时调用
    once(
      debounceCount,
      (_) async {
        if (await saveCameraImage()) {
          FaceVerificationController.to.startFaceVerification(); // 进行面部识别
        }
      },
    );
  }

  /// 保存捕获的面部图片
  Future<bool> saveCameraImage() async {
    try {
      Uint8List imgUint8List = await cameraEngine.capture();
      // 关闭相机
      cameraEngine.release();
      // 将面部图片保存在本地
      File(FaceVerificationController.to.faceLocalPath).writeAsBytes(
        imgUint8List,
        mode: FileMode.write,
      );
      return true;
    } catch (e) {
      GetNotification.showSnackbar(
        'Face Unlock',
        'Face capture error, please try again.',
        tipsIcon: FontAwesomeIcons.camera,
        tipsIconColor: ColorPalette.red,
      );
      cameraEngine.release();
      log(e.toString());
      return false;
    }
  }
}