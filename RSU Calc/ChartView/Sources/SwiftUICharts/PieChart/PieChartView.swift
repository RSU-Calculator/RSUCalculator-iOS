//
//  PieChartView.swift
//  ChartView
//
//  Created by András Samu on 2019. 06. 12..
//  Copyright © 2019. András Samu. All rights reserved.
//

import SwiftUI

public struct PieChartView : View {
    public var data: [Double]
    public var title: String
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    public var legend: String?
    public var style: ChartStyle
    public var darkModeStyle: ChartStyle
    public var formSize:CGSize
    public var dropShadow: Bool
    public var valueSpecifier:String
    public var titleValue : Double
    public var currencyFormatter: NumberFormatter
    @State private var showValue = false
    @State private var currentValue: Double = 0 {
        didSet{
            if(oldValue != self.currentValue && self.showValue) {
                HapticFeedback.playSelection()
            }
        }
    }
    
    public init(data: [Double], title: String, titleValue: Double, legend: String? = nil, style: ChartStyle = Styles.pieChartStyleOne, form: CGSize? = ChartForm.medium, dropShadow: Bool? = true, valueSpecifier: String? = "%.1f", currencyFormatter: NumberFormatter){
        self.data = data
        self.title = title
        self.titleValue = titleValue
        self.legend = legend
        self.style = style
        self.darkModeStyle = style.darkModeStyle != nil ? style.darkModeStyle! : Styles.lineViewDarkMode
        self.formSize = form!
        if self.formSize == ChartForm.large {
            self.formSize = ChartForm.extraLarge
        }
        self.dropShadow = dropShadow!
        self.valueSpecifier = valueSpecifier!
        self.currencyFormatter = currencyFormatter
    }
    
    public var body: some View {
        ZStack{
            Rectangle()
                .fill(self.colorScheme == .dark ? self.darkModeStyle.backgroundColor : self.style.backgroundColor)
                .cornerRadius(20)
                .shadow(color: self.style.dropShadowColor, radius: self.dropShadow ? 12 : 0)
            VStack(alignment: .center){
                HStack{
                    if(!showValue){
                        VStack
                        {
                        Text(self.title)
                            .font(.caption)
                            .foregroundColor(self.colorScheme == .dark ? self.darkModeStyle.textColor : self.style.textColor)
                        Text((currencyFormatter.string(from: NSNumber(value: self.titleValue))!))
                            .font(.headline)
                            .foregroundColor(self.colorScheme == .dark ? self.darkModeStyle.textColor : self.style.textColor)
                        }
                    }else{
                        Text("\(currencyFormatter.string(from: NSNumber(value: self.currentValue))!)")
                            .font(.headline)
                            .foregroundColor(self.colorScheme == .dark ? self.darkModeStyle.textColor : self.style.textColor)
                    }
                }.padding()
                PieChartRow(data: data, backgroundColor: self.style.backgroundColor, accentColor: self.style.accentColor, showValue: $showValue, currentValue: $currentValue)
                    .foregroundColor(self.style.accentColor).padding(self.legend != nil ? 0 : 12).offset(y:self.legend != nil ? 0 : -10)
                if(self.legend != nil) {
                    HStack
                    {
                        Spacer()
                        Circle().fill(Colors.BorderBlue)
                            .frame(width: 10, height: 10, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                        Text("Available")
                            .font(.caption)
                            .foregroundColor(self.colorScheme == .dark ? self.darkModeStyle.textColor : self.style.textColor)
                        Spacer()
                        Circle().fill(Colors.GradinetUpperBlue1)
                            .frame(width: 10, height: 10, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                        Text("Unavailable")
                            .font(.caption)
                            .foregroundColor(self.colorScheme == .dark ? self.darkModeStyle.textColor : self.style.textColor)
                        Spacer()
                    }
                    .padding()
                }
                
            }
        }.frame(width: self.formSize.width, height: self.formSize.height)
    }
}

#if DEBUG
struct PieChartView_Previews : PreviewProvider {
    static var previews: some View {
        PieChartView(data:[56,78,53,65,54], title: "Title", titleValue: 1.0, legend: "Legend", currencyFormatter: NumberFormatter())
    }
}
#endif
