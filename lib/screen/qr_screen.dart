import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:flutter/services.dart';
import 'package:showcaseview/showcaseview.dart';

import '../constant/theme_contants.dart';
import '../wigets/app_bar_widget.dart';
import '../wigets/figma_display_helper.dart';
import '../wigets/hero_text.dart';
import '../wigets/qr_scanner.dart';
import '../wigets/floating_triangles.dart';

//flutter localization
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class QRScreen extends StatefulWidget {
  List<AssetEntity>? selectedAssetList;
  bool isIntentSharing = false;
  List<SharedMediaFile>? listOfMedia;

  QRScreen({
    super.key,
    this.selectedAssetList,
    required this.isIntentSharing,
    this.listOfMedia,
  });

  @override
  State<QRScreen> createState() => _QRScreenState();
}

class _QRScreenState extends State<QRScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool showInfoPanel = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleInfoPanel() {
    HapticFeedback.lightImpact();
    setState(() {
      showInfoPanel = !showInfoPanel;
    });
  }

  Future<bool> _onWillPop() async {
    return (await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: ThemeConstant.primaryAppColor,
            title: const Text('Exit Confirmation'),
            content: const Text('Do you really want to leave the QR screen?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Exit'),
              ),
            ],
          ),
        )) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              ThemeConstant.primaryAppColor,
              ThemeConstant.primaryAppColorGradient2,
              ThemeConstant.primaryAppColorGradient3
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Stack(
            children: [
              // Floating Triangles
              Positioned.fill(
                child: const FloatingSquares(),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.only(top: 40, left: 15, right: 15),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Stack(
                      children: [
                        AppBarWidget(
                          showBackButton: true,
                          onBack: () => Navigator.pop(context),
                        ),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 15, vertical: 10),
                            child: InkWell(
                              onTap: _toggleInfoPanel,
                              child: Icon(
                                showInfoPanel
                                    ? Icons.qr_code_scanner_rounded
                                    : Icons.info_outline_rounded,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Hero Text
                    HeroText(
                      firstLine:
                          AppLocalizations.of(context)!.qr_screen_herotext_1,
                      secondLine:
                          AppLocalizations.of(context)!.qr_screen_herotext_2,
                      thirdLine: '',
                    ),

                    // QR Scanner and Info Panel (overlapping)
                    Expanded(
                      child: Stack(
                        children: [
                          // QR Scanner
                          Positioned.fill(
                            child: widget.isIntentSharing
                                ? QRScanner(
                                    isIntentSharing: widget.isIntentSharing,
                                    listOfMedia: widget.listOfMedia,
                                  )
                                : ShowCaseWidget(
                                    blurValue: 1,
                                    builder: (context) => QRScanner(
                                      isIntentSharing: widget.isIntentSharing,
                                      selectedAssetList:
                                          widget.selectedAssetList!,
                                    ),
                                  ),
                          ),
                          // Info Panel (Popup)
                          if (showInfoPanel)
                            Positioned(
                              top: screenHeight *
                                  0.001, // Adjust this value to move it up or down
                              left: screenWidth *
                                  0.08, // Optional: adjust horizontal position
                              child: GestureDetector(
                                  onTap:
                                      _toggleInfoPanel, // Dismiss when tapped outside
                                  child: Material(
                                    color: Colors.transparent,
                                    child: Center(
                                      child: Container(
                                        height: screenHeight / 2.8,
                                        width: screenWidth / 1.3,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(15),
                                        ),
                                        child: Column(
                                          children: [
                                            // Close button (cross) positioned at the top right corner
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 20, right: 5),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    'Steps',
                                                    style: ThemeConstant
                                                        .smallTextSize
                                                        .copyWith(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize:
                                                          18, // Increase size to make it stand out
                                                    ),
                                                  ),
                                                  Align(
                                                    alignment:
                                                        Alignment.topRight,
                                                    child: IconButton(
                                                      icon: Icon(
                                                        Icons.close,
                                                        color: ThemeConstant
                                                            .primaryAppColor,
                                                      ),
                                                      onPressed:
                                                          _toggleInfoPanel,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),

                                            Expanded(
                                              child: SingleChildScrollView(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    // Step 1
                                                    _buildStep(
                                                      number: '1',
                                                      title:
                                                          'Open Figma Plugin',
                                                      description:
                                                          'Open the Snapdrop Figma Plugin from the Figma community.',
                                                    ),
                                                    const SizedBox(height: 12),

                                                    // Step 2
                                                    _buildStep(
                                                      number: '2',
                                                      title: 'Scan QR Code',
                                                      description:
                                                          'Point your camera at the QR code displayed in the app.',
                                                    ),
                                                    const SizedBox(height: 12),

                                                    // Step 3
                                                    _buildStep(
                                                      number: '3',
                                                      title: 'Image Sync',
                                                      description:
                                                          'Your images will be transferred instantly to Figma.',
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  )),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep({
    required String number,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Step Number
          CircleAvatar(
            backgroundColor: ThemeConstant.primaryAppColor,
            radius: 14,
            child: Text(
              number,
              style: ThemeConstant.smallTextSize.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Step Description
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: ThemeConstant.smallTextSize.copyWith(
                        color: Colors.black, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(description,
                    style: ThemeConstant.smallTextSizeLight.copyWith(
                      color: Colors.black.withOpacity(0.9),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
