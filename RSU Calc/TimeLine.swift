//
//  TimeLine.swift
//  RSU Calc
//
//  Created by Dudu Twizer on 06/12/2020.
//

import SwiftUI

struct TimeLine: View {
    @EnvironmentObject var user_data: current_user_data
    @State private var showing_ADD_RSU_Sheet: Bool = false
    @Binding var currencyFormatter: NumberFormatter

    var body: some View {
        NavigationView
        {
                VStack
                {
                    if(!user_data.isDataSetEmpty())
                    {
                    DashboardCard(currencyFormatter: $currencyFormatter)
                    .environmentObject(user_data)
                    }
                    else
                    {
                        Text("No data")
                    }
                }.frame(maxWidth: 800)
                .onAppear()
                    {
                    self.setLocal()
                    }
                .navigationBarTitle("RSU Calculator", displayMode: .inline)
                .navigationBarItems(
                        leading:
                            currency_menu(currencyFormatter: $currencyFormatter).environmentObject(user_data)
                    ,
                        trailing:
                            Button (action: {
                                self.showing_ADD_RSU_Sheet = true
                            })
                            {
                                Image(systemName: "plus.app.fill").foregroundColor(.white)
                            }
                    )
        }
        .navigationViewStyle(StackNavigationViewStyle())
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

struct TimeLine_Previews: PreviewProvider {
    static var user_data = current_user_data()
    static var previews: some View {
        TimeLine(currencyFormatter: .constant(NumberFormatter()))
            .environmentObject(user_data)
    }
}

struct DashboardCard: View {
    @EnvironmentObject var user_data: current_user_data
    @Environment(\.colorScheme) var colorScheme
    @Binding var currencyFormatter: NumberFormatter
    @State var id : Int = 0
    @State var flag_found: Bool = false
    @State var isTotalViewOpen : Array<Bool> = [false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false]
    
    let formatter  = RelativeDateTimeFormatter()
    var date_formatter : DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }
    
    var per_formatter : NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        formatter.minimumIntegerDigits = 1
        formatter.maximumIntegerDigits = 3
        formatter.maximumFractionDigits = 0
        return formatter
    }
    

    
    var body: some View {
        ScrollView
        {
            ScrollViewReader { value in
        ForEach(user_data.myStocks.indices, id: \.self) { index in
            HStack (alignment: .center)
            {
                Text("\(user_data.formatDate(date: user_data.myStocks[index].vested_date, withLineBreak: false))")
                    .foregroundColor(nil)
                    .font(.caption)
                   .fontWeight(.semibold)
                    .frame(width: 50)
                    
                GroupBox(label: Text("Holdings as of \(date_formatter.string(from: user_data.myStocks[index].vested_date))"))
                {
                    
                    VStack(alignment: .leading)
                    {
                        Text("New \(user_data.myStocks[index].stock_amount) Shares\nEarnings : \(currencyFormatter.string(from: NSNumber(value: user_data.calculateTotal_Earnings(RSU: user_data.myStocks[index])))!)\nNet pay: \(currencyFormatter.string(from: NSNumber(value: user_data.calculateNet(RSU: user_data.myStocks[index])))!)")
                            .font(.title2)
                            .fontWeight(.bold)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.top, 5)
                            .shadow(color: Color.black.opacity(0.2), radius: 1)
                        ZStack
                        {
                            Text("Original grant price")
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Text("\(currencyFormatter.string(from: NSNumber(value:(user_data.getOriginalStockPrice (RSU: user_data.myStocks[index]))))!)")
                                .frame(maxWidth: .infinity, alignment: .trailing)
                                .foregroundColor(Color(self.colorScheme == .dark ? UIColor(red: 0.73, green: 0.97, blue: 0.31, alpha: 1.00) : UIColor(red: 0.15, green: 0.22, blue: 0.12, alpha: 1.00)))
                                .font(.system(size: 14, weight: .heavy, design: .default))
                        }
                        
                        if(isTotalViewOpen[index])
                        {
                            ZStack
                            {
                                Text("Ordinary Income")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                Text("\(currencyFormatter.string(from: NSNumber(value: user_data.calculateOrdinaryIncomePart(RSU: user_data.myStocks[index])))!) (\(per_formatter.string(from: NSNumber(value:(user_data.calculateOrdinaryIncomePart(RSU: user_data.myStocks[index])/user_data.calculateTotal_Earnings(RSU: user_data.myStocks[index]))))!))")
                                    .frame(maxWidth: .infinity, alignment: .trailing)
                                    .font(.system(size: 14, weight: .heavy, design: .default))
                                    .foregroundColor(Color(self.colorScheme == .dark ? UIColor(red: 0.73, green: 0.97, blue: 0.31, alpha: 1.00) : UIColor(red: 0.15, green: 0.22, blue: 0.12, alpha: 1.00)))
                            }
                            ZStack
                            {
                                Text("Capital Gain")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                Text("\(currencyFormatter.string(from: NSNumber(value: user_data.calculateCapitalGainPart(RSU: user_data.myStocks[index])))!) (\(per_formatter.string(from: NSNumber(value:(user_data.calculateCapitalGainPart(RSU: user_data.myStocks[index])/Double(user_data.myStocks[index].stock_amount)/(user_data.getOriginalStockPrice(RSU: user_data.myStocks[index])))))!) Yield)")
                                    .frame(maxWidth: .infinity, alignment: .trailing)
                                    .font(.system(size: 14, weight: .heavy, design: .default))
                                    .foregroundColor(Color(self.colorScheme == .dark ? UIColor(red: 0.73, green: 0.97, blue: 0.31, alpha: 1.00) : UIColor(red: 0.15, green: 0.22, blue: 0.12, alpha: 1.00)))
                            }
                            ZStack
                            {
                                Text("Tax1 (Ordinary) ")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                Text("\(currencyFormatter.string(from: NSNumber(value: user_data.calculateOrdinaryIncomeTaxPart(RSU: user_data.myStocks[index])))!) (\(per_formatter.string(from: NSNumber(value:(user_data.calculateOrdinaryIncomeTaxPart(RSU: user_data.myStocks[index])/user_data.calculateTotal_Earnings(RSU: user_data.myStocks[index]))))!))")
                                    .frame(maxWidth: .infinity, alignment: .trailing)
                                    .font(.system(size: 14, weight: .heavy, design: .default))
                                    .foregroundColor(Color(UIColor(red: 0.81, green: 0.17, blue: 0.12, alpha: 1.00)))
                            }
                            ZStack
                            {
                                Text("Tax2 (Capital)")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                Text("\(currencyFormatter.string(from: NSNumber(value: user_data.calculateCapitalGainTaxPart(RSU: user_data.myStocks[index])))!) (\(per_formatter.string(from: NSNumber(value:(user_data.calculateCapitalGainTaxPart(RSU: user_data.myStocks[index])/user_data.calculateTotal_Earnings(RSU: user_data.myStocks[index]))))!))")
                                    .frame(maxWidth: .infinity, alignment: .trailing)
                                    .font(.system(size: 14, weight: .heavy, design: .default))
                                    .foregroundColor(Color(UIColor(red: 0.81, green: 0.17, blue: 0.12, alpha: 1.00)))
                            }
                            ZStack
                            {
                                Text("Total to date:\n\(user_data.countVested_toDate(targetDate: user_data.myStocks[index].vested_date)) vested (out of \(user_data.countGranted_toDate(targetDate: user_data.myStocks[index].vested_date)) granted)\nEarnings:  \(currencyFormatter.string(from: NSNumber(value: user_data.calculate_ByDate_Double(targetDate: user_data.myStocks[index].vested_date, show_by_vest: true, show_withTaxDeduction: false)))!)\nNet pay:  \(currencyFormatter.string(from: NSNumber(value: user_data.calculate_ByDate_Double(targetDate: user_data.myStocks[index].vested_date, show_by_vest: true, show_withTaxDeduction: true)))!)")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .padding(.top)
                            }
                        }
                    }
                }.padding()
                .padding(.trailing)
                .groupBoxStyle(CardGroupBoxStyle())
                .onAppear()
                {
                    if (user_data.myStocks.indices.contains(index) && !self.flag_found)
                    {
                        if(user_data.myStocks[index].vested_date > Date())
                        {
                            self.flag_found = true
                            id = index
                            withAnimation
                            {
                                value.scrollTo(id, anchor: .top)
                            }
                        }

                    }
                }
                .onTapGesture()
                {
                    withAnimation {
                        isTotalViewOpen[index].toggle()
                        id = index
                        withAnimation
                        {
                            value.scrollTo(id, anchor: .top)
                        }
                    }
                }
            }.id(index)
        }
            }
        }
    }
    
   
}

