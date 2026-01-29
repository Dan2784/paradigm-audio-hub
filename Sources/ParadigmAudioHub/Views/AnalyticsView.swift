import Charts
import SwiftUI

struct AnalyticsView: View {
    @ObservedObject var store: AppStore
    @State private var basis: AnalyticsBasis = .issued
    @State private var filters = InvoiceFilters()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Invoice Analytics")
                    .font(.title2)
                Picker("Basis", selection: $basis) {
                    ForEach(AnalyticsBasis.allCases) { basis in
                        Text(basis.displayName).tag(basis)
                    }
                }
                .pickerStyle(.segmented)
                AnalyticsFiltersView(filters: $filters)
                Chart(revenueByMonth) { item in
                    BarMark(
                        x: .value("Month", item.monthLabel),
                        y: .value("Revenue", item.value)
                    )
                    .foregroundStyle(.yellow)
                }
                .frame(height: 220)

                HStack {
                    MetricCard(title: "Outstanding Balance", value: formattedCurrency(outstandingBalance))
                    MetricCard(title: "Paid vs Unpaid", value: "\(paidCount) / \(unpaidCount)")
                    MetricCard(title: "Avg Days to Payment", value: "\(averageDaysToPayment)")
                }

                Chart(topClients) { item in
                    BarMark(
                        x: .value("Client", item.client),
                        y: .value("Revenue", item.value)
                    )
                    .foregroundStyle(.orange)
                }
                .frame(height: 220)
            }
            .padding(24)
        }
    }

    private var filteredInvoices: [Invoice] {
        InvoiceFiltering.apply(filters: filters, invoices: store.invoices)
            .filter { invoice in
                if basis == .paid {
                    return invoice.paidDate != nil
                }
                return true
            }
    }

    private var revenueByMonth: [MonthlyRevenue] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: filteredInvoices) { invoice -> Date in
            let date = basis == .paid ? (invoice.paidDate ?? invoice.issueDate) : invoice.issueDate
            let components = calendar.dateComponents([.year, .month], from: date)
            return calendar.date(from: components) ?? date
        }
        return grouped.map { key, value in
            let total = value.reduce(0) { $0 + $1.total }
            return MonthlyRevenue(month: key, value: total)
        }.sorted { $0.month < $1.month }
    }

    private var outstandingBalance: Double {
        filteredInvoices.filter { $0.status != .paid && $0.status != .cancelled }.reduce(0) { $0 + $1.total }
    }

    private var paidCount: Int {
        filteredInvoices.filter { $0.status == .paid }.count
    }

    private var unpaidCount: Int {
        filteredInvoices.filter { $0.status != .paid }.count
    }

    private var averageDaysToPayment: String {
        let paidInvoices = filteredInvoices.compactMap { invoice -> Int? in
            guard let paidDate = invoice.paidDate else { return nil }
            return Calendar.current.dateComponents([.day], from: invoice.issueDate, to: paidDate).day
        }
        guard !paidInvoices.isEmpty else { return "-" }
        let average = paidInvoices.reduce(0, +) / paidInvoices.count
        return "\(average) days"
    }

    private var topClients: [ClientRevenue] {
        let grouped = Dictionary(grouping: filteredInvoices, by: { $0.clientName })
        return grouped.map { key, value in
            let total = value.reduce(0) { $0 + $1.total }
            return ClientRevenue(client: key, value: total)
        }.sorted { $0.value > $1.value }.prefix(5).map { $0 }
    }

    private func formattedCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "GBP"
        return formatter.string(from: NSNumber(value: value)) ?? "£0.00"
    }
}

private struct AnalyticsFiltersView: View {
    @Binding var filters: InvoiceFilters

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                TextField("Search", text: $filters.search)
                TextField("Client", text: $filters.client)
                Picker("Status", selection: $filters.status) {
                    Text("All").tag(InvoiceStatus?.none)
                    ForEach(InvoiceStatus.allCases) { status in
                        Text(status.displayName).tag(InvoiceStatus?.some(status))
                    }
                }
            }
            HStack {
                OptionalDatePicker(title: "Issue From", date: $filters.issueFrom)
                OptionalDatePicker(title: "Issue To", date: $filters.issueTo)
                OptionalDatePicker(title: "Paid From", date: $filters.paidFrom)
                OptionalDatePicker(title: "Paid To", date: $filters.paidTo)
            }
            .font(.caption)
        }
    }
}

enum AnalyticsBasis: String, CaseIterable, Identifiable {
    case issued
    case paid

    var id: String { rawValue }
    var displayName: String { rawValue.capitalized }
}

struct MonthlyRevenue: Identifiable {
    let month: Date
    let value: Double
    var id: Date { month }
    var monthLabel: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM yyyy"
        return formatter.string(from: month)
    }
}

struct ClientRevenue: Identifiable {
    let client: String
    let value: Double
    var id: String { client }
}

struct MetricCard: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title).font(.caption)
            Text(value).font(.headline)
        }
        .padding(12)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
    }
}
