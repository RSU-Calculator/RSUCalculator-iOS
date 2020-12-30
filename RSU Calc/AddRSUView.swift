//
//  AddRSUView.swift
//  RSU Calc
//
//  Created by Dudu Twizer on 30/11/2020.
//

import SwiftUI

extension Formatter {
    static let withSeparator: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ","
        return formatter
    }()
}

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

extension Numeric {
    var formattedWithSeparator: String { Formatter.withSeparator.string(for: self) ?? "" }
}

class Proper_Date: ObservableObject {
    @Published var value: Date = Date()
}



struct AddRSUView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var user_data: current_user_data
    @Environment(\.colorScheme) var colorScheme
    @Binding var currencyFormatter: NumberFormatter
    @State private var amount: String = ""
    @State var user_stock_amount = 0
    @State private var granted_price: String = "0"
    @State private var granted_date = Proper_Date()
    @State private var vested_date =  Proper_Date()
    @State private var total_value = 0.0
    @State private var profit = 0.0
    @State private var total_value_today = 0.0
    @State var ErrorMsg = ""
    @State var showError: Bool = false
    @State var showVested : Bool = false
    @State var times = 0
    @State var stock_value: Double = 0.0
    @State var selected : StockObject = StockObject()
    @State var show_search_for_stock : Bool = true
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
    @State var disableForm: Bool = true
    var body: some View {
        ScrollView
        {
        VStack
        {
            GroupBox(label: Text("Add new RSU").bold())
        {
            Text(selected.name == "" ? "Tap to search for a stock" : "\(selected.name ?? "") (Click to change)")
                .bold()
                .frame(maxWidth: .infinity, alignment: .leading)
                .onTapGesture {
                    show_search_for_stock = true
                }
                .padding(.top)
            
            HStack
            {
            Text("Number of RSUs")
            .frame(maxWidth: .infinity, alignment: .leading)
            TextField("Amount", text: $amount)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(UIKeyboardType.numberPad)
            }.padding(.top)
            
            HStack
            {
            Text("Granted Price ($)")
                .frame(maxWidth: .infinity, alignment: .leading)
            TextField("$1", text: $granted_price)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(UIKeyboardType.numberPad)
            }

                DatePicker(selection: $granted_date.value,
                in: dateClosedRange,
                displayedComponents: .date,
                label: {
                    Text("Granted Date")
                })
                .onReceive(granted_date.$value) { date in
                            if(date != granted_date.value)
                            {
                                self.vested_date.value = date
                                withAnimation
                                {
                                    showVested = true
                                }
                            }
                        }
               if(showVested)
               {
               DatePicker(selection: $vested_date.value,
               in: dateClosedRange,
                displayedComponents: .date,
                label: {
                    Text("Vested Date")
                }
               )
               }
            
            ZStack{
            Button(action: {calculate()})
            {
                floatingBtnGradient(ison: .constant(false))
                    .cornerRadius(10)
            }
                
            Text("Calculate")
            .frame(maxWidth: .infinity)
                .foregroundColor(self.colorScheme == .dark ? .white : .white)
            }.padding(.bottom , 5)
            
            if(showError)
            {
                Text(ErrorMsg)
                .foregroundColor(.red)
            }
                
        }.groupBoxStyle(CardGroupBoxStyle_clear())
        .padding()
        if(!disableForm)
        {
        GroupBox
        {
            
            HStack
            {
            Text("Market value")
            .frame(maxWidth: .infinity, alignment: .leading)
                VStack(alignment: .trailing)
                {
                    Text("\(user_stock_amount) * \(Int(stock_value.rounded())) =")
                        .font(.caption)
                    Text("\(currencyFormatter.string(from: NSNumber(value: self.total_value_today))!)")
                        .bold()
                }
            .frame(maxWidth: .infinity, alignment: .trailing)
            }.padding(.top, 5)

            HStack
            {
            Text("Granted value")
            .frame(maxWidth: .infinity, alignment: .leading)
                VStack(alignment: .trailing)
                {
                    Text("\(user_stock_amount) * \(Int(Double(granted_price)?.rounded() ?? 0)) * \(String(format: "%.02f" , Double(user_data.mySettings.currency_rate_results.rates[user_data.mySettings.currency] ?? 0))) =")
                        .font(.caption)
                    Text("\(currencyFormatter.string(from: NSNumber(value: self.total_value))!)")
                        .bold()
                }
            .frame(maxWidth: .infinity, alignment: .trailing)
            }.padding(.top, 5)
            HStack
            {
            Text("Profit")
            .frame(maxWidth: .infinity, alignment: .leading)
                VStack(alignment: .trailing)
                {
                    Text("\(Int(total_value_today.rounded())) - \(Int(total_value.rounded())) =")
                        .font(.caption)
                    Text("\(currencyFormatter.string(from: NSNumber(value: self.profit))!)")
                        .bold()
                }
            .frame(maxWidth: .infinity, alignment: .trailing)
            }.padding(.top, 5)
        }.padding(
        ).groupBoxStyle(CardGroupBoxStyle_clear())
        }
        VStack
            {
            
            ZStack{
            Button(action: {
                add_new()
                clean()
            })
            {
                floatingBtnGradient(ison: $disableForm)
                    .cornerRadius(10)
            }
            .disabled(disableForm)
            Text("Save & Add New")
            .frame(maxWidth: .infinity)
                .foregroundColor(self.colorScheme == .dark ? .white : .white)
            }.padding(.bottom , 5)
            
            ZStack{
            Button(action: {
                add_new()
                self.presentationMode.wrappedValue.dismiss()
            })
            {
                floatingBtnGradient(ison: $disableForm)
                    .cornerRadius(10)
            }
            .disabled(disableForm)
            Text("Save & Close")
            .frame(maxWidth: .infinity)
                .foregroundColor(self.colorScheme == .dark ? .white : .white)
            }.padding(.bottom , 5)
            }
        }.onTapGesture {
            endEditing()
        }
        }.sheet(isPresented: $show_search_for_stock) {
            StockSearchFromAPI(selected: $selected)
                .onDisappear()
                {
                    print("sheet search closed")
                    user_data.loadStockData(stockSymbol: self.selected.symbol!)
                }
        }
    }
    
    func calculate() {
        user_data.loadStockData(stockSymbol: self.selected.symbol!)
        let granted_price = Double(self.granted_price) ?? 0
        self.user_stock_amount = Int(self.amount) ?? 0
        self.stock_value = user_data.getStockPrice(stock_symbol: selected.symbol!)
        user_data.loadStockData(stockSymbol: selected.symbol!)
        if(user_stock_amount < 1)
        {
            withAnimation
            {
                showError = true
                disableForm = true
                ErrorMsg = "RSU Amount must be more than 0"
            }
        }
        
        else if(stock_value <= 0)
        {
            withAnimation
            {
                showError = true
                disableForm = true
                ErrorMsg = "Stock Symbol invalid / not found"
                self.user_data.times -= 1
            }
        }
        
        else if(granted_price < 1)
        {
            withAnimation
            {
                showError = true
                disableForm = true
                ErrorMsg = "Granted Price must be more than 0$"
            }
        }
    
        
        else
        {
            withAnimation
            {
                showError = false
                disableForm = false
                self.total_value = granted_price * Double(user_stock_amount) * Double(user_data.mySettings.currency_rate_results.rates[user_data.mySettings.currency] ?? 0)
                self.total_value_today = stock_value * Double(user_stock_amount)
                self.profit = self.total_value_today - self.total_value
            }
        }
        self.endEditing()
    }
    
    func add_new() {
        if(user_data.isDataSetEmpty())
        {
            self.user_data.myStocks = []
        }
        let tempItem : RSU_item = RSU_item(stock_symbol: self.selected.symbol!, purchase_date: self.granted_date.value, vested_date: self.vested_date.value, original_price: Double(self.granted_price) ?? 0, stock_amount: Int(self.amount) ?? 0)
        self.user_data.myStocks.append(tempItem)
        self.user_data.addCompanyToWatch(StockObject: selected)
        self.user_data.myStocks.sort(by: {$0.vested_date < $1.vested_date})
        self.user_data.sorted_by_vested = true
        self.disableForm = true
        self.showError = false
        self.user_data.savetoDisk()
    }
    
    func clean() {
        self.amount = ""
        self.granted_date = Proper_Date()
        self.vested_date = Proper_Date()
        self.granted_price = ""
        self.disableForm = true
        self.showError = false
    }
    private func endEditing() {
            UIApplication.shared.endEditing()
        }
}

struct AddRSUView_Previews: PreviewProvider {
    static var user_data = current_user_data()
    static var previews: some View {
        AddRSUView(currencyFormatter: .constant(NumberFormatter()))
            .environmentObject(user_data)
//            .colorScheme(.dark)
    }
}
