import 'package:flutter/material.dart';
import 'package:Snapdrop/services/app_share_service.dart';
import '../constant/theme_contants.dart';

//flutter localization
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ShareAppDialog extends StatelessWidget {
  const ShareAppDialog({Key? key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      surfaceTintColor: ThemeConstant.greenAccentColor,
      shadowColor: ThemeConstant.primaryAppColor,
      backgroundColor: Colors.black12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      //backgroundColor: ThemeConstant.primaryAppColor,
      elevation: 0,
      child: Container(
        decoration: ThemeConstant.appBackgroundGradient
            .copyWith(borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.share,
                size: 64,
                color: ThemeConstant.greenAccentColor,
              ),
              const SizedBox(height: 24),
              Text(
                AppLocalizations.of(context)!.app_share_dialog_text_1,
                style: ThemeConstant.largeTextSize
                    .copyWith(color: ThemeConstant.whiteColor),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                AppLocalizations.of(context)!.app_share_dialog_text_2,
                style: ThemeConstant.smallTextSize
                    .copyWith(color: ThemeConstant.whiteColor),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ThemeConstant.primaryAppColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 26, vertical: 16),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                      AppShareService().shareApp(context);
                    },
                    child: Text(
                      AppLocalizations.of(context)!
                          .app_share_dialog_share_now_button,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: ButtonStyle(
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                          side: const BorderSide(color: Colors.white, width: 2),
                        ),
                      ),
                      padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                        const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 15),
                      ),
                    ),
                    child: Text(
                      AppLocalizations.of(context)!
                          .app_share_dialog_maybe_later_button,
                      style: ThemeConstant.smallTextSizeWhiteFontWidth
                          .copyWith(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
