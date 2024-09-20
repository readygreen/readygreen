import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:readygreen/screens/home/home.dart';
import 'package:readygreen/screens/point/point.dart';

class BottomNavigation extends StatelessWidget {
  const BottomNavigation({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NavigationController());

    return Scaffold(
      bottomNavigationBar: Obx(
        () => NavigationBar(
          height: 80,
          elevation: 0,
          selectedIndex: controller.selectedIndex.value,
          onDestinationSelected: (index) =>
              controller.selectedIndex.value = index,
          destinations: const [
            NavigationDestination(icon: Icon(Icons.home), label: 'home'),
            NavigationDestination(
                icon: Icon(Icons.attach_money), label: 'point'),
            NavigationDestination(icon: Icon(Icons.map), label: 'map'),
            NavigationDestination(icon: Icon(Icons.pin_drop), label: 'loca'),
            NavigationDestination(icon: Icon(Icons.person), label: 'my'),
          ],
        ),
      ),
      body: Obx(() => controller.screens[controller.selectedIndex.value]),
    );
  }
}

class NavigationController extends GetxController {
  final Rx<int> selectedIndex = 0.obs;

  final screens = [
    HomePage(),
    PointPage(),
    Container(
      color: Colors.purple,
    ),
    Container(
      color: Colors.orange,
    ),
    Container(
      color: Colors.yellow,
    )
  ];
}
