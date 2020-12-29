//
//  RSU_CalcApp.swift
//  RSU Calc
//
//  Created by Dudu Twizer on 29/11/2020.
//

import SwiftUI

@main
struct RSU_CalcApp: App {
    var user_data = current_user_data()
    @State var currencyFormatter: NumberFormatter = NumberFormatter()
    @State var showing_ADD_RSU_Sheet = false
    var body: some Scene {
        WindowGroup {
            TabView
            {
                Main(showing_ADD_RSU_Sheet: $showing_ADD_RSU_Sheet, currencyFormatter: $currencyFormatter)
                .environmentObject(user_data)
                .tabItem {
                    Image(systemName: "1.square")
                    Text("Dashboard")
                    }
                Summary_Portfolio_Stack(currencyFormatter: $currencyFormatter, showing_ADD_RSU_Sheet: $showing_ADD_RSU_Sheet)
                .environmentObject(user_data)
                .tabItem {
                    Image(systemName: "2.square")
                    Text("Portfolio")
                    }
                TimeLine(currencyFormatter: $currencyFormatter)
                .environmentObject(user_data)
                .tabItem {
                    Image(systemName: "3.square")
                    Text("Timeline")
                    }
                Settings(currencyFormatter: $currencyFormatter)
                .environmentObject(user_data)
                .tabItem {
                    Image(systemName: "4.square")
                    Text("Setting")
                    }
            }
        }
    }
}
