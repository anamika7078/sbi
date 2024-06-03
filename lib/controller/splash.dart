import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:get/get.dart';
import 'package:sbi/view/home.dart';
import '../constant.dart';
import '../service.dart';
import '../view/login.dart';

class SplashController extends GetxController {
  late final Timer? timer;

  final fbKeyLogin = GlobalKey<FormBuilderState>();
  RxBool isLoading = false.obs;
  TextEditingController userNameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  @override
  void onInit() {
    timer = Timer(const Duration(seconds: 3), () async {
      Get.offAll(() => const LoginPage());
    });

    super.onInit();
  }

  @override
  void dispose() {
    timer!.cancel();
    super.dispose();
  }

  login() async {
    if (fbKeyLogin.currentState!.saveAndValidate()) {
      isLoading.value = true;
      var data = await Service.login(
        userNameController.text,
        passwordController.text,
      );
      print(data);
      if (data["result"]["outcome"]["outcomeId"] == 1) {
        await Service.storage.write(
            key: 'token',
            value: data["result"]["outcome"]["tokens"].toString());
        await Service.storage.write(
            key: 'loginid',
            value: data["result"]["data"]["login_id"].toString());
        await Service.storage.write(
            key: 'companyId',
            value: data["result"]["data"]["com_id"].toString());

        isLoading.value = false;
        flutterToastMsg(
          "Login Successfully",
        );
        Get.to(() => MyHomePage());
      } else if (data["result"]["outcome"]["outcomeId"] == 0) {
        flutterToastMsg(data["result"]["outcome"]["outcomeDetail"]);
        update();
      }
      isLoading.value = false;
    }
  }
}
