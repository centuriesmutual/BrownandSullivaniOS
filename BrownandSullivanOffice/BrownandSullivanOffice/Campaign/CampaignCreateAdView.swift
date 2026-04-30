import SwiftUI

/// `dashboard/create-ad/page.tsx`
struct CampaignCreateAdView: View {
    @State private var title = ""
    @State private var desc = ""
    @State private var mediaType = "image"
    @State private var targetUrl = ""
    @State private var budget = ""
    @State private var start = Date()
    @State private var end = Date().addingTimeInterval(86400 * 7)
    @State private var audience = ""
    @State private var placement = "social"
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Form {
            Section("Basics") {
                TextField("Ad title", text: $title)
                TextField("Destination URL", text: $targetUrl)
                    .keyboardType(.URL)
                    .textInputAutocapitalization(.never)
            }
            Section("Creative") {
                Picker("Media type", selection: $mediaType) {
                    Text("Image").tag("image")
                    Text("Video").tag("video")
                }
                TextField("Description", text: $desc, axis: .vertical)
                    .lineLimit(3...6)
            }
            Section("Targeting & budget") {
                TextField("Budget (USD)", text: $budget)
                    .keyboardType(.decimalPad)
                TextField("Audience", text: $audience)
                Picker("Placement", selection: $placement) {
                    Text("Social").tag("social")
                    Text("Search").tag("search")
                    Text("Display").tag("display")
                }
            }
            Section("Schedule") {
                DatePicker("Start", selection: $start, displayedComponents: .date)
                DatePicker("End", selection: $end, displayedComponents: .date)
            }
        }
        .navigationTitle("Create Ad")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Close") { dismiss() }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") { dismiss() }
                    .disabled(title.isEmpty || targetUrl.isEmpty)
            }
        }
    }
}

#Preview {
    NavigationStack { CampaignCreateAdView() }
}
