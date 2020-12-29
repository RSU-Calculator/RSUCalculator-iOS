//
//  StockTest.swift
//  RSU Calc
//
//  Created by Dudu Twizer on 16/12/2020.
//

import SwiftUI
import Foundation
import AlphaVantage

struct StockObject: Codable, Hashable {
    var symbol : String?
    var name : String?
    var type : String?
    var region : String?
    var currency : String?
    var lastvalue : Double?
    
    init() {
        self.name = ""
        self.symbol = ""
        self.region = ""
        self.currency = ""
        self.type = ""
    }
    init(apiMatch: BestMatch)
    {
        self.symbol = apiMatch.the1Symbol
        self.name = apiMatch.the2Name
        self.type = apiMatch.the3Type
        self.region = apiMatch.the4Region
        self.currency = apiMatch.the8Currency
    }
}

struct StockSearchFromAPI: View {
    @State var searchText : String = ""
    let fetcher = Stock(
        apiKey: "QTPNYCUNJQ9IUTIQ",
        export: (path: URL(fileURLWithPath: "."), dataType: .json)
    )

    @Binding var selected : StockObject
    @State var search_results : Array<BestMatch> = []
    @State var last_value_at_api: String = ""
    @State var search_results_cache : [String :Array<BestMatch>] = [:]
    @State var needToSearch : Bool = false
    @State var timer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()
    
    @Environment(\.presentationMode) var presentationMode
    var body: some View {
        VStack
        {

        SearchBar(text: $searchText, placeholder: "Search for company stock")
            .onChange(of: searchText, perform: {newValue in textChanged()})
            .onReceive(timer) { _ in
                if(needToSearch)
                {
                    print("going to search")
                    search()
                    needToSearch = false
                    self.timer.upstream.connect().cancel()
                }
                else
                {
                    print("just timer without search")
                }
            }
            List
            {
            ForEach(search_results, id: \.self){
            item in
            HStack
            {
                Text("\(item.the2Name)")
                    .bold()
                    .frame(maxWidth: .infinity, alignment: .leading)
                VStack(alignment: .trailing)
                {
                Text("\(item.the1Symbol)")
                Text("\(item.the4Region)")
                }
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .padding(.horizontal)
            .padding(.top, 2)
            .contentShape(Rectangle())
            .onTapGesture {
                selectOne(name: item)
            }
            }
                if(needToSearch)
                {
                    HStack()
                    {
                        Spacer()
                        ActivityIndicator(isAnimating: .constant(true), style: .large)
                        Spacer()
                    }
                }
            }
        
    }
    }
    
    func textChanged() {
        if(!needToSearch)
        {
            needToSearch = true
            timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
        }
    }
    func search()
    {
        var searchtext_sent_to_api = "Nothing"
        let set = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLKMNOPQRSTUVWXYZ")

        if searchText.count < 3 || searchText.count > 10 {
            search_results = []
            return
        }
        
        searchtext_sent_to_api = String(searchText.filter { !" \n\t\r".contains($0) })
//        searchtext_sent_to_api = String(searchtext_sent_to_api.split(separator: " ")[0])

        if(searchtext_sent_to_api.rangeOfCharacter(from: set.inverted) != nil)
        {
            print("error with the string")
            return
        }

        if(searchtext_sent_to_api == "Nothing")
        {
            return
        }
//        else if(searchtext_sent_to_api == last_value_at_api)
//        {
//            return
//        }
        else
        {
            last_value_at_api = searchtext_sent_to_api
        }
        if(self.search_results_cache.keys.contains(searchtext_sent_to_api))
        {
            if (search_results_cache[searchtext_sent_to_api]!.capacity > 0)
            {
                search_results = search_results_cache[searchtext_sent_to_api]!
                return
            }
        }
        // dealing with substring that already included
        var temp_results : Array<BestMatch> = []
        for key in self.search_results_cache.keys {
            if(searchtext_sent_to_api.contains(key))
            {
                for result in search_results_cache[key] ?? [] {
                    if(result.the1Symbol.uppercased().contains(searchtext_sent_to_api.uppercased()))
                    {
                        print("decided that symobol \(result.the1Symbol) contains \(searchtext_sent_to_api.uppercased())")
                        temp_results.append(result)
                    }
                    else if(result.the2Name.uppercased().contains(searchtext_sent_to_api.uppercased()))
                    {
                        print("decided that name \(result.the2Name) contains \(searchtext_sent_to_api.uppercased())")
                        temp_results.append(result)
                    }
                }
                if (temp_results.count > 0)
                {
                    search_results = temp_results
                    search_results_cache.updateValue(search_results, forKey: String(searchtext_sent_to_api))
                    return
                }
            }
            else
            {
                print("key \(key) not have \(searchtext_sent_to_api.dropLast()) (original) : \(searchtext_sent_to_api)")
            }
        }
        fetcher.fuzzyQuery(keyword: searchtext_sent_to_api) { result, err in
            if let err = err {
                guard err is ApiResponse.ApiError else {
                    print (err.localizedDescription)
                    return
                }
            }
            if let result = result
            {
                search_results = result.bestMatches
                search_results.sort(by: {$0.the9MatchScore > $1.the9MatchScore})
                search_results_cache.updateValue(search_results, forKey: searchtext_sent_to_api)
            }
        }
    }
    
    func selectOne(name: BestMatch) {
        self.selected = StockObject(apiMatch: name)
        self.presentationMode.wrappedValue.dismiss()
    }
}

struct StockTest_Previews: PreviewProvider {
    static var user_data = current_user_data()
    static var previews: some View {
        StockSearchFromAPI(selected: .constant(StockObject()))
            .environmentObject(user_data)
    }
}

struct SearchBar: UIViewRepresentable {

    @Binding var text: String
    var placeholder: String

    class Coordinator: NSObject, UISearchBarDelegate {

        @Binding var text: String

        init(text: Binding<String>) {
            _text = text
        }

        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            text = searchText
        }
    }

    func makeCoordinator() -> SearchBar.Coordinator {
        return Coordinator(text: $text)
    }

    func makeUIView(context: UIViewRepresentableContext<SearchBar>) -> UISearchBar {
        let searchBar = UISearchBar(frame: .zero)
        searchBar.delegate = context.coordinator
        searchBar.placeholder = placeholder
        searchBar.searchBarStyle = .minimal
        searchBar.autocapitalizationType = .none
        return searchBar
    }

    func updateUIView(_ uiView: UISearchBar, context: UIViewRepresentableContext<SearchBar>) {
        uiView.text = text
    }
}
