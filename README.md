
[![Swift Version][swift-image]][swift-url]
[![Build Status][travis-image]][travis-url]
[![License][license-image]][license-url]
[![Platform](https://img.shields.io/cocoapods/p/LFAlertController.svg?style=flat)](http://cocoapods.org/pods/LFAlertController)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg?style=flat-square)](http://makeapullrequest.com)

# Gymbo
![Alt text](Gymbo/Assets.xcassets/AppIcon.appiconset/AppIcon-60.png?raw=true "Title")
<br />
<p align="left">
  <p align="left">
    Gymbo is a basic iOS app that tries to utilize the MVVM architecture using Swift.
  </p>
  <p align="left">
    The app allows you to choose from a list of over 200 pre-loaded exercises and add them to what I call sessions. Sessions consist of one or
    more exercises that you would like to complete during your time at the gym. You can also create your own exercises. You can create a name for your
    new exercise, add the muscle groups it affects, and you can even take some pictures to help you visualize how to perform the exercise in case you
    forget in the future. Once you have your sessions created, you can tap on any one of them and start a session. This new screen will keep track of the
    duration of your session and you can edit your exercises while you are in the middle of your session. The dashboard section of the app will keep
    track of all the sessions you have completed and the days you have worked out. Profile allows you to tell the app a little bit about yourself.
  p</>
  <p align="left">
    The app uses no 3rd party libraries other than RealmSwift which allows storing data completely on the device for long-term persistence.
  </p>
</p>

## Features

- [x] Profile
<p align="left">
  <p align="left">
    Access/edit basic settings in Profile. Ability to upload user profile picture.
  </p>
</p>
<p align="row">
<img src= "https://github.com/sharmaro/Gymbo/blob/master/README_Assets/Profile.png" width="200" height="400">
<img src= "https://github.com/sharmaro/Gymbo/blob/master/README_Assets/Settings.png" width="200" height="400">
</p>

- [x] Dashboard
<p align="left">
  <p align="left">
    View sessions completed in the past along with the days those sessions were completed. Filter by date on session days.
  </p>
</p>
<p align="row">
<img src= "https://github.com/sharmaro/Gymbo/blob/master/README_Assets/Dashboard.png" width="200" height="400">
</p>

- [x] Sessions
<p align="left">
  <p align="left">
    View all sessions previously created. Tap on a session to preview the exercises that session contains.
  </p>
</p>
<p align="row">
<img src= "https://github.com/sharmaro/Gymbo/blob/master/README_Assets/Sessions.png" width="200" height="400">
<img src= "https://github.com/sharmaro/Gymbo/blob/master/README_Assets/Session%20preview.png" width="200" height="400">
</p>

- [x] Started Session
<p align="left">
  <p align="left">
    Start a session and tap on exercises as you complete them. This turns them green and allows user to have a visual of completed exercises.
    Tap on exercise name to mark entire exercise as completed.
  </p>
  <p align="left">
    User can also start a timer to time a resting period. Rest timer will show up in started session navigation bar if the rest timer
    screen is dismissed.
  </p>
</p>
<p align="row">
<img src= "https://github.com/sharmaro/Gymbo/blob/master/README_Assets/Start%20session.png" width="200" height="400">
<img src= "https://github.com/sharmaro/Gymbo/blob/master/README_Assets/Timer.png" width="200" height="400">
<img src= "https://github.com/sharmaro/Gymbo/blob/master/README_Assets/Start%20session%20with%20timer.png" width="200" height="400">
</p>

- [x] My Exercises
<p align="left">
  <p align="left">
    Access/edit/add exercises from this tab.
  </p>
</p>
<p align="row">
<img src= "https://github.com/sharmaro/Gymbo/blob/master/README_Assets/My%20exercises.png" width="200" height="400">
<img src= "https://github.com/sharmaro/Gymbo/blob/master/README_Assets/Create%20exercise.png" width="200" height="400">
</p>

- [x] Stopwatch
<p align="left">
  <p align="left">
    Simple stopwatch for additional utility. It works even if you leave the app or the app is terminated by the os.
  </p>
</p>
<p align="row">
<img src= "https://github.com/sharmaro/Gymbo/blob/master/README_Assets/Stopwatch.png" width="200" height="400">
</p>

## Requirements

- iOS 13.0+
- Xcode 11+

## Installation

#### Manually
You can download the source code directly.

Run `pod install` to download the latest RealmSwift

[Rohan's GitHub](https://github.com/sharmaro)

[swift-image]:https://img.shields.io/badge/swift-5.0-orange.svg
[swift-url]: https://swift.org/
[license-image]: https://img.shields.io/badge/License-MIT-blue.svg
[license-url]: LICENSE
[travis-image]: https://img.shields.io/travis/dbader/node-datadog-metrics/master.svg?style=flat-square
[travis-url]: https://travis-ci.org/dbader/node-datadog-metrics
