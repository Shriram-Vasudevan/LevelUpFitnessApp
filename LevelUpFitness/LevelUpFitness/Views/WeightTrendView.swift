import SwiftUI
import Charts

struct WeightTrendView: View {
    @ObservedObject var trendManager = TrendManager.shared
    @Environment(\.dismiss) private var dismiss

    @State private var weight = ""

    private let accent = Color(hex: "0B5ED7")

    var body: some View {
        ZStack {
            Color(hex: "F3F5F8").ignoresSafeArea()

            ScrollView {
                VStack(spacing: 14) {
                    header
                    trendCard
                    addEntryCard
                    entriesCard
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
            }
        }
        .onAppear {
            Task {
                if trendManager.weightTrend.isEmpty {
                    await trendManager.getWeightTrend()
                }
            }
        }
        .navigationBarBackButtonHidden()
    }

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Weight Trend")
                    .font(.system(size: 30, weight: .bold))
                    .foregroundColor(Color(hex: "111827"))

                Text("Last 30 days")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(Color(hex: "6B7280"))
            }

            Spacer()

            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(Color(hex: "6B7280"))
                    .frame(width: 32, height: 32)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .stroke(Color.black.opacity(0.08), lineWidth: 1)
                    )
            }
            .buttonStyle(.plain)
        }
    }

    private var trendCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                metricBlock(title: "Current", value: latestWeightText)
                metricBlock(title: "30d Change", value: changeText, valueColor: changeColor)
                metricBlock(title: "Average", value: averageText)
            }

            if sortedTrendPoints.isEmpty {
                Text("No weight entries yet. Add your first measurement below.")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color(hex: "6B7280"))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(12)
                    .background(Color(hex: "F8FAFC"))
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            } else {
                Chart(sortedTrendPoints) { point in
                    AreaMark(
                        x: .value("Date", point.date),
                        y: .value("Weight", point.value)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [accent.opacity(0.2), accent.opacity(0.02)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )

                    LineMark(
                        x: .value("Date", point.date),
                        y: .value("Weight", point.value)
                    )
                    .foregroundStyle(accent)
                    .lineStyle(StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))

                    PointMark(
                        x: .value("Date", point.date),
                        y: .value("Weight", point.value)
                    )
                    .foregroundStyle(accent)
                }
                .frame(height: 220)
                .chartYScale(domain: yDomain)
                .chartYAxis {
                    AxisMarks(position: .leading)
                }
                .chartXAxis {
                    AxisMarks(values: .stride(by: .day, count: max(1, sortedTrendPoints.count / 4))) { _ in
                        AxisGridLine(stroke: StrokeStyle(lineWidth: 0.35, dash: [2]))
                        AxisTick()
                        AxisValueLabel(format: .dateTime.month(.abbreviated).day())
                    }
                }
            }
        }
        .padding(12)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .stroke(Color.black.opacity(0.08), lineWidth: 1)
        )
    }

    private func metricBlock(title: String, value: String, valueColor: Color = Color(hex: "111827")) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(Color(hex: "6B7280"))

            Text(value)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(valueColor)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(Color(hex: "F8FAFC"))
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private var addEntryCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Add Entry")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(Color(hex: "111827"))

            HStack(spacing: 10) {
                TextField("Enter weight (lbs)", text: $weight)
                    .keyboardType(.decimalPad)
                    .font(.system(size: 15, weight: .medium))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 11)
                    .background(Color(hex: "F8FAFC"))
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

                Button {
                    addWeight()
                } label: {
                    Text("Save")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 11)
                        .background(accent)
                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(12)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .stroke(Color.black.opacity(0.08), lineWidth: 1)
        )
    }

    private var entriesCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Latest Entries")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(Color(hex: "111827"))

            if sortedTrendPoints.isEmpty {
                Text("Entries will appear here once added.")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color(hex: "6B7280"))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(10)
                    .background(Color(hex: "F8FAFC"))
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            } else {
                ForEach(sortedTrendPoints.reversed().prefix(12)) { entry in
                    HStack {
                        Text(entry.date.formatted(.dateTime.month(.abbreviated).day().year()))
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(Color(hex: "6B7280"))

                        Spacer()

                        Text(String(format: "%.1f lbs", entry.value))
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(accent)
                    }
                    .padding(10)
                    .background(Color(hex: "F8FAFC"))
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                }
            }
        }
        .padding(12)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .stroke(Color.black.opacity(0.08), lineWidth: 1)
        )
    }

    private var sortedTrendPoints: [HealthDataPoint] {
        trendManager.weightTrend.sorted { $0.date < $1.date }
    }

    private var yDomain: ClosedRange<Double> {
        let values = sortedTrendPoints.map(\.value)
        guard let minValue = values.min(), let maxValue = values.max() else {
            return 0...250
        }

        let padding = max((maxValue - minValue) * 0.15, 2)
        return (minValue - padding)...(maxValue + padding)
    }

    private var latestWeightText: String {
        guard let latest = sortedTrendPoints.last?.value else {
            return "-"
        }
        return String(format: "%.1f lbs", latest)
    }

    private var changeText: String {
        guard let first = sortedTrendPoints.first?.value,
              let last = sortedTrendPoints.last?.value else {
            return "-"
        }

        let delta = last - first
        let prefix = delta >= 0 ? "+" : ""
        return String(format: "%@%.1f lbs", prefix, delta)
    }

    private var changeColor: Color {
        guard let first = sortedTrendPoints.first?.value,
              let last = sortedTrendPoints.last?.value else {
            return Color(hex: "6B7280")
        }

        if last > first { return Color(hex: "DC2626") }
        if last < first { return Color(hex: "059669") }
        return Color(hex: "6B7280")
    }

    private var averageText: String {
        guard !sortedTrendPoints.isEmpty else { return "-" }
        let average = sortedTrendPoints.map(\.value).reduce(0, +) / Double(sortedTrendPoints.count)
        return String(format: "%.1f lbs", average)
    }

    private func addWeight() {
        guard let value = Double(weight.trimmingCharacters(in: .whitespacesAndNewlines)) else { return }

        Task {
            await trendManager.addWeightToTrend(weight: value)
            weight = ""
            ToDoListManager.shared.weightAdded()
        }
    }
}

#Preview {
    WeightTrendView()
}
