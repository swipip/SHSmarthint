
# SHSmarthint


[![Build Status](https://travis-ci.com/swipip/SHSmarthint.svg?branch=main)](https://travis-ci.com/swipip/SHSmarthint.svg?branch=main})

## Basic integration

Add the framework to your project with the following command.

```ruby
pod 'SmartHint', '~> 1.0.1'
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

## Build custom hint

You can create custom hints by using the Hint object's properties

### Custom Hint

Change core hint properties like background color, or text color, message or presentation animation style like this:

```swift
let hint = Hint(style: .banner(.bottom))
hint.backgroundColor = .white
hint.buttonsColor = .systemGray6
hint.message = "This is my banner's message"
hint.animationStyle = .fromTop
```
### Adding a textField in an AlertView

Uniquely available to alerts, you can choose to display a textField inside the view. The following example shows how to tell SmartHint you need a textField and how to subscribe to its events.

```swift
let hint = Hint(style: .alert)
hint.hasTextField = { [weak self] textField in
   textField.delegate = self
   return true
}
```

The view you are assigning the delegate to must conform to UITextFieldDelegate. Do this like so:

```swift
extension YourViewController: UITextFieldDelegate {
    func textFieldDidChangeSelection(_ textField: UITextField) {
        //Respond to changes
    }
}
```

### Adding buttons

To add a button you simply need to pass a completion handler to the addAction(_ action: HintAction) method. Let's say you need to add two buttons:

```swift
let hint = Hint(style: .banner(.bottom))
hint.addAction(HintAction(title: "first button", handler: {
    //Do something when the first buttn gets tapped
}))
hint.addAction(HintAction(title: "second button", handler: {
    //Do something when the second button gets tapped
}))
```

### Modifying core properties

Should you need to update some of HintViews core properties to fit the layout style to you app's, you cna do using the setDefaultValue(_ value: Any, forKey key: ConstantName) method provided by the SmartHint viewController's extension.

```swift
sh.setDefaultValue(CGFloat(12), forKey: .hintViewCornerRadius)
sh.setDefaultValue(CGFloat(8), forKey: .buttonsCornerRadius)
```

Note that you MUST indicate to right type for the value your are modifying otherwise the module will raise an exception. So for instance provide a CGFloat for view layout related values and a Double for the animation timing for instance
