# MUKUserNotificationViewController

[![CI Status](http://img.shields.io/travis/Muccy/MUKUserNotificationViewController.svg?style=flat)](https://travis-ci.org/Muccy/MUKUserNotificationViewController)
[![Version](https://img.shields.io/cocoapods/v/MUKUserNotificationViewController.svg?style=flat)](http://cocoadocs.org/docsets/MUKUserNotificationViewController)
[![License](https://img.shields.io/cocoapods/l/MUKUserNotificationViewController.svg?style=flat)](http://cocoadocs.org/docsets/MUKUserNotificationViewController)
[![Platform](https://img.shields.io/cocoapods/p/MUKUserNotificationViewController.svg?style=flat)](http://cocoadocs.org/docsets/MUKUserNotificationViewController)

MUKUserNotificationViewController is a container view controller which displays user notifications where status bar lives. Its functionality is highly inspired by Tweetbot. You will have features like:
* sticky notifications;
* temporary notifications with a custom duration;
* queue of notifications with rate limiting;
* customizable colors and text;
* tap and pan up gestures support.

## Usage

MUKUserNotificationViewController is easy to use. Probabily you want to use it as your root view controller and to set real content view controller as a child view controller. This library has been developed with view controller containment in mind, so it's easy to use it in that way, both programmatically and with storyboards.
To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Screenshots

[![Portrait Sticky Notification](http://i.imgur.com/K2uiyTyl.png)](http://i.imgur.com/K2uiyTy) [![Portrait Notification](http://i.imgur.com/gCnSEvLl.png)](http://imgur.com/gCnSEvL)
[![Landscape Notification](http://i.imgur.com/t9bLMB9l.png)](http://imgur.com/t9bLMB9)

## Installation

MUKUserNotificationViewController is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

    pod "MUKUserNotificationViewController"

## Author

Marco Muccinelli, muccymac@gmail.com

## License

MUKUserNotificationViewController is available under the MIT license. See the LICENSE file for more info.

