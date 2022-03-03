# UnitNumberField
A customized text field for unit-based number input for SwiftUI and AppKit (macOS). Allows user to input numbers only and validates it, respectively.
Similar to the input field in Sketch.

![Screenshot](Sources/doc/screen1.png)

## Features

- Compatibility to SwiftUI and AppKit (macOS)
- Available for Double values only at the moment
- Inline label for unit
- Feedback closure if input is not valid
- Range control (clamp the given input to a certain range)
- Formatter control (validate the input towards a given formatter)
- Bezel style support
- Control size support

## Installation

Add https://github.com/Maschina/UnitNumberField in the [“Swift Package Manager” tab in Xcode](https://developer.apple.com/documentation/xcode/adding_package_dependencies_to_your_app).

## Requirements

macOS 10.15+

## Usage

Example for usage in SwiftUI **with** units:

```swift
UnitNumberField(
  value: proxy, 
  unitText: "°", 
  range: 0...360, 
  formatter: NumberFormatter.doubleFormatter(digits: 0), 
  bezelStyle: .roundedBezel, 
  controlSize: .small
  )
  .frame(width: 55)
```


Example for usage in SwiftUI **without** units:

```swift
UnitNumberField(
  value: proxy, 
  unitText: nil, 
  range: 0...360, 
  formatter: NumberFormatter.doubleFormatter(digits: 0), 
  bezelStyle: .roundedBezel, 
  controlSize: .small
  )
  .frame(width: 55)
```
