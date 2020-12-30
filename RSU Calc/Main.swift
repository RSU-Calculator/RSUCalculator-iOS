//
//  Main.swift
//  RSU Calc
//
//  Created by Dudu Twizer on 29/11/2020.
//

import SwiftUI
import SwiftUICharts
import SwiftUIRefresh

extension Sequence where Iterator.Element: Hashable {
    func unique() -> [Iterator.Element] {
        var seen: [Iterator.Element: Bool] = [:]
        return self.filter { seen.updateValue(true, forKey: $0) == nil }
    }
}

struct currency_menu : View {
    @EnvironmentObject var user_data: current_user_data
    @Binding var currencyFormatter: NumberFormatter
    var body: some View {
    Menu(content: {
        Section {
            Button(action: {
                self.user_data.mySettings.local_code = "en_US"
                self.user_data.mySettings.currency = "USD"
                self.setLocal()
                self.user_data.savetoDisk()
            }) {
                Text("Change to USD \(getSymbolForCurrencyCode(code: "USD"))")
            }
            Button(action: {
                self.user_data.mySettings.local_code = "en_CA"
                self.user_data.mySettings.currency = "CAD"
                self.setLocal()
                self.user_data.savetoDisk()
            }) {
                Text("Change to CAD \(getSymbolForCurrencyCode(code: "CAD"))")
            }
            Button(action: {
                self.user_data.mySettings.local_code = "fr_FR"
                self.user_data.mySettings.currency = "EUR"
                self.setLocal()
                self.user_data.savetoDisk()
            }) {
                Text("Change to EUR \(getSymbolForCurrencyCode(code: "EUR"))")
            }
            Button(action: {
                self.user_data.mySettings.local_code = "cy_GB"
                self.user_data.mySettings.currency = "GBP"
                self.setLocal()
                self.user_data.savetoDisk()
            }) {
                Text("Change to GBP \(getSymbolForCurrencyCode(code: "GBP"))")
            }
            Button(action: {
                self.user_data.mySettings.local_code = "he_IL"
                self.user_data.mySettings.currency = "ILS"
                self.setLocal()
                self.user_data.savetoDisk()
            }) {
                Text("Change to ILS \(getSymbolForCurrencyCode(code: "ILS"))")
            }
        }
        
    }, label: {
        Text("Currency")
    })
    }
    
    func getSymbolForCurrencyCode(code: String) -> String {
        var candidates: [String] = []
        let locales: [String] = NSLocale.availableLocaleIdentifiers
        for localeID in locales {
            guard let symbol = findMatchingSymbol(localeID: localeID, currencyCode: code) else {
                continue
            }
            if symbol.count == 1 {
                return symbol
            }
            candidates.append(symbol)
        }
        let sorted = sortAscByLength(list: candidates)
        if sorted.count < 1 {
            return ""
        }
        return sorted[0]
    }

    func findMatchingSymbol(localeID: String, currencyCode: String) -> String? {
        let locale = Locale(identifier: localeID as String)
        guard let code = locale.currencyCode else {
            return nil
        }
        if code != currencyCode {
            return nil
        }
        guard let symbol = locale.currencySymbol else {
            return nil
        }
        return symbol
    }

    func sortAscByLength(list: [String]) -> [String] {
        return list.sorted(by: { $0.count < $1.count })
    }
    
    func setLocal()
    {
        let f = NumberFormatter()
        f.numberStyle = .currency
        f.locale = Locale(identifier: user_data.mySettings.local_code)
        f.maximumFractionDigits = 0
        self.currencyFormatter = f
    }
}

struct ActivityIndicator: UIViewRepresentable {

    @Binding var isAnimating: Bool
    let style: UIActivityIndicatorView.Style

    func makeUIView(context: UIViewRepresentableContext<ActivityIndicator>) -> UIActivityIndicatorView {
        return UIActivityIndicatorView(style: style)
    }

    func updateUIView(_ uiView: UIActivityIndicatorView, context: UIViewRepresentableContext<ActivityIndicator>) {
        isAnimating ? uiView.startAnimating() : uiView.stopAnimating()
    }
}


struct Main: View {
    @EnvironmentObject var user_data: current_user_data
    @Binding var showing_ADD_RSU_Sheet: Bool
    @Environment(\.colorScheme) var colorScheme
    @Binding var currencyFormatter: NumberFormatter
    @State var toDate : Date = Calendar.current.date(byAdding: .year, value: 100, to: Date())!
    @State var fromDate : Date = Calendar.current.date(byAdding: .year, value: -100, to: Date())!
    @State private var showAll: Bool = true
    @State private var show_withTaxDeduction: Bool = false
    @State private var show_running_sum: Bool = false
    @State private var show_by_year_aggr: Bool = false
    var date_formatter : DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }
    var dateClosedRange: ClosedRange<Date> {
        let currentDate = Date()
        var dateComponent = DateComponents()
        dateComponent.year = 20
        var dateComponent2 = DateComponents()
        dateComponent2.year = -20
        let min = Calendar.current.date(byAdding: dateComponent2, to:currentDate)
        let max = Calendar.current.date(byAdding: dateComponent, to:currentDate)
        return min!...max!
    }
    @State private var show_by_vest: Bool = false
    @State var isShowing = false
    @State var topLineData : [(String,Double)] = []
    var body: some View {
        NavigationView
        {
            ScrollView {
                VStack(alignment: .leading)
                {
                    if(!user_data.isDataSetEmpty())
                    {
                        if(user_data.mySettings.custom_stock_price)
                        {
                            Text("Showing simulation for stock \(user_data.mySettings.custom_stock_price_stockSymbol.uppercased()) price : \(currencyFormatter.string(from: NSNumber(value: user_data.mySettings.custom_stock_price_value))!)")
                                .foregroundColor(.red)
                                .padding()
                            
                        }
                        if(user_data.myStocks.count == 1)
                        {
                            LineChartView(data: topLineData, title: "Holdings: \(currencyFormatter.string(from: NSNumber(value:user_data.calculate_ByDate_Double(targetDate: toDate, show_by_vest: true, show_withTaxDeduction: false)))!)", style: Styles.lineChartStyleOne, form: ChartForm.extraLarge, rateValue: user_data.get_rate_value(targetDate: toDate, show_by_vest: true, show_withTaxDeduction: false), currencyFormatter: currencyFormatter)
                                .padding()
                                .onAppear()
                                {
                                    topLineData = user_data.calculate_StringDoubleArray(targetDate: toDate, show_by_vest: true, show_withTaxDeduction: false, RunningSum: true, show_by_year_aggr: show_by_year_aggr, withLineBreak: false)
                                    topLineData = [("", 0),topLineData[0]]
                                }
                                .onDisappear()
                                {
                                    topLineData = []
                                }
                        }
                        else
                        
                        {
                            LineChartView(data: user_data.calculate_StringDoubleArray(targetDate: toDate, show_by_vest: true, show_withTaxDeduction: false, RunningSum: true, show_by_year_aggr: show_by_year_aggr, withLineBreak: false), title: "Holdings: \(currencyFormatter.string(from: NSNumber(value:user_data.calculate_ByDate_Double(targetDate: toDate, show_by_vest: true, show_withTaxDeduction: false)))!)", style: Styles.lineChartStyleOne, form: ChartForm.extraLarge, rateValue: user_data.get_rate_value(targetDate: toDate, show_by_vest: true, show_withTaxDeduction: false), currencyFormatter: currencyFormatter)
                            .padding()
                        }

                    Text("Summary")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.leading)
                        .padding(.top)
                        .padding(.horizontal)
                    
                    
                    // Today's holding
                    NavigationLink(destination:
                                    BarChartView(data: ChartData(values: user_data.calculate_StringDoubleArray(targetDate: Date(), show_by_vest: true, show_withTaxDeduction: false, RunningSum: false, show_by_year_aggr: false, withLineBreak: true)), title: "Portfolio value by vesting day" , legend: "By vesting date" , form: ChartForm.extraLarge, currencyFormatter: currencyFormatter, page_headline: "Today's holding", long_description: "This graph shows your vested RSUs and their value, by vesting date. If you don't see any value, it means that you still don't have any RSUs that are vested.\n\nThe value of each data point is the number of vested stocks multiple the current stock value.") .padding(.top)
                        )
                        {
                        CardDash(title: "Today's holding", value: user_data.calculate_ByDate_Double(targetDate: Date(), show_by_vest: true, show_withTaxDeduction: false), icon: "wallet.pass", link_desc: "Show vesting so far", color: Color(self.colorScheme == .dark ? UIColor(red: 0.40, green: 0.76, blue: 0.91, alpha: 1.00) : UIColor(red: 0.48, green: 0.51, blue: 1.00, alpha: 1.00)), currencyFormatter: $currencyFormatter)
                        }
                        .padding(.top, 5)
                        .padding(.horizontal)
                    
                    // Total holding
                    NavigationLink(destination:
                                    BarChartView(data: ChartData(values: user_data.calculate_StringDoubleArray(targetDate: Calendar.current.date(byAdding: .year, value: 100, to: Date())!, show_by_vest: true, show_withTaxDeduction: false, RunningSum: false, show_by_year_aggr: false, withLineBreak: true)), title: "Portfolio value by granting day", legend: "By granting date", form: ChartForm.extraLarge, currencyFormatter: currencyFormatter, page_headline: "Total holding", long_description: "This graph shows your total RSUs and their value, by vesting date. If you don't see any value, it means that you still don't have any RSUs that are vested.\n\nThe value of each data point is the number of vested stocks multiple the current stock value.") .padding(.top)
                        )
                        {
                            CardDash(title: "Total holding",value: user_data.calculate_ByDate_Double(targetDate: Calendar.current.date(byAdding: .year, value: 100, to: Date())!, show_by_vest: true, show_withTaxDeduction: false), icon: "calendar.badge.clock", link_desc: "Show future holding", color: Color(self.colorScheme == .dark ? UIColor(red: 0.40, green: 0.76, blue: 0.91, alpha: 1.00) : UIColor(red: 0.48, green: 0.51, blue: 1.00, alpha: 1.00)), currencyFormatter: $currencyFormatter)
                        }
                        .padding(.top, 5)
                        .padding(.horizontal)
                    
                    Group{
                        Text("TAX Simulation")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.leading)
                        .padding(.top)
                        .padding(.horizontal)
                    
                    // Today holding after tax
                    NavigationLink(destination:
                                    BarChartView(data: ChartData(values: user_data.calculate_StringDoubleArray(targetDate: Date(), show_by_vest: true, show_withTaxDeduction: true, RunningSum: false, show_by_year_aggr: false, withLineBreak: true)), title: "Portfolio value by vesting day" , legend: "By vesting date" , form: ChartForm.extraLarge, currencyFormatter: currencyFormatter, page_headline: "Today's net pay", long_description: "This graph shows your vested RSUs and their value, minus the estimated taxes, by vesting date. If you don't see any value, it means that you still don't have any RSUs that are vested.\n\nThe value of each data point is the number of vested stocks multiple the current stock value.\n\nThe tax is calculated by the rules defined in the setting tab") .padding(.top)
                        )
                        {
                        CardDash(title: "Today's net pay", value: user_data.calculate_ByDate_Double(targetDate: Date(), show_by_vest: true, show_withTaxDeduction: true), icon: "wallet.pass", link_desc: "Show vesting so far", color: Color(self.colorScheme == .dark ? UIColor(red: 0.40, green: 0.76, blue: 0.91, alpha: 1.00) : UIColor(red: 0.48, green: 0.51, blue: 1.00, alpha: 1.00)), currencyFormatter: $currencyFormatter)
                        }
                        .padding(.top, 5)
                        .padding(.horizontal)
                    
                    // total holding after tax
                    NavigationLink(destination:
                                    BarChartView(data: ChartData(values: user_data.calculate_StringDoubleArray(targetDate: Calendar.current.date(byAdding: .year, value: 100, to: Date())!, show_by_vest: true, show_withTaxDeduction: true, RunningSum: false, show_by_year_aggr: false, withLineBreak: true)), title: "Portfolio value by granting day", legend: "By granting date", form: ChartForm.extraLarge, currencyFormatter: currencyFormatter, page_headline: "Total net pay", long_description: "This graph shows your total RSUs and their value, minus the estimated taxes, by vesting date. If you don't see any value, it means that you still don't have any RSUs that are vested.\n\nThe value of each data point is the number of vested stocks multiple the current stock value. \n\nThe tax is calculated by the rules defined in the setting tab") .padding(.top)
                        )
                        {
                            CardDash(title: "Total net pay",value: user_data.calculate_ByDate_Double(targetDate: Calendar.current.date(byAdding: .year, value: 100, to: Date())!, show_by_vest: true, show_withTaxDeduction: true), icon: "calendar.badge.clock", link_desc: "Show future holding", color: Color(self.colorScheme == .dark ? UIColor(red: 0.40, green: 0.76, blue: 0.91, alpha: 1.00) : UIColor(red: 0.48, green: 0.51, blue: 1.00, alpha: 1.00)), currencyFormatter: $currencyFormatter)
                        }
                        .padding(.top, 5)
                        .padding(.horizontal)
                    }
                    
                    Group
                    {
                    Text("Insights")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.leading)
                        .padding(.top)
                        .padding(.horizontal)
                        
                    CardDash2(title: "Next vesting point is in \(user_data.getNextVest()) days", icon: "info.circle", link_desc: "", color: Color(self.colorScheme == .dark ? UIColor(red: 0.40, green: 0.76, blue: 0.91, alpha: 1.00) : UIColor(red: 0.48, green: 0.51, blue: 1.00, alpha: 1.00)), currencyFormatter: $currencyFormatter)
                        .padding(.top, 5)
                        .padding(.horizontal)
                    
                    ForEach(user_data.myCompanies, id: \.self) { item in
                        CardDash(title: "\(item.symbol?.uppercased() ?? "NA") - current value", value: user_data.getStockPrice(stock_symbol: item.symbol!), icon: "info.circle", link_desc: "", color: Color(self.colorScheme == .dark ? UIColor(red: 0.40, green: 0.76, blue: 0.91, alpha: 1.00) : UIColor(red: 0.48, green: 0.51, blue: 1.00, alpha: 1.00)), currencyFormatter: $currencyFormatter)
                            .padding(.top, 5)
                            .padding(.horizontal)
                    }
                    
                    NavigationLink(destination:
                        BarChartView(data: ChartData(values: user_data.calculate_StringDoubleArray(targetDate: Calendar.current.date(byAdding: .year, value: 100, to: Date())!, show_by_vest: true, show_withTaxDeduction: false, RunningSum: false, show_by_year_aggr: true, withLineBreak: true)), title: "Portfolio value by vesting day", legend: "By vesting date", form: ChartForm.extraLarge, currencyFormatter: currencyFormatter, page_headline: "\(Int((user_data.getYearsOfStocks().count))) years average", long_description: "This graph show your yearly average RSUs value. The first year is the first granted RSU while the last year is the very last vested RSU.\n\nThe value of each data point is the number of vested stocks in that year multiple the current stock value.") .padding(.top)
                        )
                        {
                        CardDash(title: "\(Int((user_data.getYearsOfStocks().count))) years average", value: (user_data.calculate_ByDate_Double(targetDate: Calendar.current.date(byAdding: .year, value: 100, to: Date())!, show_by_vest: true, show_withTaxDeduction: false)/Double((user_data.getYearsOfStocks().count))), icon: "info.circle", link_desc: "Show by year", color: Color(self.colorScheme == .dark ? UIColor(red: 0.40, green: 0.76, blue: 0.91, alpha: 1.00) : UIColor(red: 0.48, green: 0.51, blue: 1.00, alpha: 1.00)), currencyFormatter: $currencyFormatter)
                        }
                        .padding(.top, 5)
                        .padding(.horizontal)
                    
                        if((user_data.get_number_of_months() > 0))
                        {
                        CardDash(title: "\(Int((user_data.get_number_of_months()))) months average", value: (user_data.calculate_ByDate_Double(targetDate: Calendar.current.date(byAdding: .year, value: 100, to: Date())!, show_by_vest: true, show_withTaxDeduction: false)/Double((user_data.get_number_of_months()))), icon: "info.circle", link_desc: "", color: Color(self.colorScheme == .dark ? UIColor(red: 0.40, green: 0.76, blue: 0.91, alpha: 1.00) : UIColor(red: 0.48, green: 0.51, blue: 1.00, alpha: 1.00)), currencyFormatter: $currencyFormatter)
                        .padding(.top, 5)
                        .padding(.horizontal)
                        }
                    }
                    
                    Group
                    {
                    Text("Manage your RSU list")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.leading)
                        .padding(.top)
                        .padding(.horizontal)
                    
                    CardDash2(title: "Total of \(user_data.countVested_toToday()) out of \((user_data.countGranted_ToToday())) granted", icon: "info.circle", link_desc: "", color: Color(self.colorScheme == .dark ? UIColor(red: 0.40, green: 0.76, blue: 0.91, alpha: 1.00) : UIColor(red: 0.48, green: 0.51, blue: 1.00, alpha: 1.00)), currencyFormatter: $currencyFormatter)
                        .padding(.top, 5)
                        .padding(.horizontal)
                        
                    NavigationLink(destination:
                                   Holdings(currencyFormatter: $currencyFormatter, showing_ADD_RSU_Sheet: $showing_ADD_RSU_Sheet)
                                    .environmentObject(user_data)
                                    .padding()
                        )
                        {
                        CardDash2(title: "Total of \(user_data.myStocks.count) entries", icon: "info.circle", link_desc: "Manage your RSU List", color: Color(self.colorScheme == .dark ? UIColor(red: 0.40, green: 0.76, blue: 0.91, alpha: 1.00) : UIColor(red: 0.48, green: 0.51, blue: 1.00, alpha: 1.00)), currencyFormatter: $currencyFormatter)
                        }
                        .padding(.top, 5)
                        .padding(.horizontal)
                    }
                    
                    }
                    else
                    {
                        VStack(alignment: .center)
                        {
                            Spacer()
                        Text("Click here to add your first RSU to the list")
                            .onTapGesture {
                                self.showing_ADD_RSU_Sheet = true
                            }
                            Spacer()
                        }
                    }
                }.pullToRefresh(isShowing: $isShowing) {
                    self.user_data.data_from_api = true
                    self.user_data.cache = [:]
                    self.isShowing = false
                }
                .onAppear()
                    {
                    self.setLocal()
                    }
                .navigationBarTitle("RSU Calculator", displayMode: .inline)
                .navigationBarItems(
                    leading:
                        currency_menu(currencyFormatter: $currencyFormatter).environmentObject(user_data),
                        trailing:
                            Button (action: {
                                self.showing_ADD_RSU_Sheet = true
                            })
                            {
                                Image(systemName: "plus.app.fill").foregroundColor(colorScheme == .dark ? .white : .black)
                            }
            )
            }
            .frame(maxWidth: 800)
            }.navigationViewStyle(StackNavigationViewStyle())
           
            .sheet(isPresented: $showing_ADD_RSU_Sheet) {
                AddRSUView(currencyFormatter: $currencyFormatter)
                .environmentObject(user_data)
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        Button(action: {
                            self.showing_ADD_RSU_Sheet = false
                        }) {
                            Text("Done").fontWeight(.semibold)
                        }
                    }
                }
        }
    }
    func setLocal()
    {
        let f = NumberFormatter()
        f.numberStyle = .currency
        f.locale = Locale(identifier: user_data.mySettings.local_code)
        f.maximumFractionDigits = 0
        self.currencyFormatter = f
    }
}

struct Main_Previews: PreviewProvider {
    static var user_data = current_user_data()
    static var previews: some View {
        Main(showing_ADD_RSU_Sheet: .constant(false), currencyFormatter: .constant(NumberFormatter()))
            .environmentObject(user_data)
            .colorScheme(.dark)
            .onAppear()
            {
                user_data.mockData()
            }
    }
}

struct CardDash: View {
    @Environment(\.colorScheme) var colorScheme
     var title: String
     var value: Double
     var icon: String
     var link_desc: String
     var color: Color
    @Binding var currencyFormatter: NumberFormatter

    var body: some View {
        VStack(alignment: .leading) {
            HStack
            {
                ZStack
                {
                    LinearGradient(gradient: Gradient(
                                    colors:
                                        [
                                            .init(
                                                colorScheme == .light ?
                                                    UIColor(red: 0.99, green: 1.00, blue: 1.00, alpha: 1.00):
                                                    UIColor(red: 0.19, green: 0.23, blue: 0.27, alpha: 1.00)
                                            ),
                                            .init(
                                                colorScheme == .light ?
                                                    UIColor(red: 0.82, green: 0.93, blue: 1.00, alpha: 1.00):
                                                    UIColor(red: 0.16, green: 0.29, blue: 0.31, alpha: 1.00)
                                            )
                                        ]),
                                   startPoint: .topLeading, endPoint: .bottomTrailing)
                        .frame(width: 40.0, height: 40.0)
                        .shadow(color: Color.black.opacity(0.2),radius: 3, x: 0, y:3)
                        .cornerRadius(40)
                    Image(systemName: icon)
                        .padding()
                        .clipShape(Circle())
                        .foregroundColor(self.colorScheme == .dark ? .white : .black)
                        .shadow(radius: 10)
                }
                VStack(alignment: .leading)
                {
                    Text("\(title)")
                        .font(.caption)
                        .foregroundColor(self.colorScheme == .dark ? .white : .black)
                        .padding(.top)
                    Text("\(currencyFormatter.string(from: NSNumber(value: self.value))!)")
                        .font(.title2)
                        .bold()
                        .foregroundColor(color)
                        .padding(.bottom)
                }
                Spacer()
                VStack(alignment: .trailing){
                    Text("\(link_desc)")
                        .font(.caption)
//                        .foregroundColor(Color(UIColor(red: 0.35, green: 0.35, blue: 0.36, alpha: 1.00)))
                        .foregroundColor(self.colorScheme == .dark ? Color.gray : Color.gray)
                        .padding(.trailing)
                }
            }
            .background(self.colorScheme == .dark ? Color(UIColor(red: 0.11, green: 0.11, blue: 0.12, alpha: 1.00)) : Color(UIColor(red: 0.95, green: 0.98, blue: 1.00, alpha: 1.00)))
            .cornerRadius(10)
        }
    }
}

struct CardDash2: View {
    @Environment(\.colorScheme) var colorScheme
     var title: String
     var icon: String
     var link_desc: String
     var color: Color
    @Binding var currencyFormatter: NumberFormatter

    var body: some View {
        VStack(alignment: .leading) {
            HStack
            {
                ZStack
                {
                    LinearGradient(gradient: Gradient(
                                    colors:
                                        [
                                            .init(
                                                colorScheme == .light ?
                                                    UIColor(red: 0.99, green: 1.00, blue: 1.00, alpha: 1.00):
                                                    UIColor(red: 0.19, green: 0.23, blue: 0.27, alpha: 1.00)
                                            ),
                                            .init(
                                                colorScheme == .light ?
                                                    UIColor(red: 0.82, green: 0.93, blue: 1.00, alpha: 1.00):
                                                    UIColor(red: 0.16, green: 0.29, blue: 0.31, alpha: 1.00)
                                            )
                                        ]),
                                   startPoint: .topLeading, endPoint: .bottomTrailing)
                        .frame(width: 40.0, height: 40.0)
                        .shadow(color: Color.black.opacity(0.2),radius: 3, x: 0, y:3)
                        .cornerRadius(40)
                    Image(systemName: icon)
                        .padding()
                        .clipShape(Circle())
                        .foregroundColor(self.colorScheme == .dark ? .white : .black)
                        .shadow(radius: 10)
                }
                VStack(alignment: .leading)
                {
                    Text("\(title)")
                        .font(.subheadline)
                        .foregroundColor(color)
                }
                Spacer()
                VStack(alignment: .trailing){
                    Text("\(link_desc)")
                        .font(.caption)
                        .foregroundColor(self.colorScheme == .dark ? Color.gray : Color.gray)
                        .padding(.trailing)
                }
            }
            .background(self.colorScheme == .dark ? Color(UIColor(red: 0.11, green: 0.11, blue: 0.12, alpha: 1.00)) : Color(UIColor(red: 0.95, green: 0.98, blue: 1.00, alpha: 1.00)))
            .cornerRadius(10)
        }
    }
}
