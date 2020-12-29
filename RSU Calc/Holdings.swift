//
//  Holdings.swift
//  RSU Calc
//
//  Created by Dudu Twizer on 30/11/2020.
//

import SwiftUI
import SwiftUICharts

extension EditMode {

    mutating func toggle() {
        self = self == .active ? .inactive : .active
    }
}

struct Holdings: View {
    @EnvironmentObject var user_data: current_user_data
    @Environment(\.colorScheme) var colorScheme
    @Binding var currencyFormatter: NumberFormatter
    @Binding var showing_ADD_RSU_Sheet : Bool
    @State var change_view_to_vested : Bool = false
    var body: some View {
            VStack(alignment: .leading)
            {
                if(!user_data.isDataSetEmpty())
                {
                GroupBox(label: Text("RSU List").font(.system(size: 14, weight: .heavy, design: .default)))
                    {
                    
                Toggle("Show by vesting date", isOn: $change_view_to_vested.animation()).padding(.horizontal, 10)
                    .onReceive([self.change_view_to_vested].publisher.first()) { (value) in
                        if(change_view_to_vested && !user_data.sorted_by_vested)
                                {
                                    user_data.myStocks.sort(by: {$0.vested_date < $1.vested_date})
                                    user_data.sorted_by_vested = true
                                }
                        else if (user_data.sorted_by_vested && !change_view_to_vested)
                                {
                                    user_data.myStocks.sort(by: {$0.purchase_date < $1.purchase_date})
                                    user_data.sorted_by_vested = false
                                }
                       }
                List {
                    ForEach(user_data.myStocks, id: \.self) { stock in
                        NavigationLink(destination:
                                    OneStockFocus(stock: stock).environmentObject(user_data)
                        ) {
                            ZStack
                            {
                                Text(stock.stock_symbol + " (" + String(stock.stock_amount) + ")")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                Text(change_view_to_vested ? stock.vested_date : stock.purchase_date, style: .date)
                                .frame(maxWidth: .infinity, alignment: .trailing)
                            }
                        }
                    }
                    .onDelete(perform: delete)
                }
                    }
                }
                else
                {
                    Text("No Data")
                }
                    
            }.navigationBarTitle("Portfolio", displayMode: .inline)
            
    }
    
    func edit(at offsets: IndexSet) {
        print(offsets)
    }
    
    func setLocal()
    {
        let f = NumberFormatter()
        f.numberStyle = .currency
        f.locale = Locale(identifier: user_data.mySettings.local_code)
        f.maximumFractionDigits = 0
        self.currencyFormatter = f
    }
    
    func delete(at offsets: IndexSet) {
        user_data.myStocks.remove(atOffsets: offsets)
        user_data.FindAndDeleteCompanyFromWatch()
        user_data.savetoDisk()
    }

}

struct Holdings_Previews: PreviewProvider {
    static var user_data = current_user_data()
    static var previews: some View {
        Holdings(currencyFormatter: .constant(NumberFormatter()), showing_ADD_RSU_Sheet: .constant(false))
            .environmentObject(user_data)
    }
}

struct Summary_Portfolio_Stack_Previews: PreviewProvider {
    static var user_data = current_user_data()
    static var previews: some View {
        Summary_Portfolio_Stack(currencyFormatter: .constant(NumberFormatter()), showing_ADD_RSU_Sheet: .constant(false))
            .environmentObject(user_data)
    }
}


struct Summary_Portfolio_Stack: View {
    @Binding var currencyFormatter: NumberFormatter
    @Binding var showing_ADD_RSU_Sheet: Bool
    @EnvironmentObject var user_data: current_user_data
    @Environment(\.colorScheme) var colorScheme
    var body: some View {
        NavigationView
        {
            ScrollView {
        VStack(alignment: .center)
            {
            
            PieChartView(data: [user_data.calculate_ByDate_Double(targetDate: Date(), show_by_vest: true, show_withTaxDeduction: false),user_data.calculate_ByDate_Double(targetDate: Calendar.current.date(byAdding: .year, value: 100, to: Date())!, show_by_vest: true, show_withTaxDeduction: false)-user_data.calculate_ByDate_Double(targetDate: Date(), show_by_vest: true, show_withTaxDeduction: false)], title: "Total portfolio value",titleValue: user_data.calculate_ByDate_Double(targetDate: Calendar.current.date(byAdding: .year, value: 100, to: Date())!, show_by_vest: true, show_withTaxDeduction: false), legend: "Available Unavailable", form: ChartForm.extraLarge, currencyFormatter: currencyFormatter) // legend is optional
                .padding(.top)
            
            Text("")
                .padding(.top)
            
            Text("Stocks in the portfolio: ")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.system(size: 14, weight: .heavy, design: .default))
                    .padding(.leading)
            ForEach(user_data.myCompanies, id: \.self) { item in
                ZStack
                {
                    Text("\(item.name ?? "")")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.system(size: 14, weight: .light, design: .default))
                        .padding(.leading)
                    Text("\(currencyFormatter.string(from: NSNumber(value: user_data.getStockPrice(stock_symbol: item.symbol!)))!)")
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .font(.system(size: 14, weight: .heavy, design: .default))
                        .padding(.trailing)
                }
               
            }
            
            
            
            Text("Portfolio summary: ")
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.system(size: 14, weight: .heavy, design: .default))
                .padding(.leading)
                .padding(.top)
                
            Group
            {
                ZStack
                {
                    Text("Portfolio total vested shares")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.system(size: 14, weight: .light, design: .default))
                        .padding(.leading)
                    Text("\(user_data.countVested_toToday())")
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .font(.system(size: 14, weight: .heavy, design: .default))
                        .padding(.trailing)
                }
            
                ZStack
                {
                    Text("Portfolio total granted shares")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.system(size: 14, weight: .light, design: .default))
                        .padding(.leading)
                    Text("\(user_data.countGranted_ToToday())")
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .font(.system(size: 14, weight: .heavy, design: .default))
                        .padding(.trailing)
                }
            
                ZStack
                {
                    Text("Portfolio total value (Before Tax)")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.system(size: 14, weight: .light, design: .default))
                        .padding(.leading)
                    Text("\(currencyFormatter.string(from: NSNumber(value: user_data.calculate_ByDate_Double(targetDate: Date(), show_by_vest: true, show_withTaxDeduction: false)))!)")
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .font(.system(size: 14, weight: .heavy, design: .default))
                        .padding(.trailing)
                }
            
                ZStack
                {
                    Text("Portfolio total Net value (After Tax)")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.system(size: 14, weight: .light, design: .default))
                        .padding(.leading)
                    Text("\(currencyFormatter.string(from: NSNumber(value:user_data.calculate_ByDate_Double(targetDate: Date(), show_by_vest: true, show_withTaxDeduction: true)))!)")
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .font(.system(size: 14, weight: .heavy, design: .default))
                        .padding(.trailing)
                }
            
                ZStack
                {
                    Text("Portfolio future value (Before Tax)")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.system(size: 14, weight: .light, design: .default))
                        .padding(.leading)
                    Text("\(currencyFormatter.string(from: NSNumber(value:user_data.calculate_ByDate_Double(targetDate: Calendar.current.date(byAdding: .year, value: 100, to: Date())!, show_by_vest: true, show_withTaxDeduction: false)))!)")
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .font(.system(size: 14, weight: .heavy, design: .default))
                        .padding(.trailing)
                }
            
                ZStack
                {
                    Text("Portfolio future net value (After Tax)")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.system(size: 14, weight: .light, design: .default))
                        .padding(.leading)
                    Text("\(currencyFormatter.string(from: NSNumber(value:user_data.calculate_ByDate_Double(targetDate: Calendar.current.date(byAdding: .year, value: 100, to: Date())!, show_by_vest: true, show_withTaxDeduction: true)))!)")
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .font(.system(size: 14, weight: .heavy, design: .default))
                        .padding(.trailing)
                }
            }
            Spacer()
        }.navigationBarTitle("Portfolio", displayMode: .inline)
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
            }.frame(maxWidth: 800)
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
    
    
}
//
//struct Carousel_Stocks: View {
//    @Binding var currencyFormatter: NumberFormatter
//    @EnvironmentObject var user_data: current_user_data
//    var body: some View {
//        ScrollView(.horizontal)
//        {
//            ScrollViewReader { value in
//                HStack
//                {
//                    Text("Stocks in the Portfolio: ")
//                        .font(.title2)
//                        .padding()
//                        .id(1)
//                    // all watched stocks
//                    ForEach(user_data.getUniqueSymbolList(), id: \.self) { item in
//                        VStack
//                        {
//                        Text("\(item.uppercased())")
//                            .font(.title2)
//                            Text((currencyFormatter.string(from: NSNumber(value:(user_data.getStockPrice(stock_symbol: item))))!))
//                            .font(.title2)
//                        }.padding(3)
//                    }.id(2)
//
//                    Text("Portfolio total vested : \(user_data.calculatedField.Portfolio_total_vested)")
//                        .font(.title2)
//                        .padding()
//                        .id(3)
//
//                    Text("Portfolio total granted : \(user_data.calculatedField.Portfolio_total_granted)")
//                        .font(.title2)
//                        .padding()
//                        .id(4)
//
//                    Text("Portfolio total value : \(currencyFormatter.string(from: NSNumber(value: user_data.calculatedField.Portfolio_total_value_Total_Earnings))!)")
//                        .font(.title2)
//                        .padding()
//                        .id(5)
//
//                    Text("Portfolio total value (Net) : \(currencyFormatter.string(from: NSNumber(value:user_data.calculatedField.Portfolio_total_value_Net))!)")
//                        .font(.title2)
//                        .padding()
//                        .id(6)
//                }.overlay(RoundedRectangle(cornerRadius: 30)
//                            .stroke(Color.white, lineWidth: 1))
//                .padding(.horizontal)
//            }
//        }
//    }
//}

struct OneStockFocus: View {
    @State var stock : RSU_item
    @Environment(\.editMode) var mode
    @EnvironmentObject var user_data: current_user_data
    @State private var amount: String = ""
    @State private var granted_price: String = "0"
    @State private var granted_date = Date()
    @State var ErrorMsg = ""
    @State var showError: Bool = false
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
    @State private var vested_date =  Calendar.current.date(byAdding: .year, value: 2, to: Date())!
    var body: some View {
        List
        {
            HStack
            {
                Text("Stock Symbol")
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text(String(stock.stock_symbol))
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }.padding(.top)
            HStack
            {
                Text("Number of RSUs")
                    .frame(maxWidth: .infinity, alignment: .leading)
                if self.mode?.wrappedValue.isEditing ?? true {
                    TextField("Amount", text: $amount)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(UIKeyboardType.numberPad)
                }
                else
                {
                Text(String(stock.stock_amount))
                    .frame(maxWidth: .infinity, alignment: .trailing)
                }
            }.padding(.top)
            HStack
            {
                Text("Granted Date")
                    .frame(maxWidth: .infinity, alignment: .leading)
                if self.mode?.wrappedValue.isEditing ?? true {
                    DatePicker(selection: $granted_date,
                        in: dateClosedRange,
                        displayedComponents: .date,
                        label: {
                            Text("")
                            
                        }
                    )
                }
            else
                {
                Text(stock.purchase_date, style: .date)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                }
            }.padding(.top)
            HStack
            {
                Text("Vested Date")
                    .frame(maxWidth: .infinity, alignment: .leading)
                if self.mode?.wrappedValue.isEditing ?? true {
                    DatePicker(selection: $vested_date,
                       in: dateClosedRange,
                        displayedComponents: .date,
                        label: {
                            Text("")
                        }
                    )
                }
                else
                {
                Text(stock.vested_date, style: .date)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                }
            }.padding(.top)
            HStack
            {
                Text("Granted Price")
                    .frame(maxWidth: .infinity, alignment: .leading)
                if self.mode?.wrappedValue.isEditing ?? true {
                    TextField("$1", text: $granted_price)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(UIKeyboardType.numberPad)
                }
                else
                {
                Text(String(stock.original_price))
                    .frame(maxWidth: .infinity, alignment: .trailing)
                }
            }.padding(.top)
            if self.mode?.wrappedValue.isEditing ?? true {
                 Text("Save")
                    .bold()
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .center)
                    .onTapGesture {
                        save()
                    }
                if(showError)
                {
                    Text(ErrorMsg)
                    .foregroundColor(.red)
                }
            }
            else {
                 Text("")
            }
        }.onAppear()
        {
            self.amount = String(stock.stock_amount)
            self.granted_price = String(stock.original_price)
            self.granted_date = stock.purchase_date
            self.vested_date = stock.vested_date
        }
        .padding()
        .navigationTitle(Text(stock.stock_symbol) + Text(" ") + Text(stock.purchase_date, style: .date))
        .navigationBarItems(trailing: EditButton())
        .navigationBarTitleDisplayMode(.inline)
    }
    
    func save() {
        
        let granted_price = Double(self.granted_price) ?? 0
        let user_stock_amount = Int(self.amount) ?? 0
        
        if(user_stock_amount < 1)
        {
            withAnimation
            {
                showError = true
                ErrorMsg = "RSU Amount must be more than 0"
            }
            return
        }
        else if(granted_price < 1)
        {
            withAnimation
            {
                showError = true
                ErrorMsg = "Granted Price must be more than 0$"
            }
            return
        }
        else
        {
            showError = false
        }
        
        let new_rsu = RSU_item(id: stock.id, stock_symbol: stock.stock_symbol, purchase_date: self.granted_date, vested_date: self.vested_date, original_price: Double(self.granted_price) ?? 0, stock_amount: Int(self.amount) ?? 0)
        
        user_data.updateMyStock(for: stock, to: new_rsu)
        self.stock = new_rsu
        self.mode?.wrappedValue.toggle()
    }
}
