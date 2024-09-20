import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:readygreen/screens/home/home.dart';

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
    const HomePage(),
    Container(
      color: Colors.blue,
    ),
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




// class BottomNavigation extends StatefulWidget {
//   const BottomNavigation({super.key});

//   @override
//   _BottomNavigationState createState() => _BottomNavigationState();
// }

// class _BottomNavigationState extends State<BottomNavigation> {
//   int _selectedIndex = 0;

//   // 페이지 이동을 위한 함수
//   void _onItemTapped(BuildContext context, int index) {
//     setState(() {
//       _selectedIndex = index;
//     });

//     if (index == 0) {
//       Navigator.pushNamed(context, '/home');
//     } else if (index == 2) {
//       Navigator.pushNamed(context, '/map');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return BottomNavigationBar(
//       currentIndex: _selectedIndex,
//       onTap: (index) => _onItemTapped(context, index),
//       type: BottomNavigationBarType.fixed,
//       iconSize: 24,
//       backgroundColor: Colors.white,
//       selectedItemColor: const Color(0xFF7FC818),
//       unselectedItemColor: const Color(0xFF7A7A7A),
//       selectedLabelStyle: const TextStyle(fontSize: 12),
//       unselectedLabelStyle: const TextStyle(fontSize: 12),
//       items: const <BottomNavigationBarItem>[
//         BottomNavigationBarItem(
//           icon: Icon(Icons.home),
//           label: '홈',
//         ),
//         BottomNavigationBarItem(
//           icon: Icon(Icons.attach_money),
//           label: '포인트',
//         ),
//         BottomNavigationBarItem(
//           icon: Icon(Icons.map),
//           label: '지도',
//         ),
//         BottomNavigationBarItem(
//           icon: Icon(Icons.pin_drop),
//           label: '주변',
//         ),
//         BottomNavigationBarItem(
//           icon: Icon(Icons.person),
//           label: '마이페이지',
//         ),
//       ],
//     );
//   }
// }
