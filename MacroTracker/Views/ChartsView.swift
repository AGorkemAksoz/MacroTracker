import SwiftUI

struct ChartsView: View {
    @ObservedObject var homeViewModel: HomeViewModel
    @State private var selectedTab: Int = 1 // 0: Daily, 1: Weekly, 2: Monthly
    
    // Helper to get last 7 days
    var last7Days: [Date] {
        let calendar = Calendar.current
        return (0..<7).map { offset in
            calendar.date(byAdding: .day, value: -offset, to: Date())!
        }.reversed()
    }
    // Helper to get previous 7 days
    var previous7Days: [Date] {
        let calendar = Calendar.current
        return (7..<14).map { offset in
            calendar.date(byAdding: .day, value: -offset, to: Date())!
        }.reversed()
    }
    
    var caloriesData: [Double] {
        last7Days.map { day in
            homeViewModel.getMealsForDate(day).reduce(0) { $0 + $1.calories }
        }
    }
    var proteinData: [Double] {
        last7Days.map { day in
            homeViewModel.getMealsForDate(day).reduce(0) { $0 + $1.proteinG }
        }
    }
    var fatData: [Double] {
        last7Days.map { day in
            homeViewModel.getMealsForDate(day).reduce(0) { $0 + $1.fatTotalG }
        }
    }
    // Previous 7 days data
    var prevCaloriesData: [Double] {
        previous7Days.map { day in
            homeViewModel.getMealsForDate(day).reduce(0) { $0 + $1.calories }
        }
    }
    var prevProteinData: [Double] {
        previous7Days.map { day in
            homeViewModel.getMealsForDate(day).reduce(0) { $0 + $1.proteinG }
        }
    }
    var prevFatData: [Double] {
        previous7Days.map { day in
            homeViewModel.getMealsForDate(day).reduce(0) { $0 + $1.fatTotalG }
        }
    }
    // Dynamic percentage change
    var caloriesChange: Int {
        let prevAvg = prevCaloriesData.isEmpty ? 0 : prevCaloriesData.reduce(0, +) / Double(prevCaloriesData.count)
        let currAvg = caloriesData.isEmpty ? 0 : caloriesData.reduce(0, +) / Double(caloriesData.count)
        guard prevAvg != 0 else { return 0 }
        return Int(((currAvg - prevAvg) / prevAvg) * 100)
    }
    var proteinChange: Int {
        let prevAvg = prevProteinData.isEmpty ? 0 : prevProteinData.reduce(0, +) / Double(prevProteinData.count)
        let currAvg = proteinData.isEmpty ? 0 : proteinData.reduce(0, +) / Double(proteinData.count)
        guard prevAvg != 0 else { return 0 }
        return Int(((currAvg - prevAvg) / prevAvg) * 100)
    }
    var fatChange: Int {
        let prevAvg = prevFatData.isEmpty ? 0 : prevFatData.reduce(0, +) / Double(prevFatData.count)
        let currAvg = fatData.isEmpty ? 0 : fatData.reduce(0, +) / Double(fatData.count)
        guard prevAvg != 0 else { return 0 }
        return Int(((currAvg - prevAvg) / prevAvg) * 100)
    }
    var days: [String] {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        return last7Days.map { formatter.string(from: $0) }
    }
    var calories: Int { Int(caloriesData.last ?? 0) }
    var protein: Int { Int(proteinData.last ?? 0) }
    var fat: Int { Int(fatData.last ?? 0) }
    var last7DaysRangeLabel: String {
        guard let first = last7Days.first, let last = last7Days.last else { return "" }
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return "\(formatter.string(from: first)) - \(formatter.string(from: last))"
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Tabs
                HStack(spacing: 24) {
                    ForEach(["Daily", "Weekly", "Monthly"].indices, id: \ .self) { idx in
                        Button(action: { selectedTab = idx }) {
                            VStack(spacing: 2) {
                                Text(["Daily", "Weekly", "Monthly"][idx])
                                    .font(.primaryTitle)
                                    .foregroundStyle(selectedTab == idx ? Color.appForegroundColor : Color.secondayNumberForegroundColor)
                                Rectangle()
                                    .frame(height: 2)
                                    .foregroundStyle(selectedTab == idx ? Color.appForegroundColor : Color.clear)
                            }
                        }
                    }
                }
                .padding(.top, 16)
                .padding(.bottom, 8)
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 32) {
                        // Calories Card
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Calories")
                                .font(.primaryTitle)
                            Text("\(calories)")
                                .font(.primaryNumberTitle)
                            HStack(spacing: 4) {
                                Text(last7DaysRangeLabel)
                                    .font(.secondaryNumberTitle)
                                    .foregroundStyle(Color.secondayNumberForegroundColor)
                                Text("\(caloriesChange > 0 ? "+" : "")\(caloriesChange)%")
                                    .font(.secondaryNumberTitle)
                                    .foregroundStyle(caloriesChange >= 0 ? Color.green : Color.red)
                            }
                        }
                        .padding(.horizontal)
                        
                        // Line Chart (Calories)
                        CaloriesLineChart(data: caloriesData, days: days)
                            .frame(height: 120)
                            .padding(.horizontal)
                        
                        // Protein Card
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Protein")
                                .font(.primaryTitle)
                            Text("\(protein)g")
                                .font(.primaryNumberTitle)
                            HStack(spacing: 4) {
                                Text(last7DaysRangeLabel)
                                    .font(.secondaryNumberTitle)
                                    .foregroundStyle(Color.secondayNumberForegroundColor)
                                Text("\(proteinChange > 0 ? "+" : "")\(proteinChange)%")
                                    .font(.secondaryNumberTitle)
                                    .foregroundStyle(proteinChange >= 0 ? Color.green : Color.red)
                            }
                        }
                        .padding(.horizontal)
                        
                        // Bar Chart (Protein)
                        ProteinBarChart(data: proteinData, days: days)
                            .frame(height: 100)
                            .padding(.horizontal)
                        
                        // Fat Card
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Fat")
                                .font(.primaryTitle)
                            Text("\(fat)g")
                                .font(.primaryNumberTitle)
                            HStack(spacing: 4) {
                                Text(last7DaysRangeLabel)
                                    .font(.secondaryNumberTitle)
                                    .foregroundStyle(Color.secondayNumberForegroundColor)
                                Text("\(fatChange > 0 ? "+" : "")\(fatChange)%")
                                    .font(.secondaryNumberTitle)
                                    .foregroundStyle(fatChange >= 0 ? Color.green : Color.red)
                            }
                        }
                        .padding(.horizontal)
                        
                        // Bar Chart (Fat)
                        FatBarChart(data: fatData, days: days)
                            .frame(height: 100)
                            .padding(.horizontal)
                    }
                    .padding(.top, 8)
                    .padding(.bottom, 32)
                }
            }
            .background(Color("appBackgroundColor").ignoresSafeArea())
            .navigationTitle("Progress")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// Simple line chart using Path for calories
struct CaloriesLineChart: View {
    let data: [Double]
    let days: [String]
    @State private var selectedIdx: Int? = nil
    
    var body: some View {
        GeometryReader { geo in
            let maxY = (data.max() ?? 1)
            let minY = (data.min() ?? 0)
            let height = geo.size.height
            let width = geo.size.width
            let stepX = width / CGFloat(data.count - 1)
            let points = data.enumerated().map { idx, val in
                CGPoint(x: CGFloat(idx) * stepX, y: height - CGFloat((val - minY) / (maxY - minY + 0.01)) * height)
            }
            ZStack {
                // Line
                Path { path in
                    if let first = points.first {
                        path.move(to: first)
                        for pt in points.dropFirst() {
                            path.addLine(to: pt)
                        }
                    }
                }
                .stroke(Color.secondayNumberForegroundColor, lineWidth: 3)
                
                // Tappable points
                ForEach(points.indices, id: \ .self) { idx in
                    let pt = points[idx]
                    Circle()
                        .fill(Color.secondayNumberForegroundColor)
                        .frame(width: 16, height: 16)
                        .opacity(selectedIdx == idx ? 1 : 0.001)
                        .position(pt)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            withAnimation { selectedIdx = idx }
                        }
                }
                // Days labels
                ForEach(days.indices, id: \ .self) { idx in
                    Text(days[idx])
                        .font(.secondaryNumberTitle)
                        .foregroundStyle(Color.secondayNumberForegroundColor)
                        .position(x: CGFloat(idx) * stepX, y: height + 12)
                }
            }
        }
    }
    
    func formattedDay(idx: Int) -> String {
        // Example: "Sat, Jun 14"
        let formatter = DateFormatter()
        formatter.dateFormat = "E, MMM d"
        return formatter.string(from: Date().addingTimeInterval(Double(idx) * 86400))
    }
}

// Protein Bar Chart (was MacrosBarChart)
struct ProteinBarChart: View {
    let data: [Double]
    let days: [String]
    @State private var selectedIdx: Int? = nil
    
    var body: some View {
        GeometryReader { geo in
            let maxY = (data.max() ?? 1)
            let height = geo.size.height
            let width = geo.size.width
            let barWidth = width / CGFloat(data.count * 2)
            ZStack {
                ForEach(data.indices, id: \ .self) { idx in
                    let val = data[idx]
                    let barHeight = CGFloat(val / maxY) * height
                    let barX = CGFloat(idx) * barWidth * 2 + barWidth
                    VStack(spacing: 0) {
                        Spacer(minLength: height - barHeight)
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.secondayNumberForegroundColor.opacity(0.2))
                            .frame(width: barWidth, height: barHeight)
                            .onTapGesture {
                                withAnimation { selectedIdx = idx }
                            }
                        Text(days[idx])
                            .font(.secondaryNumberTitle)
                            .foregroundStyle(Color.secondayNumberForegroundColor)
                            .frame(width: barWidth * 1.2)
                    }
                    .frame(width: barWidth * 2, height: height, alignment: .bottom)
                    .position(x: barX, y: height / 2)
                }
                // Annotation overlay
                if let idx = selectedIdx {
                    let val = data[idx]
                    let barHeight = CGFloat(val / maxY) * height
                    let barX = CGFloat(idx) * barWidth * 2 + barWidth
                    let annotationY = height - barHeight - 36
                    BarAnnotationCard(
                        title: formattedDay(idx: idx),
                        value: "\(Int(val))g"
                    )
                    .position(x: barX, y: max(annotationY, 36))
                    // Pointer/line
                    Path { path in
                        let startY = max(annotationY + 18, 54)
                        let endY = height - barHeight
                        path.move(to: CGPoint(x: barX, y: startY))
                        path.addLine(to: CGPoint(x: barX, y: endY))
                    }
                    .stroke(Color.secondayNumberForegroundColor.opacity(0.3), style: StrokeStyle(lineWidth: 2, dash: [4]))
                }
            }
        }
    }
    
    func formattedDay(idx: Int) -> String {
        // Example: "Sat, Jun 14"
        let formatter = DateFormatter()
        formatter.dateFormat = "E, MMM d"
        return formatter.string(from: Date().addingTimeInterval(Double(idx) * 86400))
    }
}

struct BarAnnotationCard: View {
    let title: String
    let value: String
    var body: some View {
        VStack(spacing: 2) {
            Text(title)
                .font(.secondaryNumberTitle)
                .foregroundStyle(Color.secondayNumberForegroundColor)
            Text(value)
                .font(.primaryNumberTitle)
                .foregroundStyle(Color.appForegroundColor)
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.containerBackgroundColor)
                .shadow(color: Color.black.opacity(0.08), radius: 6, x: 0, y: 2)
        )
    }
}

// Fat Bar Chart (was WeightBarChart)
struct FatBarChart: View {
    let data: [Double]
    let days: [String]
    @State private var selectedIdx: Int? = nil
    
    var body: some View {
        GeometryReader { geo in
            let maxY = (data.max() ?? 1)
            let height = geo.size.height
            let width = geo.size.width
            let barWidth = width / CGFloat(data.count * 2)
            ZStack {
                ForEach(data.indices, id: \ .self) { idx in
                    let val = data[idx]
                    let barHeight = CGFloat(val / maxY) * height
                    let barX = CGFloat(idx) * barWidth * 2 + barWidth
                    VStack(spacing: 0) {
                        Spacer(minLength: height - barHeight)
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.secondayNumberForegroundColor.opacity(0.2))
                            .frame(width: barWidth, height: barHeight)
                            .onTapGesture {
                                withAnimation { selectedIdx = idx }
                            }
                        Text(days[idx])
                            .font(.secondaryNumberTitle)
                            .foregroundStyle(Color.secondayNumberForegroundColor)
                            .frame(width: barWidth * 1.2)
                    }
                    .frame(width: barWidth * 2, height: height, alignment: .bottom)
                    .position(x: barX, y: height / 2)
                }
                // Annotation overlay
                if let idx = selectedIdx {
                    let val = data[idx]
                    let barHeight = CGFloat(val / maxY) * height
                    let barX = CGFloat(idx) * barWidth * 2 + barWidth
                    let annotationY = height - barHeight - 36
                    BarAnnotationCard(
                        title: formattedDay(idx: idx),
                        value: "\(Int(val))g"
                    )
                    .position(x: barX, y: max(annotationY, 36))
                    // Pointer/line
                    Path { path in
                        let startY = max(annotationY + 18, 54)
                        let endY = height - barHeight
                        path.move(to: CGPoint(x: barX, y: startY))
                        path.addLine(to: CGPoint(x: barX, y: endY))
                    }
                    .stroke(Color.secondayNumberForegroundColor.opacity(0.3), style: StrokeStyle(lineWidth: 2, dash: [4]))
                }
            }
        }
    }
    
    func formattedDay(idx: Int) -> String {
        // Example: "Sat, Jun 14"
        let formatter = DateFormatter()
        formatter.dateFormat = "E, MMM d"
        return formatter.string(from: Date().addingTimeInterval(Double(idx) * 86400))
    }
}
