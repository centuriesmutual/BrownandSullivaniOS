import SwiftUI

struct AdminView: View {
    @EnvironmentObject private var app: AppState
    @State private var section: Section = .overview

    enum Section: String, CaseIterable, Identifiable {
        case overview = "Overview"
        case users = "Users"
        case system = "System"
        case activity = "Activity"
        var id: String { rawValue }

        var icon: String {
            switch self {
            case .overview: "gauge.with.dots.needle.67percent"
            case .users: "person.3.fill"
            case .system: "server.rack"
            case .activity: "list.bullet.clipboard"
            }
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                segmentedHeader
                ScrollView {
                    Group {
                        switch section {
                        case .overview: overview
                        case .users:    usersList
                        case .system:   systemPanel
                        case .activity: activityFeed
                        }
                    }
                    .padding(Theme.spacing.l)
                }
            }
            .background(Theme.color.background.ignoresSafeArea())
            .navigationTitle("Admin")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    HStack(spacing: 6) {
                        Image(systemName: "shield.lefthalf.filled")
                            .foregroundStyle(Theme.color.danger)
                        Text("Admin")
                            .font(.headline)
                            .foregroundStyle(Theme.color.textPrimary)
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button { app.backToOffice() } label: {
                            Label("Back to Office", systemImage: "briefcase.fill")
                        }
                        Button(role: .destructive) { app.signOut() } label: {
                            Label("Sign Out", systemImage: "rectangle.portrait.and.arrow.right")
                        }
                    } label: {
                        Avatar(initials: app.userInitials, size: 32,
                               gradient: [Theme.color.danger, Color(hex: 0xB91C1C)])
                    }
                }
            }
        }
    }

    private var segmentedHeader: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(Section.allCases) { s in
                    Button { section = s } label: {
                        Label(s.rawValue, systemImage: s.icon)
                            .font(.subheadline.weight(.semibold))
                            .padding(.horizontal, 14).padding(.vertical, 8)
                            .background(section == s ? Theme.color.primary : Theme.color.surfaceMuted)
                            .foregroundStyle(section == s ? Color.white : Theme.color.textPrimary)
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, Theme.spacing.l)
            .padding(.vertical, 10)
        }
        .background(Color.white)
    }

    // MARK: - Overview

    private var overview: some View {
        VStack(spacing: Theme.spacing.l) {
            userStatsGrid
            systemMetricsCard
            quickStatusCard
        }
    }

    private var userStatsGrid: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 2),
                  spacing: 12) {
            statTile("Total users",    "\(app.userStats.total)",    "person.3.fill",       Theme.color.primary)
            statTile("Active",         "\(app.userStats.active)",   "person.fill.checkmark",Theme.color.success)
            statTile("New today",      "\(app.userStats.newToday)", "person.fill.badge.plus",Theme.color.info)
            statTile("Premium",        "\(app.userStats.premium)",  "star.fill",            Theme.color.warning)
        }
    }

    private func statTile(_ title: String, _ value: String, _ icon: String, _ color: Color) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                ZStack {
                    RoundedRectangle(cornerRadius: 10).fill(color.opacity(0.15))
                    Image(systemName: icon).foregroundStyle(color)
                }
                .frame(width: 40, height: 40)
                Spacer()
            }
            Text(value).font(.system(size: 22, weight: .bold))
            Text(title).font(.caption).foregroundStyle(Theme.color.textSecondary)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .dashboardCardStyle()
    }

    private var systemMetricsCard: some View {
        TitledCard("System metrics", icon: "cpu.fill") {
            VStack(spacing: 14) {
                metricRow("CPU",     percent: app.systemMetrics.cpu,     color: Theme.color.info)
                metricRow("Memory",  percent: app.systemMetrics.memory,  color: Theme.color.success)
                metricRow("Disk",    percent: app.systemMetrics.disk,    color: Theme.color.warning)
                metricRow("Network", percent: app.systemMetrics.network, color: Theme.color.primary)
            }
        }
    }

    private func metricRow(_ name: String, percent: Int, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(name).font(.subheadline)
                Spacer()
                Text("\(percent)%").font(.subheadline.weight(.semibold)).foregroundStyle(color)
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4).fill(Theme.color.border.opacity(0.5))
                    RoundedRectangle(cornerRadius: 4)
                        .fill(color)
                        .frame(width: max(0, geo.size.width * Double(percent) / 100))
                }
            }
            .frame(height: 8)
        }
    }

    private var quickStatusCard: some View {
        TitledCard("Component status", icon: "checkmark.shield.fill") {
            VStack(spacing: 8) {
                ForEach(app.systemStatus) { comp in
                    HStack(spacing: 12) {
                        Image(systemName: comp.icon).foregroundStyle(Theme.color.primary)
                            .frame(width: 28)
                        Text(comp.name).font(.subheadline.weight(.medium))
                        Spacer()
                        ChipBadge(text: comp.status.label, color: comp.status.color)
                    }
                    .padding(.vertical, 6)
                    if comp.id != app.systemStatus.last?.id {
                        Divider()
                    }
                }
            }
        }
    }

    // MARK: - Users

    private var usersList: some View {
        TitledCard("Users", icon: "person.3.fill") {
            VStack(spacing: 0) {
                ForEach(Array(app.adminUsers.enumerated()), id: \.element.id) { idx, user in
                    HStack(spacing: 12) {
                        Avatar(initials: String(user.name.prefix(2)), size: 40)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(user.name).font(.subheadline.weight(.semibold))
                            Text(user.email).font(.caption).foregroundStyle(Theme.color.textSecondary)
                            HStack(spacing: 6) {
                                ChipBadge(text: user.role,
                                          color: roleColor(user.role))
                                ChipBadge(text: user.status,
                                          color: statusColor(user.status))
                            }
                        }
                        Spacer()
                        Text(user.lastActive)
                            .font(.caption2)
                            .foregroundStyle(Theme.color.textSecondary)
                    }
                    .padding(.vertical, 10)
                    if idx < app.adminUsers.count - 1 { Divider() }
                }
            }
        }
    }

    private func roleColor(_ role: String) -> Color {
        switch role {
        case "Admin": Theme.color.danger
        case "Manager": Theme.color.warning
        case "Agent": Theme.color.info
        default: Theme.color.secondary
        }
    }

    private func statusColor(_ status: String) -> Color {
        switch status {
        case "Active": Theme.color.success
        case "Idle": Theme.color.warning
        case "Offline": Theme.color.secondary
        default: Theme.color.primary
        }
    }

    // MARK: - System

    private var systemPanel: some View {
        VStack(spacing: Theme.spacing.l) {
            quickStatusCard
            systemMetricsCard

            TitledCard("Maintenance", icon: "wrench.and.screwdriver.fill") {
                VStack(spacing: 8) {
                    maintenanceRow("Clear cache", "trash.fill", Theme.color.warning)
                    maintenanceRow("Reindex search", "magnifyingglass.circle.fill", Theme.color.info)
                    maintenanceRow("Run health check", "heart.text.square.fill", Theme.color.success)
                    maintenanceRow("Restart API", "arrow.triangle.2.circlepath.circle.fill", Theme.color.danger)
                }
            }
        }
    }

    private func maintenanceRow(_ title: String, _ icon: String, _ color: Color) -> some View {
        Button {} label: {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10).fill(color.opacity(0.15))
                    Image(systemName: icon).foregroundStyle(color)
                }
                .frame(width: 40, height: 40)
                Text(title).font(.subheadline.weight(.semibold))
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(Theme.color.textSecondary)
                    .font(.caption.weight(.bold))
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Activity

    private var activityFeed: some View {
        TitledCard("Recent activity", icon: "list.bullet.clipboard.fill") {
            VStack(spacing: 10) {
                ForEach(app.adminActivity) { item in
                    HStack(spacing: 12) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10).fill(item.kind.color.opacity(0.15))
                            Image(systemName: item.kind.icon).foregroundStyle(item.kind.color)
                        }
                        .frame(width: 36, height: 36)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(item.message).font(.subheadline.weight(.semibold))
                            HStack(spacing: 6) {
                                if let user = item.user {
                                    Text(user).font(.caption.weight(.semibold)).foregroundStyle(Theme.color.primary)
                                    Text("•").font(.caption).foregroundStyle(Theme.color.textSecondary)
                                }
                                Text(item.timestamp).font(.caption).foregroundStyle(Theme.color.textSecondary)
                            }
                        }
                        Spacer()
                    }
                    .padding(10)
                    .background(Theme.color.surfaceMuted)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
        }
    }
}

#Preview {
    AdminView().environmentObject(AppState())
}
