//
//  SharedStorage.swift
//  RSU Calc
//
//  Created by Dudu Twizer on 30/11/2020.
//

import Foundation
import SwiftUI

struct RSU_item : Identifiable, Hashable, Codable
{
    var id = UUID()
    let stock_symbol : String
    let purchase_date : Date
    let vested_date : Date
    let original_price : Double
    let stock_amount : Int
}


struct UserSettings : Hashable, Codable
{
    
    var currency : String
    let country : String
    var local_code : String
    var currency_rate_results : RateResult
    var custom_stock_price: Bool
    var custom_stock_price_value : Double
    var custom_stock_price_stockSymbol : String
    var ordinaryIncomeTax : Double
    var capitalGainIncomeTax : Double
    var customTax1 : Double
    var numberOfYearsForTax : Double
    
    init() {
        self.country = "USA"
        self.currency = "USD"
        self.local_code = "en_US"
        self.currency_rate_results = RateResult(rates: ["USD":1.0, "ILS":3.5], base: "", date: "")
        self.custom_stock_price = false
        self.custom_stock_price_value = 0.0
        self.custom_stock_price_stockSymbol = ""
        self.ordinaryIncomeTax = 0.50
        self.customTax1 = 0.12
        self.capitalGainIncomeTax = 0.25
        self.numberOfYearsForTax = 2.0
    }
    
}

class current_user_data: ObservableObject {
    @Published var myStocks = Array<RSU_item>()
    @Published var myCompanies = Array<StockObject>()
    @Published var mySettings = UserSettings()
    var formatter  : RelativeDateTimeFormatter {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter
    }
    @Published var sorted_by_vested :Bool = false
    @Published var data_from_api = true
    @Published var cache : [String: Double] = ["":0]
    private var already_running = false
    @Published var times = 0
    init() {
        self.loadFromDisk()
        self.loadRateFromAPI()
        self.FindAndDeleteCompanyFromWatch()
    }
    
    func updateMyStock(for oldstock: RSU_item, to newStock: RSU_item) {
        if let index = myStocks.firstIndex(where: { $0.id == newStock.id }) {
                myStocks[index] = newStock
            }
        }
    
    func FindAndDeleteCompanyFromWatch()
    {
        print("FindAndDeleteCompanyFromWatch")
        var newMyCompanies = Array<StockObject>()
        
        for stock in myStocks {
            if newMyCompanies.firstIndex(where: {$0.symbol == stock.stock_symbol.uppercased()}) != nil
            {
                break
            }
            else
            {
                if(findStockObject(stockSymbol: stock.stock_symbol.uppercased()) != nil)
                {
                    newMyCompanies.append(findStockObject(stockSymbol: stock.stock_symbol.uppercased())!)
                }
            }
        }
        self.myCompanies = newMyCompanies
    }
    
    func addCompanyToWatch(StockObject: StockObject)
    {
        if(findStockObject(stockSymbol: StockObject.symbol!) == nil)
        {
            self.myCompanies.append(StockObject)
        }
    }
    
    func findUserStock(stockSymbol: String) -> RSU_item?
    {
        if let index = myStocks.firstIndex(where: {$0.stock_symbol == stockSymbol})
        {
            return myStocks[index]
        }
        return nil
    }
    
    func findStockObject(stockSymbol: String) -> StockObject?
    {
        if let index = myCompanies.firstIndex(where: {$0.symbol == stockSymbol})
        {
            return myCompanies[index]
        }
        return nil
    }
        
    func loadStockData(stockSymbol: String)
    {
        if(!SharedStorage.storage.checkDatabaseMatch(name: stockSymbol.uppercased()) || data_from_api)
        {
            print("called to go to api! : already_running : \(already_running) times: \(times)")
            if(!already_running && times < 3)
            {
                print("decided that task is not running, start running: ")
                already_running = true
                times = times + 1
                let task = URLSession.shared.stockAPITask(with: URL(string: "https://finnhub.io/api/v1/quote?symbol=\(stockSymbol.uppercased())&token=bv4155f48v6tcp17dsb0")!) { stockAPI, response, error in
                 if let stockAPI = stockAPI {
                    SharedStorage.storage.saveToDatabase(name: stockSymbol.uppercased(), number: stockAPI.c)
                    print("returned from the api with value \(stockAPI.c)")
                 }
                    DispatchQueue.main.async {
                    self.data_from_api = false
                    self.already_running = false
                    }
               }
                task.resume()
            }
        }
    }
    
func loadRateFromAPI()
    {
        guard let url = URL(string: "https://api.exchangeratesapi.io/latest?base=USD") else {
                   print("Invalid URL")
                   return
               }
               let request = URLRequest(url: url)
               URLSession.shared.dataTask(with: request) { data, response, error in
                   if let data = data {
                       if let decodedResponse = try? JSONDecoder().decode(RateResult.self, from: data) {
                           // we have good data – go back to the main thread
                           DispatchQueue.main.async {
                               // update our UI
                            self.mySettings.currency_rate_results = decodedResponse
                           }
                           // everything is good, so we can exit
                           return
                       }
                   }
                   // if we're still here it means there was a problem
                   print("Fetch failed: \(error?.localizedDescription ?? "Unknown error")")
               }.resume()
    }
    func loadFromDisk()
    {
        self.myStocks = SharedStorage.storage.get_array(key: "myStocks") ?? []
        self.mySettings = SharedStorage.storage.get_settings(key: "userSettings") ?? UserSettings()
        self.myCompanies = SharedStorage.storage.get_array_StockObject(key: "myCompanies") ?? []
        self.myStocks.sort(by: {$0.purchase_date < $1.purchase_date})
        self.sorted_by_vested = false
        if myStocks.isEmpty {
            myStocks.append(RSU_item(stock_symbol: "", purchase_date: Date(), vested_date: Date(), original_price: 0, stock_amount: 0))
        }
        self.mySettings.custom_stock_price = false
    }
    
    func mockData()
    {
        self.myStocks = [
            RSU_item(stock_symbol: "AMZN", purchase_date: Date().addingTimeInterval(-31536000), vested_date: Date().addingTimeInterval(-5184000) ,original_price: 1600, stock_amount: 60),
            RSU_item(stock_symbol: "AMZN", purchase_date: Date().addingTimeInterval(-11536000), vested_date: Date().addingTimeInterval(5184000) ,original_price: 2100, stock_amount: 10),
            RSU_item(stock_symbol: "AMZN", purchase_date: Date().addingTimeInterval(-536000), vested_date: Date().addingTimeInterval(-584000) ,original_price: 1100, stock_amount: 20),
            RSU_item(stock_symbol: "AMZN", purchase_date: Date().addingTimeInterval(-136000), vested_date: Date().addingTimeInterval(-184000) ,original_price: 2100, stock_amount: 20)]
        
        self.myStocks.sort(by: {$0.vested_date < $1.vested_date})
        self.savetoDisk()
    }
    
    func savetoDisk()
    {
        SharedStorage.storage.set_array(value: self.myStocks, key: "myStocks")
        SharedStorage.storage.save_array(value: self.myCompanies, key: "myCompanies")
        SharedStorage.storage.save_settings(value: self.mySettings, key: "userSettings")
    }
    
    func calculate_DoubleArray(targetDate: Date, show_by_vest: Bool, show_withTaxDeduction: Bool, RunningSum: Bool) -> [(Double)] {
        if(myStocks.count > 0)
        {
        var stocks : [(Double)] = [calculateTotal_Earnings(RSU:self.myStocks[0])]
        var index = 0
        var tempvalue = 0.0
        for stock in self.myStocks{
                if (index > 0)
                {
                    if(show_by_vest ? (stock.vested_date <= targetDate) : (stock.purchase_date <= targetDate))
                    {
                        tempvalue = RunningSum ? stocks[index-1] : 0.0
                        stocks.append(show_withTaxDeduction ? ((calculateNet(RSU: stock))+tempvalue) : ((calculateTotal_Earnings(RSU: stock))+tempvalue))
                        index+=1
                    }
                }
                else
                {
                    index+=1
                }
        }
        return stocks
        }
        else
        {
            return [0.0]
        }
    }

    
    func get_rate_value(targetDate: Date, show_by_vest: Bool, show_withTaxDeduction: Bool) -> Int
    {
        let today_value = calculate_DoubleArray(targetDate: targetDate, show_by_vest: show_by_vest, show_withTaxDeduction: show_withTaxDeduction, RunningSum: true)
        var granted_value = 0.0
        for stock in self.myStocks {
            if(show_by_vest)
            {
                if(stock.vested_date <= targetDate)
                {
                    granted_value = granted_value + (stock.original_price * Double(stock.stock_amount)*Double(self.mySettings.currency_rate_results.rates[self.mySettings.currency] ?? 0))
                }
            }
            else
            {
                if(stock.purchase_date <= targetDate)
                {
                    granted_value = granted_value + (stock.original_price * Double(stock.stock_amount)*Double(self.mySettings.currency_rate_results.rates[self.mySettings.currency] ?? 0))
                }
            }
        }
        if(today_value.last! > 0 && granted_value != 0)
        {
            let rate = Int(((today_value.last!-granted_value)/granted_value)*100)
            return rate
        }
        else
        {
            return 0
        }
    }
    
    func isDataSetEmpty() -> Bool
    {
        if(self.myStocks.count == 1)
        {
            if(self.myStocks.last?.stock_amount == 0 && self.myStocks.last?.original_price == 0)
            {
                return true
            }
        }
        else
        {
            if (self.myStocks.count == 0)
            {
                return true
            }
        }
        return false
    }
    
    func formatDate(date: Date, withLineBreak: Bool?) -> String {
        let today = Date()
        let formatter  = RelativeDateTimeFormatter()
        
        let diffs = Calendar.current.dateComponents([.month, .year], from: today, to: date)
        var result = ""
        if(diffs.year ?? 0 > 0)
        {
            result += "in \(diffs.year ?? 0)"
            if(diffs.year ?? 0 > 1)
            {
                result += " years"
            }
            else if (diffs.year == 1)
            {
                result += " year"
            }
            
            if (diffs.month ?? 0 > 0)
            {
                if(withLineBreak ?? false)
                {
                    result += "\nand \(diffs.month ?? 0)"
                }
                else
                {
                    result += " and \(diffs.month ?? 0)"
                }
                
            }
            if(diffs.month ?? 0 > 1)
            {
                result += " months"
            }
            else if (diffs.month == 1)
            {
                result += " month"
            }
        }
        else if(diffs.year ?? 0 < 0)
        {
            result += "\(abs(diffs.year ?? 0))"
            if(diffs.year ?? 0 < -1)
            {
                result += " years"
            }
            else if (diffs.year == -1)
            {
                result += " year"
            }
            
            if (diffs.month ?? 0 < -1)
            {
                if(withLineBreak ?? false)
                {
                    result += "\nand \(abs(diffs.month ?? 0))"
                }
                else
                {
                    result += " and \(abs(diffs.month ?? 0))"
                }
            }
            else
            {
                result += " ago"
            }
            if(diffs.month ?? 0 < -1)
            {
                result += " months ago"
            }
            else if (diffs.month == -1)
            {
                result += " month ago"
            }
        }
        else
        {
            result = formatter.localizedString(for: date, relativeTo: Date())
        }
        
        
        return result
    }
    
    func getYearsOfStocks() -> [Int] {
        var years : [Int] = []
        for stock in myStocks {
            years.append(Calendar.current.component(.year,  from: stock.vested_date))
            years.append(Calendar.current.component(.year,  from: stock.purchase_date))
        }
        years = Array(Set(years))
        years = years.sorted()
        let range : [Int] = Array(years.first!...years.last!)
        return range
    }
    
    func get_number_of_months() -> Int {
        var copy1 = myStocks
        var copy2 = myStocks
        copy1.sort(by: {$0.vested_date < $1.vested_date})
        copy2.sort(by: {$0.purchase_date < $1.purchase_date})
        return Calendar.current.dateComponents([.month], from: copy2.first?.purchase_date ?? Date(), to: copy1.last?.vested_date ?? Date()).month ?? 0
    }
    
    func getNextVest() -> Int {
        var copy = myStocks
        
        copy.sort(by: {$0.vested_date < $1.vested_date})
        
        for stock in copy {
            if(stock.vested_date > Date())
            {
                return Calendar.current.dateComponents([.day], from: Date(), to: stock.vested_date).day ?? 0
            }
        }
        return 0
    }
    
    func calculate_StringDoubleArray(targetDate: Date, show_by_vest: Bool, show_withTaxDeduction: Bool, RunningSum: Bool, show_by_year_aggr: Bool, withLineBreak: Bool) -> [(String,Double)]
    {
        var copy = myStocks
        if(myStocks.count > 0)
        {
            var stocks : [(String,Double)] = []
            var index = 0
            var new_item : Double = 0.0
            if show_by_year_aggr
            {
                let years = getYearsOfStocks().sorted()
                var year_sum = 0.0
                for year in years
                {
                    year_sum = 0.0
                    for stock in self.myStocks {
                        if(Calendar.current.component(.year, from: show_by_vest ? stock.vested_date : stock.purchase_date) == year)
                        {
                            new_item = (show_withTaxDeduction ? (calculateNet(RSU: stock)) : (calculateTotal_Earnings(RSU: stock)))
                            year_sum += new_item
                        }
                    }
                    stocks.append((year.description,year_sum))
                }
                return stocks
            }
            else
            {
                if show_by_vest {
                    copy.sort(by: {$0.vested_date < $1.vested_date})
                }
                else
                {
                    copy.sort(by: {$0.purchase_date < $1.purchase_date})
                }
                for stock in copy{
                        if (index > 0)
                        {
                            if(show_by_vest ? (stock.vested_date <= targetDate) : (stock.purchase_date <= targetDate))
                            {
                                new_item = (show_withTaxDeduction ? (calculateNet(RSU: stock)) : (calculateTotal_Earnings(RSU: stock)))
                                new_item = RunningSum ? (new_item + stocks[index-1].1) : (new_item)
                                stocks.append(((formatDate(date: show_by_vest ? stock.vested_date : stock.purchase_date, withLineBreak: withLineBreak)),new_item))
                                index+=1
                            }
                        }
                        else
                        {
                            if(show_by_vest ? (stock.vested_date <= targetDate) : (stock.purchase_date <= targetDate))
                            {
                                new_item = (show_withTaxDeduction ? (calculateNet(RSU: self.myStocks[0])) : (calculateTotal_Earnings(RSU: self.myStocks[0])))
                                stocks = [((formatDate(date: show_by_vest ? self.myStocks[0].vested_date : self.myStocks[0].purchase_date, withLineBreak: withLineBreak)),new_item)]
                                index+=1
                            }
                        }
                }
                return stocks
            }
        }
        else
        {
            return []
        }
    }
    
    func calculateOrdinaryIncomeTaxPart(RSU: RSU_item) -> Double {
        let today_value = getStockPrice(stock_symbol: RSU.stock_symbol) * Double(RSU.stock_amount)
        let original_value = (RSU.original_price * Double(self.mySettings.currency_rate_results.rates[self.mySettings.currency] ?? 0) * Double(RSU.stock_amount))
        
        if(today_value >= original_value)
        {
            let taxes = original_value * (self.mySettings.ordinaryIncomeTax + self.mySettings.customTax1)
            return taxes
        }
        else
        {
            let taxes = today_value * (self.mySettings.ordinaryIncomeTax + self.mySettings.customTax1)
            return taxes
        }
    }
    
    func getStockPrice(stock_symbol: String) -> Double
    {
        var stock_value = 0.0
        if(self.mySettings.custom_stock_price && mySettings.custom_stock_price_stockSymbol.uppercased() == stock_symbol.uppercased())
        {
            return mySettings.custom_stock_price_value
        }
        else
        {
            if(self.cache.keys.contains(stock_symbol.uppercased()))
            {
                stock_value = cache[stock_symbol.uppercased()]!
            }
            else
            {
                self.loadStockData(stockSymbol: stock_symbol.uppercased())
                stock_value = SharedStorage.storage.getFromDatabase(name: stock_symbol.uppercased())
                if(stock_value > 0)
                {
                    self.cache.updateValue(SharedStorage.storage.getFromDatabase(name: stock_symbol.uppercased()), forKey: stock_symbol.uppercased())
                }
            }
            stock_value = stock_value * Double(self.mySettings.currency_rate_results.rates[self.mySettings.currency] ?? 0)
            return Double(stock_value)
        }
    }

    
    func countGranted_toDate(targetDate: Date) -> Int
    {
        var totalGranted = 0
        for stock in self.myStocks{
            if(stock.purchase_date <= targetDate )
            {
                totalGranted = totalGranted + stock.stock_amount
            }
        }
        return totalGranted
    }
    
    func countGranted_ToToday() -> Int
    {
        return countGranted_toDate(targetDate: Date())
    }
    
    func countVested_toToday() -> Int
    {
        return countVested_toDate(targetDate: Date())
    }


    func calculateOrdinaryIncomePart(RSU: RSU_item) -> Double {
        let today_value = getStockPrice(stock_symbol: RSU.stock_symbol) * Double(RSU.stock_amount)
        let amount = RSU.original_price * Double(self.mySettings.currency_rate_results.rates[self.mySettings.currency] ?? 0) * Double(RSU.stock_amount)
        return min(today_value, amount)
    }
    
    func calculateNet(RSU: RSU_item) -> Double {
        var today_value = Double(RSU.stock_amount) * getStockPrice(stock_symbol: RSU.stock_symbol)
        today_value = today_value - calculateCapitalGainTaxPart(RSU: RSU)
        today_value = today_value - calculateOrdinaryIncomeTaxPart(RSU: RSU)
        return today_value
    }
    
    func countVested_toDate(targetDate: Date) -> Int
    {
        var totalVested = 0
        for stock in self.myStocks{
            if(stock.vested_date <= targetDate )
            {
                totalVested = totalVested + stock.stock_amount
            }
        }
        return totalVested
    }
    
    
    func calculateTotal_Earnings(RSU: RSU_item) -> Double {
        let today_value = self.getStockPrice(stock_symbol: RSU.stock_symbol)*Double(RSU.stock_amount)
        return today_value
    }
    
    func getOriginalStockPrice(RSU: RSU_item) -> Double
    {
        var stock_value = RSU.original_price
        stock_value = stock_value * Double(self.mySettings.currency_rate_results.rates[self.mySettings.currency] ?? 0)
        return Double(stock_value)
    }

    
    func calculateCapitalGainTaxPart(RSU: RSU_item) -> Double {
        let today_value = getStockPrice(stock_symbol: RSU.stock_symbol) * Double(RSU.stock_amount)
        let original_value = (RSU.original_price * Double(self.mySettings.currency_rate_results.rates[self.mySettings.currency] ?? 0) * Double(RSU.stock_amount))
        var taxes = 0.0
        let lock_period = Calendar.current.date(byAdding: .year, value: Int(self.mySettings.numberOfYearsForTax), to: RSU.purchase_date)!
        if(today_value >= original_value)
        {
            if(lock_period > Date())
            {
                taxes = (today_value - original_value) * (self.mySettings.ordinaryIncomeTax + self.mySettings.customTax1)
            }
            else
            {
                taxes = (today_value - original_value) * self.mySettings.capitalGainIncomeTax
            }
            return taxes
        }
        else
        {
            return taxes
        }
    }

    
    func calculateCapitalGainPart(RSU: RSU_item) -> Double {
        let today_value = getStockPrice(stock_symbol: RSU.stock_symbol) * Double(RSU.stock_amount)
        let original_value = (RSU.original_price * Double(self.mySettings.currency_rate_results.rates[self.mySettings.currency] ?? 0) * Double(RSU.stock_amount))
        let amount = today_value - original_value
        return amount
    }
    
    
    func calculate_ByDate_Double(targetDate: Date, show_by_vest: Bool, show_withTaxDeduction: Bool) -> Double
    {
        var totalTotal_Earnings = 0.0
        var copy = myStocks
        for stock in copy{
            if show_by_vest {
                copy.sort(by: {$0.vested_date < $1.vested_date})
            }
            else
            {
                copy.sort(by: {$0.purchase_date < $1.purchase_date})
            }
            if(show_by_vest)
            {
                if(stock.vested_date <= targetDate )
                {
                    if(!show_withTaxDeduction)
                    {
                        totalTotal_Earnings = totalTotal_Earnings + calculateTotal_Earnings(RSU: stock)
                    }
                    else
                    {
                        totalTotal_Earnings = totalTotal_Earnings + calculateNet(RSU: stock)
                    }
                }
            }
            else
            {
                if(stock.purchase_date <= targetDate )
                {
                    if(!show_withTaxDeduction)
                    {
                        totalTotal_Earnings = totalTotal_Earnings + calculateTotal_Earnings(RSU: stock)
                    }
                    else
                    {
                        totalTotal_Earnings = totalTotal_Earnings + calculateNet(RSU: stock)
                    }
                }
            }
        }
        return totalTotal_Earnings
    }
    
    func getUniqueSymbolList() -> [String] {
        var symbols: [String] = []
        for e in self.myStocks {
            symbols.append(e.stock_symbol)
        }
        symbols = symbols.unique()
        return symbols
    }
}

public class SharedStorage: ObservableObject
{
    public static let storage = SharedStorage()
    
    let sharedContainer = UserDefaults(suiteName: "group.twizer")
    
    init() {
    }
    
    func save_settings(value: UserSettings, key: String)
    {
        do {
            // Create JSON Encoder
            let encoder = JSONEncoder()

            // Encode
            let data = try encoder.encode(value)

            // Write/Set Data
            self.sharedContainer?.set(data, forKey: key)

        } catch {
            print("Unable to Encode (\(error))")
        }
    }
    
    
    func get_settings(key: String) -> UserSettings?
    {
        if let data = self.sharedContainer?.data(forKey: key) {
            do {
                // Create JSON Decoder
                let decoder = JSONDecoder()

                // Decode Note
                let note = try decoder.decode(UserSettings.self, from: data)
                return note
            } catch {
                print("Unable to Decode Note (\(error))")
            }
        }
        return nil
    }

    func save_array(value: Array<StockObject>, key: String)
    {
        do {
            // Create JSON Encoder
            let encoder = JSONEncoder()

            // Encode
            let data = try encoder.encode(value)

            // Write/Set Data
            self.sharedContainer?.set(data, forKey: key)

        } catch {
            print("Unable to Encode (\(error))")
        }
    }
    
    func set_array(value: Array<RSU_item>, key: String)
    {
        do {
            // Create JSON Encoder
            let encoder = JSONEncoder()

            // Encode
            let data = try encoder.encode(value)

            // Write/Set Data
            self.sharedContainer?.set(data, forKey: key)

        } catch {
            print("Unable to Encode (\(error))")
        }
    }
    
    func get_array_StockObject(key: String) -> Array<StockObject>?
    {
        if let data = self.sharedContainer?.data(forKey: key) {
            do {
                // Create JSON Decoder
                let decoder = JSONDecoder()

                // Decode Note
                let note = try decoder.decode(Array<StockObject>.self, from: data)
                return note
            } catch {
                print("Unable to Decode Note (\(error))")
            }
        }
        return nil
    }
    
    func get_array(key: String) -> Array<RSU_item>?
    {
        if let data = self.sharedContainer?.data(forKey: key) {
            do {
                // Create JSON Decoder
                let decoder = JSONDecoder()

                // Decode Note
                let note = try decoder.decode(Array<RSU_item>.self, from: data)
                return note
            } catch {
                print("Unable to Decode Note (\(error))")
            }
        }
        return nil
    }
    
    func checkDatabaseMatch(name: String) -> Bool
    {
       guard let database = self.sharedContainer?.dictionary(forKey: "Stock_DB") as? [String:Double],
             let _ = database[name] else { return false }

        return true
    }
    
    func getFromDatabase(name: String) -> Double
    {
       guard let database = self.sharedContainer?.dictionary(forKey: "Stock_DB") as? [String:Double] else { return 0 }
        return database[name] ?? 0
    }
        
    func saveToDatabase(name: String, number: Double)
    {
       var newEntry : [String: Double]
       if let database = self.sharedContainer?.dictionary(forKey: "Stock_DB") as? [String:Double] {
          newEntry = database
       } else {
          newEntry = [:]
       }
       newEntry[name] = number

        self.sharedContainer?.set(newEntry, forKey: "Stock_DB")
    }
    
    func saveDateToDatabase(name: String, date: Date)
    {
       var newEntry : [String: Date]
       if let database = self.sharedContainer?.dictionary(forKey: "Database_Dates") as? [String:Date] {
          newEntry = database
       } else {
          newEntry = [:]
       }
       newEntry[name] = date

        self.sharedContainer?.set(newEntry, forKey: "Database_Dates")
    }
    
}

struct RateResult: Hashable, Codable {
    let rates: [String: Double]
    let base, date: String
}
    
