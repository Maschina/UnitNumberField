import SwiftUI

struct ContentView: View {
	@State var value: Double = 100
	
	func doubleFormatter(digits: Int = 1) -> NumberFormatter {
		let formatter = NumberFormatter()
		formatter.maximumFractionDigits = digits
		return formatter
	}
	
    var body: some View {
		HStack {
			UnitNumberField(value: $value, unitText: "%", range: 0...100, formatter: doubleFormatter(digits: 0), bezelStyle: .roundedBezel, controlSize: .small)
				.frame(width: 50)
			
			Spacer()
		}
	}
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
			.frame(width: 300)
			.padding()
    }
}
