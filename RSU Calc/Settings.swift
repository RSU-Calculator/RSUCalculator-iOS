//
//  Settings.swift
//  RSU Calc
//
//  Created by Dudu Twizer on 02/12/2020.
//

import SwiftUI

struct Settings: View {
    @State var custom_stock_price = false
    @Binding var currencyFormatter: NumberFormatter
    @EnvironmentObject var user_data: current_user_data
    @State var custom_price_user_input = ""
    @State var selectedStock = ""
    @State var user_selected = false
    
    var per_formatter : NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        formatter.minimumIntegerDigits = 1
        formatter.maximumIntegerDigits = 3
        formatter.maximumFractionDigits = 0
        return formatter
    }
    
    var body: some View {
        NavigationView
        {
            Form
            {
            Section(header: Text("TAX Settings"))
            {
                HStack
                {
                Text("Capital tax rate: \(per_formatter.string(from: NSNumber(value: user_data.mySettings.capitalGainIncomeTax))!)")
                Stepper("", onIncrement: {
                    user_data.mySettings.capitalGainIncomeTax += 0.01
                    user_data.savetoDisk()

                }, onDecrement: {
                    user_data.mySettings.capitalGainIncomeTax -= 0.01
                    user_data.savetoDisk()
                })
                }
                HStack
                {
                Text("Ordinary income tax rate: \(per_formatter.string(from: NSNumber(value: user_data.mySettings.ordinaryIncomeTax))!)")
                Stepper("", onIncrement: {
                    user_data.mySettings.ordinaryIncomeTax += 0.01
                    user_data.savetoDisk()
                }, onDecrement: {
                    user_data.mySettings.ordinaryIncomeTax -= 0.01
                    user_data.savetoDisk()
                })
                }
                HStack
                {
                Text("Other ordinary income tax rate: \(per_formatter.string(from: NSNumber(value: user_data.mySettings.customTax1))!)")
                Stepper("", onIncrement: {
                    user_data.mySettings.customTax1 += 0.01
                    user_data.savetoDisk()
                }, onDecrement: {
                    user_data.mySettings.customTax1 -= 0.01
                    user_data.savetoDisk()
                })
                }
                HStack
                {
                Text("Stocks lock-up period:  \(Int(user_data.mySettings.numberOfYearsForTax)) years")
                Stepper("", onIncrement: {
                    user_data.mySettings.numberOfYearsForTax += 1.0
                    user_data.savetoDisk()
                }, onDecrement: {
                    user_data.mySettings.numberOfYearsForTax -= 1.0
                    user_data.savetoDisk()
                })
                }
            }
//            currency_menu(currencyFormatter: $currencyFormatter).environmentObject(user_data)
//            Section(header: Text("Simulation"))
//            {
//                Toggle("Custom stock price" , isOn: $custom_stock_price.animation())
//                if(custom_stock_price)
//                {
//                    Text("Select Stock")
//                    ForEach(user_data.getUniqueSymbolList(), id: \.self) { item in
//                        Text("\(item.uppercased())")
//                            .frame(maxWidth: .infinity, alignment: .leading)
//                            .onTapGesture {
//                                editStock(stockSymbol: item)
//                            }
//                    }
//                    if(user_selected)
//                    {
//                        HStack
//                        {
//                            Text("Enter custom value for: \(selectedStock.uppercased()) ($):")
//                            TextField("", text:  $custom_price_user_input)
//                                .textFieldStyle(RoundedBorderTextFieldStyle())
//                                .keyboardType(UIKeyboardType.numberPad)
//                        }
//                    }
//                }
//            }
//            .onTapGesture {
//                endEditing()
//            }
//            .onDisappear()
//            {
//                if(!custom_stock_price)
//                {
//                    user_data.mySettings.custom_stock_price = false
//                }
//                else if(!selectedStock.isEmpty && !custom_price_user_input.isEmpty)
//                {
//                    user_data.mySettings.custom_stock_price = true
//                    user_data.mySettings.custom_stock_price_stockSymbol = selectedStock
//                    user_data.mySettings.custom_stock_price_value = (Double(custom_price_user_input) ?? 0) * Double(user_data.mySettings.currency_rate_results.rates[user_data.mySettings.currency] ?? 0)
//                }
//            }
            }.frame(maxWidth: 800)
            
            .navigationBarTitle("Settings", displayMode: .inline)
        }.navigationViewStyle(StackNavigationViewStyle())
    }
    
    func editStock(stockSymbol: String) {
        withAnimation
        {
            self.selectedStock = stockSymbol
            self.user_selected = true
        }
    }
    
    private func endEditing() {
            UIApplication.shared.endEditing()
        }
}

struct Settings_Previews: PreviewProvider {
    static var previews: some View {
        Settings(currencyFormatter: .constant(NumberFormatter()))
    }
}
