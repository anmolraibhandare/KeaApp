# KeaApp
Pet tracking iOS app that allows the users to: Sign in to the app, search for a dog breed and add random pet image, pin a location to get all the path from current locations.

### Overview
Features used in the application:\
`AVKit` - to place the video image on the main view controller\
`Firebase` - to sign in and sign up to the app\
`Core Data` - to persist user data in local memory\
`MapView` - to display paths for walking\
`DogAPI` - to search for random dog images and save them in the memory

### Requirements
- Xcode 11.4
- Swift 5

![](kea.gif)

### Setup
Clone the app to your local machine
KeaApp is built using Swift and Firebase. Dependencies are managed using CocoaPods.

1. Setup Firebase for the app to get `GoogleService-info.plist` file. Link to setup firebase can be found [here](https://firebase.google.com/docs/ios/setup)
2. Run `pod install` in the Source directory, open `.xcworkspace` file and build the project
3. Create a new database named `users` within your firebase account. Add a new Cloud Firestore collection `users` with firstname, lastname, uid, email and password
4. Your Firebase should now be linked with Kea, now run the project
5. The application should prompt to activate location services. Make sure to `Allow location services`. If not active, go to Settings -> Privacy -> Location Services -> Turn on or enable `While using the App`

  > **_NOTE:_** - *Please make sure to setup Firebase and to activate location services to run the application as intended.*\
  *To check persistence, you can close the app within the simulator by holding `Command ⌘` + `Shift` + Double tapping 'H'*

### User Flow
1. Sign Up -> Pin and view walking paths -> Add Pet 
2. Crash the app to see if the data is persisted
2. Log in with same email id and password

### Authentication
#### Sign Up
1. Click on a "Sign Up" button
2. Provide first and last name, email and password (password should contain at least 8 characters, including letters, numbers and special characters)
3. Click on a "Sign Up" button below

#### Login
1. Click on a "Login" button
2. Provide email and password used to sign up before.
3. Click on a "Login" button below.

### View Paths
1. Move the pin (center) to place the location on the map where you need to take your pet for a walk
2. Click on the "Walk" button located at the buttom right corner
3. This show different paths you can take with walking the dog

### View and Add Pets
1. Click on your name at the bottom of the screen
2. You could see your pet list, click the "Plus" button at buttom right to add a new pet
3. Select the breed of your dog from the picker view for random dog images of the breed
4. Click "Add pet" once you are done with the selection

### UX Study
This app is inspired by my User Experience Nanodegree Final project (Kea - Pet Tracking Application). 

- [Github Link](https://github.com/anmolraibhandare/Kea)
- [Case Study](https://github.com/anmolraibhandare/Kea/blob/master/Kea%20-%20Case%20Study.pdf)
- [Prototype Link](https://www.figma.com/proto/fn7K4NfOouOafKMWGQig96/Kea?node-id=291%3A755&scaling=scale-down)
- [Project Link](https://www.figma.com/file/fn7K4NfOouOafKMWGQig96/Kea?node-id=291%3A0)

### Technologies Used In Application:
- AVKit
- Stack Views
- Auto Layout
- UIKit
- CoreData
- Networking
- Table View
- Navigation & Tab Controllers





