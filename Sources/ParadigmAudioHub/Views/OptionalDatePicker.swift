import SwiftUI

struct OptionalDatePicker: View {
    let title: String
    @Binding var date: Date?

    var body: some View {
        HStack {
            Toggle(isOn: Binding(
                get: { date != nil },
                set: { isOn in
                    if isOn {
                        date = date ?? Date()
                    } else {
                        date = nil
                    }
                }
            )) {
                Text(title)
            }
            .toggleStyle(.switch)
            if date != nil {
                DatePicker(\"\", selection: Binding(\n                    get: { date ?? Date() },\n                    set: { date = $0 }\n                ), displayedComponents: .date)\n            }
        }
    }
}
