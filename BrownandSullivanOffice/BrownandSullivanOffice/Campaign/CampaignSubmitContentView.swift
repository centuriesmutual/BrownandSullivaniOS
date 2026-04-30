import SwiftUI

/// `dashboard/submit-content/page.tsx`
struct CampaignSubmitContentView: View {
    @EnvironmentObject private var app: AppState
    @State private var title = ""
    @State private var boxUrl = ""
    @State private var publishDate = Date()
    @State private var notes = ""
    @State private var showSubmittedToast = false

    private static let submittedAtFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .short
        return f
    }()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Submit Blog Post or Article")
                    .font(.title2.bold())
                if !app.contentSubmissions.isEmpty {
                    recentSection
                }
                Group {
                    fieldLabel("Title")
                    TextField("Headline", text: $title)
                        .textFieldStyle(.roundedBorder)

                    fieldLabel("Box document")
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "link")
                            TextField("Paste Box document URL", text: $boxUrl)
                                .keyboardType(.URL)
                                .textInputAutocapitalization(.never)
                        }
                        .padding()
                        .background(PressBoxTheme.background)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        Text("Share your Box document with edit access before submitting.")
                            .font(.caption)
                            .foregroundStyle(PressBoxTheme.textSecondary)
                    }

                    fieldLabel("Featured image")
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(PressBoxTheme.border, style: StrokeStyle(lineWidth: 1, dash: [8]))
                        .frame(height: 120)
                        .overlay(
                            VStack(spacing: 8) {
                                Image(systemName: "photo")
                                    .font(.largeTitle)
                                    .foregroundStyle(PressBoxTheme.textSecondary)
                                Text("Tap to attach (demo)")
                                    .font(.caption)
                                    .foregroundStyle(PressBoxTheme.textSecondary)
                            }
                        )

                    DatePicker("Publish date", selection: $publishDate, displayedComponents: [.date, .hourAndMinute])

                    fieldLabel("Notes")
                    TextEditor(text: $notes)
                        .frame(minHeight: 100)
                        .padding(8)
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(PressBoxTheme.border))
                }
                Button {
                    submit()
                } label: {
                    Text("Submit")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(PressBoxTheme.indigo)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .disabled(title.isEmpty || boxUrl.isEmpty)
            }
            .padding(16)
            .pressBoxCard()
            .padding(16)
        }
        .background(PressBoxTheme.background)
        .alert("Submitted", isPresented: $showSubmittedToast) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Your request is queued for review.")
        }
    }

    private var recentSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Recent submissions")
                .font(.subheadline.weight(.semibold))
            ForEach(app.contentSubmissions.prefix(5)) { sub in
                VStack(alignment: .leading, spacing: 4) {
                    Text(sub.title).font(.subheadline.weight(.medium))
                    HStack {
                        Text(Self.submittedAtFormatter.string(from: sub.submittedAt))
                        Spacer()
                        Text(sub.status)
                            .font(.caption2.weight(.semibold))
                            .padding(.horizontal, 8).padding(.vertical, 4)
                            .background(PressBoxTheme.chip(for: sub.status).0)
                            .foregroundStyle(PressBoxTheme.chip(for: sub.status).1)
                            .clipShape(Capsule())
                    }
                    .font(.caption)
                    .foregroundStyle(PressBoxTheme.textSecondary)
                }
                .padding(10)
                .background(PressBoxTheme.background)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
    }

    private func submit() {
        app.submitBlogContent(title: title, boxURL: boxUrl, publishDate: publishDate, notes: notes)
        title = ""
        boxUrl = ""
        notes = ""
        publishDate = Date()
        showSubmittedToast = true
    }

    private func fieldLabel(_ s: String) -> some View {
        Text(s).font(.subheadline.weight(.semibold))
    }
}

#Preview {
    NavigationStack { CampaignSubmitContentView().environmentObject(AppState()) }
}
