import SwiftUI

/// Sheet for logging a self-reported session.
struct LogSessionSheet: View {
    /// Called with start date and hours.
    let onLog: (Date, Double) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var startedAt = Date.now
    @State private var hours = 1.0

    var body: some View {
        Form {
            DatePicker("Started", selection: $startedAt)
            TextField("Hours", value: $hours, format: .number)
            PlaytimeSourceTag(source: .selfReported)
        }
        .formStyle(.grouped)
        .padding(DesignTokens.Spacing.lg)
        .frame(minWidth: DesignTokens.Layout.detailMinWidth)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
            ToolbarItem(placement: .confirmationAction) {
                Button("Log") {
                    onLog(startedAt, hours)
                    dismiss()
                }
                .disabled(hours <= 0)
            }
        }
    }
}

#Preview {
    LogSessionSheet { _, _ in }
}
