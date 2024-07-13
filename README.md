<a>
<img src="assets/svg_asset/snapdrop_logo.svg" height="100" width="100"> 
<h1> Snapdrop </h1>

## Snapdrop - Effortless Image Transfer for UI/UX Designers

### 1. Features:

* Direct phone to Figma image transfer
* Secure QR code connection
* Seamless Figma plugin integration
* Review & integrate images in Figma

### 2. Useful For:

* UI/UX designers
* Anyone transferring images between phone and Figma

### 3. Core Structure:

* Mobile app: image selection & QR Scanning
* Figma plugin: QR code Generation & image import

### 4. Resources & Inspirations:

* Solves common designer image transfer pain point
* Streamlines workflow & improves design efficiency

### 5. Future Scope:

* Send Up to 10 Images at Once: Effortlessly transfer multiple images in a single go.
* Support for Larger Files (Over 5MB): Handle high-resolution images without limitations.
* Transfer History: View and manage your past image transfers for easy reference.
* Multi-Lingual Support: Use Snapdrop in your preferred language for a global design experience.
* Theme Customization: Personalize your Snapdrop experience with custom colors and light/dark themes.

### 6. Screenshots:
<table>
  <tr>
    <td>
      <img src="assets/app_screenshots/splashscreen.jpeg" alt="Splashscreen" width="300">
    </td>
        <td>
      <img src="assets/app_screenshots/void_error.jpeg" alt="HomeScreen" width="300">
    </td>
        <td>
      <img src="assets/app_screenshots/home_screen.jpeg" alt="HomeScreen"  width="300">
    </td>
  </tr>
   <tr>
    <td>
      <img src="assets/app_screenshots/multiple_selection.jpeg" alt="Splashscreen" width="300">
    </td>
    <td>
      <img src="assets/app_screenshots/qr_screen.jpeg" alt="HomeScreen" width="300">
    </td>
      <td>
      <img src="assets/app_screenshots/review_images_2.jpeg" alt="Splashscreen" width="300">
    </td>
  </tr>
     <tr>
  </tr>
</table>



### 6. File Structure

A High-level overview of the project structure:
```

lib/                     # Root Package
|
├─ constant/                             # Constant files to use across the app
│  ├─ global_showcase_key.dart           # Global key used for showcase view
│  ├─ theme_constants.dart               # Theme file
|
├─ l10n/                                 # Localization files
│  ├─ app_ar.arb                         # Arabic Language
│  ├─ app_en.arb                         # English Language
│  ├─ app_es.arb                         # Spanish Language
│  ├─ app_hi.arb                         # Hindi Language
│  ├─ app_pt.arb                         # Portuguese Language
│  ├─ app_zh.arb                         # Simplified Chinese Language
|
├─ screen/                               # Contain all the main screens of the app
│  ├─ home_screen.dart                   # Home screen for the app
│  ├─ intent_sharing_screen.dart         # Images sent directly from other apps
│  ├─ language_selection.dart            # Language selection screen
│  ├─ onboard_screen.dart                # Onboarding screen for the first time
│  ├─ qr_screen.dart                     # QR Screen
│  ├─ send_file_screen.dart              # Review selected images screen
|
├─ services/                             # Services used for the app
│  ├─ app_share_service.dart             # To handle app sharing functionality
│  ├─ check_app_version.dart             # To check and handle app version updates
│  ├─ check_internet_connectivity.dart   # To check internet connectivity before sending images
│  ├─ file_image.dart                    # To identify the size of the image
│  ├─ first_time_login.dart              # To check first time login to display showcase view and onboarding screen
│  ├─ in_app_review_service.dart         # To handle in-app review prompts
│  ├─ media_provider.dart                # Provides the app with the album list and the images present in the album
│  ├─ permission_provider.dart           # To ask user to grant permission for storage and camera
│  ├─ selected_language.dart             # To manage selected language settings
│  ├─ socket_service.dart                # To transfer all the images from phone to your Figma design file
|
├─ utils/                                # Utility files
│  ├─ firebase_initialization_class.dart # Firebase initialization
│  ├─ firebase_options.dart              # Firebase options
|
├─ widgets/                              # Widgets used multiple times throughout the application
│  ├─ app_bar_widget.dart                # App bar for the app
│  ├─ connect.dart                       # Connect to socket and send images from phone to Figma
│  ├─ dropdown_view.dart                 # Dropdown used to display all the albums and images in a grid view
│  ├─ figma_display_helper.dart          # For displaying Figma info
│  ├─ hero_text.dart                     # To display info throughout every screen
│  ├─ intent_file_displayer.dart         # Display images shared from other apps to Snapdrop
│  ├─ intro_widget.dart                  # Used in the intro screen to display info
│  ├─ qr_scanner.dart                    # Actual QR scanning code
│  ├─ room_displayer.dart                # To display the room ID when connected to Figma
│  ├─ selected_images.dart               # Review images displayer
│  ├─ share_app_dialog.dart              # Dialog for sharing the app
|
├─ main.dart                             # Main class


```

# 7. Libraries

- [cupertino_icons](https://pub.dev/packages/cupertino_icons): ^1.0.2
- [photo_manager](https://pub.dev/packages/photo_manager): ^3.0.0
- [flutter_svg](https://pub.dev/packages/flutter_svg): ^2.0.5
- [qr_code_scanner](https://pub.dev/packages/qr_code_scanner): ^1.0.1
- [socket_io_client](https://pub.dev/packages/socket_io_client): ^2.0.3+1
- [flutter_launcher_icons](https://pub.dev/packages/flutter_launcher_icons): ^0.13.1
- [receive_sharing_intent](https://pub.dev/packages/receive_sharing_intent): ^1.4.5
- [photo_manager_image_provider](https://pub.dev/packages/photo_manager_image_provider): ^2.1.1
- [permission_handler](https://pub.dev/packages/permission_handler): ^11.3.1
- [lottie](https://pub.dev/packages/lottie): ^3.1.0
- [device_info_plus](https://pub.dev/packages/device_info_plus): ^10.1.0
- [showcaseview](https://pub.dev/packages/showcaseview): ^3.0.0
- [shared_preferences](https://pub.dev/packages/shared_preferences): ^2.2.3
- [shimmer](https://pub.dev/packages/shimmer): ^3.0.0
- [firebase_core](https://pub.dev/packages/firebase_core): ^3.0.0
- [firebase_analytics](https://pub.dev/packages/firebase_analytics): ^11.0.0
- [firebase_crashlytics](https://pub.dev/packages/firebase_crashlytics): ^4.0.0
- [firebase_performance](https://pub.dev/packages/firebase_performance): ^0.10.0
- [firebase_remote_config](https://pub.dev/packages/firebase_remote_config): ^5.0.0
- [package_info_plus](https://pub.dev/packages/package_info_plus): ^8.0.0
- [intl](https://pub.dev/packages/intl): ^0.19.0
- [flutter_localizations](https://pub.dev/packages/flutter_localizations)
- [in_app_review](https://pub.dev/packages/in_app_review): ^2.0.9
- [flutter_upgrade_version](https://pub.dev/packages/flutter_upgrade_version): ^1.1.5
- [share_plus](https://pub.dev/packages/share_plus): ^9.0.0

</a>

