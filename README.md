# AnyTimeScan

**AnyTimeScan** is a cross-platform mobile app (Flutter) for capturing object images to generate 3D models. It works on both Android and iOS and supports seamless cloud integration.

<div align="center">
    <img src="https://github.com/user-attachments/assets/d6268c82-9baa-4345-bd8a-0fa14a80ee14" alt="AnyTimeScan Image 1">
    <img src="https://github.com/user-attachments/assets/e121b3a0-567f-46ef-a4b8-34ecdc144170" alt="AnyTimeScan Image 2">
    <img src="https://github.com/user-attachments/assets/7e93cfd5-40ba-427f-9da7-ba076d34a45d" alt="AnyTimeScan Image 3">
</div>

## Key Features

- **Automated Image Capture**: Takes images every 2 seconds until stopped.
- **Cloud Upload**: Images are uploaded to Cloudinary for server-side processing.
- **STL File Generation**: Generates 3D models (STL files) from images, viewable within the app.
- **Project Organization**: Users can create separate projects for each object.

## How It Works

1. **Project Creation**: Users start by creating a project for each object.
2. **Image Capture**: The app automatically captures photos at regular intervals.
3. **Cloud Integration**: Photos are uploaded to Cloudinary, and the STL file is generated and stored.
4. **STL Viewing**: The generated 3D model can be viewed directly in-app.


<div align="center">
    <img src="https://github.com/user-attachments/assets/372e1345-716a-49dd-a5b8-c6da597d12a1" alt="AnyTimeScan STL Image">
</div>

## Setup

1. Clone the repository:
   ```bash
   git clone https://github.com/ayush-beniwal/AnyTimeScan.git
2. Install Dependencies:
    ```bash
    flutter pub get
3. Run the App:
   ```bash
   flutter run
