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

* Send more than 10 images at once or Send files larger than 5 mb.
* Able to see all the transfer history.

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



### File Structure

A High-level overview of the project structure:
```

lib/                     # Root Package
|
├─ Constant/                 # For data handling
│  ├─ global_showcase_key/              # sample used for testing
│  ├─ models/            # Objects representing data
│  ├─ repositories/      # Source of data
|
├─ redux/                # manages app state
│  ├─ component/         # app building block
│     ├─ actions         # methods to update app state
|     ├─ middleware      # run in response to actions, execute before reducer
|     ├─ reducer         # intercepts actions, responsible for updating the state
|     ├─ selectors       # read data from the state, queries against your 'state database'
|     ├─ state           # immutable object that lives at the top of the widget hierarchy
|
├─ ui/                   # app views
│  ├─ component/         # views for different components
│    ├─ view/            # generel view for component
│    ├─ edit/            # change values on the views fields
|
├─ main/                # Main classes

```


</a>

