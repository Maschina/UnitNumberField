import SwiftUI
import AVFoundation // system sounds

/// A customized text field that allows numbers only and validates the user input
struct UnitNumberField: NSViewRepresentable {
	typealias NSViewType = CustomTextField
	
	@Binding var value: Double
	
	let unitText: String
	let range: ClosedRange<Double>
	let formatter: NumberFormatter
	let bezelStyle: NSTextField.BezelStyle
	let controlSize: NSControl.ControlSize
	let isValid: ((Bool) -> ())?
	
	/// Initializes the custom control
	/// - Parameters:
	///   - value: Binding to the value
	///   - unitText: Static text representation of the unit
	///   - range: Valid range for the user input
	///   - formatter: Valid format for the user input
	///   - isValid: Optional: Closure to determine if currently typed user input is already valid
	///   - bezelStyle: Optional: Bezel style
	///   - controlSize: Optional: Size of the control
	init(value: Binding<Double>, unitText: String, range: ClosedRange<Double>, formatter: NumberFormatter, isValid: ((Bool) -> ())? = nil, bezelStyle: NSTextField.BezelStyle = .squareBezel, controlSize: NSControl.ControlSize = .regular) {
		self._value = value
		self.unitText = unitText
		self.range = range
		self.formatter = formatter
		self.isValid = isValid
		self.bezelStyle = bezelStyle
		self.controlSize = controlSize
	}
	
	func makeNSView(context: Context) -> CustomTextField {
		let view = CustomTextField(frame: .zero, unitText: unitText, controlSize: controlSize)
		
		view.delegate = context.coordinator
		// Bezel style
		view.bezelStyle = bezelStyle
		// Font size
		view.font = .systemFont(ofSize: NSFont.systemFontSize(for: controlSize))
		
		return view
	}
	
	func updateNSView(_ nsView: CustomTextField, context: Context) {
		nsView.stringValue = formatter.string(for: value) ?? ""
	}
	
	func makeCoordinator() -> Coordinator {
		Coordinator(parent: self, initValue: value)
	}
	
	// MARK: User input Coordinator
	
	final class Coordinator : NSObject, NSTextFieldDelegate {
		let parent: UnitNumberField
		var lastValidInput: Double?
		
		init(parent: UnitNumberField, initValue: Double) {
			self.parent = parent
			self.lastValidInput = initValue
		}
		
		/// Validate text input using `formatter` and `range`
		/// - Parameter stringValue: String input
		/// - Returns: Returns output if valid, or `nil`
		private func validation(_ stringValue: String) -> Double? {
			// Formatter compliant?
			guard let value = parent.formatter.number(from: stringValue) else { return nil }
			let doubleValue = value.doubleValue
			// in range?
			if parent.range.contains(doubleValue) {
				return doubleValue
			} else {
				if parent.range.upperBound < doubleValue { return parent.range.upperBound }
				else { return parent.range.lowerBound }
			}
		}
		
		func controlTextDidChange(_ obj: Notification) {
			guard let textField = obj.object as? NSTextField else { return }
			let stringValue = textField.stringValue
			// feedback if current user input is valid
			parent.isValid?(validation(stringValue) != nil)
		}
		
		/// Validate when text input finished
		func controlTextDidEndEditing(_ obj: Notification) {
			guard let textField = obj.object as? NSTextField else { return }
			let stringValue = textField.stringValue
			
			guard let doubleValue = validation(stringValue) else {
				// input was not valid
				NSSound.beep()
				textField.stringValue = parent.formatter.string(for: lastValidInput) ?? ""
				return
			}
			// input valid
			lastValidInput = doubleValue
			textField.stringValue = parent.formatter.string(for: doubleValue) ?? ""
			parent.value = doubleValue
		}
		
		/// Listen for certain keyboard keys
		func control(_ control: NSControl, textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
			switch commandSelector {
				case #selector(NSStandardKeyBindingResponding.insertNewline(_:)): // RETURN
					textView.window?.makeFirstResponder(nil) // Blur cursor
					return true
					
				case #selector(NSStandardKeyBindingResponding.cancelOperation(_:)): // ESC
					guard let textField = control as? NSTextField else { return false }
					NSSound.beep()
					textField.stringValue = parent.formatter.string(for: lastValidInput) ?? ""
					return true
					
				default:
					return false
			}
		}
	}
	
	// MARK: Custom NSTextField
	
	/// Custom text field which includes a suffix label for the unit text
	class CustomTextField: NSTextField {
		private let suffixLabel: NSTextField
		
		convenience init(frame frameRect: NSRect, unitText: String, controlSize: NSControl.ControlSize = .regular) {
			self.init(frame: frameRect)
			
			self.controlSize = controlSize
			self.suffixLabel.stringValue = unitText
			self.suffixLabel.font = NSFont.boldSystemFont(ofSize: controlSize == .regular ? NSFont.systemFontSize : NSFont.smallSystemFontSize)
		}
		
		override init(frame frameRect: NSRect) {
			// Suffix label
			self.suffixLabel = NSTextField(labelWithString: "")
			self.suffixLabel.translatesAutoresizingMaskIntoConstraints = false
			self.suffixLabel.font = NSFont.boldSystemFont(ofSize: NSFont.systemFontSize)
			self.suffixLabel.drawsBackground = false
			
			// Super init
			super.init(frame: frameRect)
			
			// Text field modifications
			self.cell = CustomTextFieldCell(suffixLabelWidth: suffixLabel.intrinsicContentSize.width)
			self.usesSingleLineMode = true
			
			// Adding suffix label to view layers
			self.addSubview(self.suffixLabel)
			NSLayoutConstraint.activate([
				suffixLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -5),
				suffixLabel.firstBaselineAnchor.constraint(equalTo: self.firstBaselineAnchor)
			])
		}
		
		required init?(coder: NSCoder) {
			fatalError("init(coder:) has not been implemented")
		}
	}
	
	// MARK: Custom NSTextFieldCell
	
	/// Constraint field cell to give sufficient room to the unit label
	private class CustomTextFieldCell: NSTextFieldCell {
		var suffixLabelWidth: CGFloat?
		
		convenience init(suffixLabelWidth: CGFloat? = nil) {
			self.init(textCell: "")
			self.suffixLabelWidth = suffixLabelWidth
		}
		
		override init(textCell string: String) {
			super.init(textCell: string)
			
			self.isEditable = true
			self.isBordered = true
			self.drawsBackground = true
			self.isBezeled = true
			self.isSelectable = true
		}
		
		required init(coder: NSCoder) {
			fatalError("init(coder:) has not been implemented")
		}
		
		override func drawingRect(forBounds rect: NSRect) -> NSRect {
			let rectInset = NSRect(x: rect.origin.x, y: rect.origin.y, width: rect.size.width - (suffixLabelWidth ?? 10.0), height: rect.size.height)
			return super.drawingRect(forBounds: rectInset)
		}
	}
}


// MARK: - Previews

struct TextFieldPlusView: View {
	@State var value: Double = 0.0
	
	func doubleFormatter(digits: Int = 1) -> NumberFormatter {
		let formatter = NumberFormatter()
		formatter.maximumFractionDigits = digits
		return formatter
	}
	
	var body: some View {
		VStack {
			UnitNumberField(value: $value, unitText: "%", range: 0...100, formatter: doubleFormatter(digits: 0), bezelStyle: .roundedBezel, controlSize: .small)
		}
	}
}

struct TextFieldPlusView_Previews: PreviewProvider {
	static var previews: some View {
		TextFieldPlusView(value: 100)
			.preferredColorScheme(.light)
			.frame(width: 55)
			.padding()
		
		TextFieldPlusView(value: 100)
			.preferredColorScheme(.dark)
			.frame(width: 55)
			.padding()
	}
}
