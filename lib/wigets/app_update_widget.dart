// import 'package:flutter/material.dart';
// import 'package:upgrader/upgrader.dart';

// class AppUpdateWidget extends StatelessWidget {
//   const AppUpdateWidget({super.key});

//   @override
//   Widget build(BuildContext context) {
//     var screenWidth = MediaQuery.of(context).size.width;
//     var screenHeight = MediaQuery.of(context).size.height;

//     return UpgradeAlert(
//       upgrader: Upgrader(
//         appcastConfig: AppcastConfiguration(
//           url: 'https://your-server.com/appcast.json',
//           supportedOS: ['android', 'ios'],
//         ),
//         child: _buildUpdateWidget(screenWidth, screenHeight),
//       ),
//     );
//   }

//   Widget _buildUpdateWidget(double screenWidth, double screenHeight) {
//     return Container(
//       height: screenHeight / 3,
//       width: screenHeight / 1.5,
//       decoration: BoxDecoration(
//         borderRadius: const BorderRadius.only(
//           topLeft: Radius.circular(30.0),
//           topRight: Radius.circular(30.0),
//         ),
//         color: ThemeConstant.primaryAppColor.withOpacity(0.3),
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             ClipRRect(
//               borderRadius: BorderRadius.circular(10),
//               child: SvgPicture.asset(
//                 'assets/svg_asset/snapdrop_logo.svg',
//                 height: 80,
//                 width: 80,
//               ),
//             ),
//             const Text(
//               'Update Available',
//               style: ThemeConstant.mediumTextSizeDark,
//             ),
//             const Text(
//               'A newer version of Snapdrop is ready to be installed.',
//               style: ThemeConstant.smallTextSizeGrey,
//               textAlign: TextAlign.center,
//             ),
//             ElevatedButton(
//               onPressed: () {
//                 Upgrader().upgradeApp();
//               },
//               style: ElevatedButton.styleFrom(
//                 minimumSize: Size(screenWidth, screenHeight / 20),
//                 backgroundColor: ThemeConstant.primaryAppColor,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(5),
//                 ),
//               ),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   FittedBox(
//                     fit: BoxFit.scaleDown,
//                     child: Text(
//                       "Install Now",
//                       style: ThemeConstant.smallTextSizeLight,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             ElevatedButton(
//               onPressed: () {},
//               style: ElevatedButton.styleFrom(
//                 minimumSize: Size(screenWidth, screenHeight / 20),
//                 disabledBackgroundColor: Colors.grey.withOpacity(0.2),
//                 side: const BorderSide(color: Colors.grey),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(5),
//                 ),
//               ),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   FittedBox(
//                     fit: BoxFit.scaleDown,
//                     child: Text(
//                       "Later",
//                       style: ThemeConstant.smallTextSizeDark,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
