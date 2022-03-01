# UnitNumberField
A customized text field for unit-based number for SwiftUI and AppKit (macOS). Allows number only and validates the user input.
Similar to the input field in Sketch.

Example for usage in SwiftUI:

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

## Features

- Compatibility to SwiftUI and AppKit (macOS)
- Available for Double values only at the moment
- Inline label for unit
- Feedback closure if input is not valid
- Range control (clamp the given input to a certain range)
- Formatter control (validate the input towards a given formatter)
- Bezel style support
- Control size support
