//
//  OnboardingPage.swift
//  Gymbo
//
//  Created by Rohan Sharma on 7/23/20.
//  Copyright © 2020 Rohan Sharma. All rights reserved.
//

import UIKit

enum OnboardingPage: String, CaseIterable {
    case welcome = "Welcome!"
    case myExercises = "My Exercises"
    case sessions = "Sessions"
    case stopwatch = "Stopwatch"
    case finish = "Awesome!"

    var image: UIImage {
        let imageName: String
        switch self {
        case .welcome, .finish:
            return UIImage()
        case .myExercises:
            imageName = "MyExercises_Onboarding"
        case .sessions:
            imageName = "Sessions_Onboarding"
        case .stopwatch:
            imageName = "Stopwatch_Onboarding"
        }
        return UIImage(named: imageName) ?? UIImage()
    }

    var info: String {
        let text: String
        switch self {
        case .welcome:
            text = "Hi there! To get started, swipe through the pages to learn more. If you want to skip the boring stuff and get straight to the workouts then swipe down!"
        case .myExercises:
            text = "Here, you can look through all the exercises, search for exercises, and even create some of your own! Tap to find out more about each exercise."
        case .sessions:
            text = "You can interact with all your sessions here. You can tap to view/edit them. You can delete them and add new ones by tapping +Exercises on the top right!"
        case .stopwatch:
            text = "The stopwatch allows you to...well...use a stopwatch!"
        case .finish:
            text = "You're done with the boring stuff. Swipe down to start working out!"
        }
        return text
    }
}
