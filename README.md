# SHSmarthint


[![Build Status](https://travis-ci.com/swipip/SHSmarthint.svg?branch=main)](https://travis-ci.com/swipip/SHSmarthint.svg?branch=main})

## Basic integration

Add the framework to your project with the following command.

```ruby
pod 'SmartHint', '~> 1.0.0'
```

## How to use SH core features

First you must import the framework to the file your are working on:
```swift
import SmartHint
```
SmartHint offers a convenient way to add callOut and banners to certain views inside you view hierarchy.
To interact with the framework simply use the built in UIViewController extenion

```swift 
self.sh
```

### Banner

You can create add a banner bellow your UINavigationController's navBar like so:

```swift
 guard let targetView = navigationController?.navigationBar else {return}
 sh.addHint(hint: Hint(style: .banner(.bottom), message: "Hey this is a banner"), to: targetView) {
   //Respond to banner view's tap event
 }
```
An optional completion argument is triggered in reponse to a tap event on the banner.


### Callout

You can create add a callout bellow a given view like so:

```swift
sh.addHint(hint: Hint(style: .callout(.triangle), message: "Hey this is a callout"), to: targetView) {
 //Respond to banner view's tap event
}
```
An optional completion argument is triggered in reponse to a tap event on the callout.
