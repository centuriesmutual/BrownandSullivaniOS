import SwiftUI

/// Home tab — mirrors `dashboard/page.tsx` (tasks + calendar month + upcoming events).
struct CampaignDashboardView: View {
    @EnvironmentObject private var app: AppState
    @State private var displayedMonth: Date = Date()
    @State private var selectedDay: Int?
    @State private var showAllTasks = false
    @State private var showNewEvent = false
    @State private var newTitle = ""
    @State private var newTime = ""
    @State private var newType: PressEventKind = .meeting
    @State private var taskDetail: MarketingTaskItem?
    @State private var taskStatusPick = "In Progress"

    private let calendar = Calendar.current
    private let weekdayLetters: [(Int, String)] = [
        (0, "S"), (1, "M"), (2, "T"), (3, "W"), (4, "T"), (5, "F"), (6, "S")
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                calendarCard
                tasksCard
                upcomingEventsCard
            }
            .padding(.vertical, 8)
        }
        .background(PressBoxTheme.background)
        .sheet(isPresented: $showAllTasks) {
            NavigationStack {
                List(app.marketingTasks) { t in
                    Button {
                        taskDetail = t
                        taskStatusPick = t.status
                        showAllTasks = false
                    } label: {
                        taskRowContent(t)
                    }
                }
                .navigationTitle("All tasks")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Done") { showAllTasks = false }
                    }
                }
            }
        }
        .sheet(item: $taskDetail) { task in
            NavigationStack {
                Form {
                    Section("Task") {
                        Text(task.title).font(.headline)
                        Text(task.description)
                            .font(.subheadline)
                            .foregroundStyle(PressBoxTheme.textSecondary)
                        LabeledContent("Due", value: task.dueDate)
                        LabeledContent("Priority", value: task.priority)
                        LabeledContent("From", value: task.assignedBy)
                    }
                    Section("Status") {
                        Picker("Update status", selection: $taskStatusPick) {
                            Text("Not Started").tag("Not Started")
                            Text("In Progress").tag("In Progress")
                            Text("Completed").tag("Completed")
                        }
                    }
                }
                .navigationTitle("Task detail")
                .navigationBarTitleDisplayMode(.inline)
                .onAppear { taskStatusPick = task.status }
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Close") { taskDetail = nil }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Save") {
                            app.updateMarketingTask(id: task.id, status: taskStatusPick)
                            taskDetail = nil
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showNewEvent) {
            NavigationStack {
                Form {
                    Section("Event") {
                        TextField("Title", text: $newTitle)
                        TextField("Time (e.g. 2:00 PM)", text: $newTime)
                        Picker("Type", selection: $newType) {
                            Text("Meeting").tag(PressEventKind.meeting)
                            Text("Review").tag(PressEventKind.review)
                            Text("Event").tag(PressEventKind.event)
                        }
                    }
                    if let selectedDay {
                        let comp = calendar.dateComponents([.year, .month], from: displayedMonth)
                        if let first = calendar.date(from: comp),
                           let date = calendar.date(byAdding: .day, value: selectedDay - 1, to: first) {
                            Text("Date: \(CampaignDateFormat.displayLabel(yyyyMMdd: CampaignDateFormat.storageString(from: date)))")
                                .font(.footnote)
                        }
                    }
                }
                .navigationTitle("New event")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") { showNewEvent = false }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Save") {
                            saveEvent()
                        }
                        .disabled(newTitle.isEmpty || newTime.isEmpty || selectedDay == nil)
                    }
                }
            }
        }
    }

    private var calendarCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Button { shiftMonth(-1) } label: {
                    Image(systemName: "chevron.left.circle.fill").font(.title3).foregroundStyle(PressBoxTheme.indigo)
                }
                Spacer()
                Text(monthTitle)
                    .font(.headline)
                Spacer()
                Button { shiftMonth(1) } label: {
                    Image(systemName: "chevron.right.circle.fill").font(.title3).foregroundStyle(PressBoxTheme.indigo)
                }
            }
            weekdayRow
            calendarGrid
        }
        .padding(16)
        .pressBoxCard()
        .padding(.horizontal, 16)
    }

    private var weekdayRow: some View {
        HStack {
            ForEach(weekdayLetters, id: \.0) { _, d in
                Text(d).font(.caption2.weight(.semibold))
                    .foregroundStyle(PressBoxTheme.textSecondary)
                    .frame(maxWidth: .infinity)
            }
        }
    }

    private var calendarGrid: some View {
        let days = monthCells
        return LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 4), count: 7), spacing: 6) {
            ForEach(Array(days.enumerated()), id: \.offset) { _, cell in
                if let day = cell {
                    dayCell(day)
                } else {
                    Color.clear.frame(height: 40)
                }
            }
        }
    }

    private func dayCell(_ day: Int) -> some View {
        let count = eventsCount(on: day)
        let today = isToday(day)
        let selected = selectedDay == day
        return Button {
            selectedDay = day
            newTitle = ""
            newTime = ""
            showNewEvent = true
        } label: {
            VStack(spacing: 4) {
                Text("\(day)")
                    .font(.subheadline.weight(today ? .bold : .medium))
                if count > 0 {
                    HStack(spacing: 2) {
                        ForEach(0..<min(count, 3), id: \.self) { _ in
                            Circle().fill(PressBoxTheme.indigo).frame(width: 4, height: 4)
                        }
                    }
                } else {
                    Color.clear.frame(height: 4)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 44)
            .background(
                selected
                ? PressBoxTheme.indigo.opacity(0.2)
                : (today ? PressBoxTheme.indigoLight : PressBoxTheme.background)
            )
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(today ? PressBoxTheme.indigo : Color.clear, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    private var tasksCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("My Tasks").font(.headline)
                Spacer()
                Button("View All") {
                    showAllTasks = true
                }
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(PressBoxTheme.indigo)
            }
            ForEach(Array(app.marketingTasks.prefix(3))) { task in
                Button {
                    taskDetail = task
                    taskStatusPick = task.status
                } label: {
                    taskRowSummary(task)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(16)
        .pressBoxCard()
        .padding(.horizontal, 16)
    }

    private var upcomingEventsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Upcoming Events").font(.headline)
            ForEach(app.campaignEvents.sorted(by: { $0.date < $1.date })) { ev in
                let label = CampaignDateFormat.displayLabel(yyyyMMdd: ev.date)
                let isToday = label == "Today"
                HStack(spacing: 12) {
                    Image(systemName: ev.type.icon)
                        .foregroundStyle(ev.type.tint)
                        .padding(10)
                        .background(ev.type.tint.opacity(isToday ? 0.25 : 0.12))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(ev.title).font(.subheadline.weight(.semibold))
                            if isToday {
                                Text("Today")
                                    .font(.caption2.weight(.bold))
                                    .padding(.horizontal, 6).padding(.vertical, 2)
                                    .background(PressBoxTheme.indigoLight)
                                    .foregroundStyle(PressBoxTheme.indigoDark)
                                    .clipShape(Capsule())
                            }
                        }
                        Text("\(label) • \(ev.time)")
                            .font(.caption)
                            .foregroundStyle(isToday ? PressBoxTheme.indigo : PressBoxTheme.textSecondary)
                    }
                    Spacer()
                }
                .padding(10)
                .background(isToday ? PressBoxTheme.indigoLight.opacity(0.5) : Color.clear)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(isToday ? PressBoxTheme.indigo.opacity(0.3) : Color.clear)
                )
            }
        }
        .padding(16)
        .pressBoxCard()
        .padding(.horizontal, 16)
    }

    private var monthTitle: String {
        let f = DateFormatter()
        f.dateFormat = "LLLL yyyy"
        return f.string(from: displayedMonth)
    }

    private func shiftMonth(_ d: Int) {
        if let m = calendar.date(byAdding: .month, value: d, to: displayedMonth) {
            displayedMonth = m
        }
    }

    private var monthCells: [Int?] {
        let comp = calendar.dateComponents([.year, .month], from: displayedMonth)
        guard let first = calendar.date(from: comp),
              let range = calendar.range(of: .day, in: .month, for: first)
        else { return [] }
        let padding = calendar.component(.weekday, from: first) - 1
        var cells: [Int?] = Array(repeating: nil, count: padding)
        for day in range {
            cells.append(day)
        }
        while cells.count % 7 != 0 { cells.append(nil) }
        return cells
    }

    private func dateString(year: Int, month: Int, day: Int) -> String {
        String(format: "%04d-%02d-%02d", year, month, day)
    }

    private func eventsCount(on day: Int) -> Int {
        let y = calendar.component(.year, from: displayedMonth)
        let m = calendar.component(.month, from: displayedMonth)
        let ds = dateString(year: y, month: m, day: day)
        return app.campaignEvents.filter { $0.date == ds }.count
    }

    private func isToday(_ day: Int) -> Bool {
        let y = calendar.component(.year, from: displayedMonth)
        let m = calendar.component(.month, from: displayedMonth)
        guard let d = calendar.date(from: DateComponents(year: y, month: m, day: day)) else { return false }
        return calendar.isDateInToday(d)
    }

    @ViewBuilder
    private func taskRowSummary(_ task: MarketingTaskItem) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(task.title).font(.subheadline.weight(.medium))
                Text("Due: \(task.dueDate) • \(task.priority) Priority")
                    .font(.caption)
                    .foregroundStyle(PressBoxTheme.textSecondary)
            }
            Spacer()
            Text(task.status)
                .font(.caption2.weight(.semibold))
                .padding(.horizontal, 8).padding(.vertical, 4)
                .background(PressBoxTheme.chip(for: task.status).0)
                .foregroundStyle(PressBoxTheme.chip(for: task.status).1)
                .clipShape(Capsule())
        }
        .padding(12)
        .background(PressBoxTheme.background)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    @ViewBuilder
    private func taskRowContent(_ t: MarketingTaskItem) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(t.title).font(.headline)
            Text(t.description).font(.caption).foregroundStyle(PressBoxTheme.textSecondary)
            HStack {
                Text("Due: \(t.dueDate)").font(.caption2)
                Text("•").font(.caption2)
                Text("\(t.priority) priority").font(.caption2)
            }
            Text(t.status).font(.caption2.weight(.semibold))
                .padding(.horizontal, 8).padding(.vertical, 4)
                .background(PressBoxTheme.chip(for: t.status).0)
                .foregroundStyle(PressBoxTheme.chip(for: t.status).1)
                .clipShape(Capsule())
        }
        .padding(.vertical, 4)
    }

    private func saveEvent() {
        guard let day = selectedDay else { return }
        let y = calendar.component(.year, from: displayedMonth)
        let m = calendar.component(.month, from: displayedMonth)
        guard let date = calendar.date(from: DateComponents(year: y, month: m, day: day)) else { return }
        app.addCampaignEvent(title: newTitle, time: newTime, on: date, type: newType)
        showNewEvent = false
        newTitle = ""
        newTime = ""
    }
}

#Preview {
    NavigationStack {
        CampaignDashboardView().environmentObject(AppState())
    }
}
