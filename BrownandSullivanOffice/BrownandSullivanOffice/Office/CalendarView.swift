import SwiftUI

/// Renamed to avoid clashing with `SwiftUI.CalendarView`.
struct CalendarTabView: View {
    @EnvironmentObject private var app: AppState
    @State private var displayedMonth: Date = Date()
    @State private var selectedDate: Date = Calendar.current.startOfDay(for: Date())

    private let calendar = Calendar.current
    private let weekdaySymbols: [(id: Int, label: String)] = [
        (0, "S"), (1, "M"), (2, "T"), (3, "W"), (4, "T"), (5, "F"), (6, "S")
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: Theme.spacing.l) {
                monthHeader
                weekdays
                grid
                eventsCard
            }
            .padding(Theme.spacing.l)
        }
    }

    private var monthHeader: some View {
        HStack {
            Button { shiftMonth(-1) } label: {
                Image(systemName: "chevron.left")
                    .padding(8)
                    .background(Theme.color.surfaceMuted)
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
            Spacer()
            Text(monthTitle)
                .font(.title3.weight(.bold))
            Spacer()
            Button { shiftMonth(1) } label: {
                Image(systemName: "chevron.right")
                    .padding(8)
                    .background(Theme.color.surfaceMuted)
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
        }
    }

    private var weekdays: some View {
        HStack {
            ForEach(weekdaySymbols, id: \.id) { d in
                Text(d.label)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Theme.color.textSecondary)
                    .frame(maxWidth: .infinity)
            }
        }
    }

    private var grid: some View {
        let days = monthDays
        return LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 6), count: 7),
                         spacing: 6) {
            ForEach(Array(days.enumerated()), id: \.offset) { _, date in
                if let date {
                    dayCell(date)
                } else {
                    Color.clear.frame(height: 44)
                }
            }
        }
    }

    private func dayCell(_ date: Date) -> some View {
        let day = calendar.component(.day, from: date)
        let isToday = calendar.isDateInToday(date)
        let isSelected = calendar.isDate(date, inSameDayAs: selectedDate)
        let count = events(on: date).count
        return Button {
            selectedDate = calendar.startOfDay(for: date)
        } label: {
            VStack(spacing: 4) {
                Text("\(day)")
                    .font(.subheadline.weight(isToday ? .bold : .medium))
                    .foregroundStyle(isSelected ? .white : Theme.color.textPrimary)
                if count > 0 {
                    HStack(spacing: 2) {
                        ForEach(0..<min(count, 3), id: \.self) { _ in
                            Circle().fill(isSelected ? Color.white : Theme.color.primary)
                                .frame(width: 4, height: 4)
                        }
                    }
                } else {
                    Color.clear.frame(height: 4)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 44)
            .background(isSelected
                        ? AnyShapeStyle(Theme.gradient.primary)
                        : isToday
                          ? AnyShapeStyle(Theme.color.primary.opacity(0.10))
                          : AnyShapeStyle(Theme.color.surfaceMuted))
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .buttonStyle(.plain)
    }

    private var eventsCard: some View {
        TitledCard(eventTitle, icon: "calendar.badge.clock") {
            let dayEvents = events(on: selectedDate)
            if dayEvents.isEmpty {
                Text("No events scheduled.")
                    .font(.subheadline)
                    .foregroundStyle(Theme.color.textSecondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 8)
            } else {
                VStack(spacing: 10) {
                    ForEach(dayEvents) { event in
                        eventRow(event)
                    }
                }
            }
        }
    }

    private func eventRow(_ event: CalendarEvent) -> some View {
        HStack(spacing: 12) {
            Rectangle().fill(event.color).frame(width: 4)
                .clipShape(RoundedRectangle(cornerRadius: 2))
            VStack(alignment: .leading, spacing: 4) {
                Text(event.title).font(.subheadline.weight(.semibold))
                HStack(spacing: 10) {
                    Label(timeString(event.date),
                          systemImage: "clock")
                        .font(.caption)
                        .foregroundStyle(Theme.color.textSecondary)
                    if !event.location.isEmpty && event.location != "—" {
                        Label(event.location, systemImage: "mappin.and.ellipse")
                            .font(.caption)
                            .foregroundStyle(Theme.color.textSecondary)
                    }
                }
                if !event.participants.isEmpty {
                    Label(event.participants.joined(separator: ", "),
                          systemImage: "person.2.fill")
                        .font(.caption)
                        .foregroundStyle(Theme.color.textSecondary)
                }
            }
            Spacer()
            ChipBadge(text: event.kind.rawValue, color: event.color)
        }
        .padding(12)
        .background(event.color.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    // MARK: - Helpers

    private var monthTitle: String {
        let f = DateFormatter()
        f.dateFormat = "LLLL yyyy"
        return f.string(from: displayedMonth)
    }

    private var eventTitle: String {
        let f = DateFormatter()
        f.dateFormat = "EEEE, MMM d"
        return f.string(from: selectedDate)
    }

    private func timeString(_ d: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "h:mm a"
        return f.string(from: d)
    }

    private func shiftMonth(_ delta: Int) {
        if let new = calendar.date(byAdding: .month, value: delta, to: displayedMonth) {
            displayedMonth = new
        }
    }

    /// Returns 6 weeks worth of days. nil for cells outside the displayed month.
    private var monthDays: [Date?] {
        let comps = calendar.dateComponents([.year, .month], from: displayedMonth)
        guard let first = calendar.date(from: comps),
              let range = calendar.range(of: .day, in: .month, for: first)
        else { return [] }
        let weekday = calendar.component(.weekday, from: first) - 1   // Sunday = 0
        var cells: [Date?] = Array(repeating: nil, count: weekday)
        for d in range {
            if let date = calendar.date(byAdding: .day, value: d - 1, to: first) {
                cells.append(date)
            }
        }
        while cells.count % 7 != 0 { cells.append(nil) }
        return cells
    }

    private func events(on date: Date) -> [CalendarEvent] {
        app.events.filter { calendar.isDate($0.date, inSameDayAs: date) }
            .sorted(by: { $0.date < $1.date })
    }
}

#Preview {
    NavigationStack { CalendarTabView().environmentObject(AppState()) }
}
