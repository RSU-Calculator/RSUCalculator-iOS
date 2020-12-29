//
//  ChartRow.swift
//  ChartView
//
//  Created by András Samu on 2019. 06. 12..
//  Copyright © 2019. András Samu. All rights reserved.
//

import SwiftUI

public struct BarChartRow : View {
    var data: [Double]
    var accentColor: Color
    var gradient: GradientColor?
    @State var last_touched : Int = 0
    @Binding var maxValue: Double?
    @Binding var touchLocation: CGFloat
    var maxHigh : Double {
        var max : Double?
        if maxValue != nil
        {
            max = maxValue!
        }
        else
        {
        max = data.max()
        }
        return max!
    }
    public var body: some View {
        GeometryReader { geometry in
            HStack(alignment: .bottom, spacing: (geometry.frame(in: .local).width-22)/CGFloat(self.data.count * 3)){
                ForEach(0..<self.data.count, id: \.self) { i in
                    if( self.data.count > 1 )
                    {
                    BarChartCell(value: self.normalizedValue(index: i),
                                 index: i,
                                 width: Float(geometry.frame(in: .local).width - 22),
                                 numberOfDataPoints: self.data.count,
                                 accentColor: self.accentColor,
                                 gradient: self.gradient,
                                 touchLocation: self.$touchLocation)

                        .scaleEffect(self.touchLocation > CGFloat(i)/CGFloat(self.data.count) && self.touchLocation < CGFloat(i+1)/CGFloat(self.data.count) ? scaleOnChange(index: i) : CGSize(width: 1, height: 1), anchor: .bottom)
                        .animation(.spring())
                        
                    }
                    else
                    {
                        BarChartCell(value: self.normalizedValue(index: i),
                                     index: i,
                                     width: Float(geometry.frame(in: .local).width - 22),
                                     numberOfDataPoints: self.data.count,
                                     accentColor: self.accentColor,
                                     gradient: self.gradient,
                                     touchLocation: self.$touchLocation)
                            .animation(.spring())
                    }
                }
            }
            .padding([.top, .leading, .trailing], 10)
        }
    }
    
    func normalizedValue(index: Int) -> Double {
        return Double(self.data[index])/Double(self.maxHigh)
    }
    
    func scaleOnChange(index: Int) -> CGSize
    {
        return CGSize(width: 1.4, height: 1.1)
    }
}

#if DEBUG
struct ChartRow_Previews : PreviewProvider {
    static var previews: some View {
        Group {
            BarChartRow(data: [0], accentColor: Colors.OrangeStart, maxValue: .constant(nil), touchLocation: .constant(-1))
            BarChartRow(data: [8,23,54,32,12,37,7], accentColor: Colors.OrangeStart, maxValue: .constant(nil), touchLocation: .constant(-1))
        }
    }
}
#endif
