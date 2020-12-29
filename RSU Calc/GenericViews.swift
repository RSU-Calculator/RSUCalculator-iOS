//
//  GenericViews.swift
//  RSU Calc
//
//  Created by Dudu Twizer on 02/12/2020.
//

import SwiftUI

struct GenericViews: View {
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

struct GenericViews_Previews: PreviewProvider {
    static var previews: some View {
        Background()
    }
}

struct Background: View {
    @Environment(\.colorScheme) var colorScheme
    var body: some View {
        if(colorScheme == .dark)
        {
            let background = LinearGradient(gradient: Gradient(
            colors:
            [
            .init(UIColor(red: 0.15, green: 0.15, blue: 0.20, alpha: 1.00)),
            .init(UIColor(red: 0.11, green: 0.14, blue: 0.17, alpha: 1.00))
            ]),
                       startPoint: .topLeading, endPoint: .bottomTrailing)
            .edgesIgnoringSafeArea(.all)
            return background
        }
        else
        {
            let background = LinearGradient(gradient: Gradient(
               colors:
               [
               .init(UIColor(red: 0.93, green: 0.94, blue: 0.95, alpha: 1.00)),
               .init(UIColor(red: 0.94, green: 0.94, blue: 0.95, alpha: 1.00))
               ]),
                          startPoint: .topLeading, endPoint: .bottomTrailing)
               .edgesIgnoringSafeArea(.all)
            return background
        }
    }
}

struct CardGroupBoxStyle: GroupBoxStyle {
    @Environment(\.colorScheme) var colorScheme
    func makeBody(configuration: Configuration) -> some View {
        VStack(alignment: .leading) {
            configuration.label
            configuration.content
        }
        .padding()
        .background(LinearGradient(gradient: Gradient(
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
                                    .edgesIgnoringSafeArea(.all))
        .clipShape(RoundedRectangle(cornerRadius: 25, style: .continuous))
        .shadow(color: self.colorScheme == .dark ? Color.darkStart.opacity(0.3) : Color.black.opacity(0.2), radius: self.colorScheme == .dark ? 10 : 10, x: self.colorScheme == .dark ? -10 : -5, y: self.colorScheme == .dark ? -10 : -5)
        .shadow(color: self.colorScheme == .dark ? Color.darkEnd : Color.white.opacity(0.7), radius: self.colorScheme == .dark ? 10 : 10, x: self.colorScheme == .dark ? 10 : 10, y: self.colorScheme == .dark ? 10 : 10)
    }
}

struct floatingBtnGradient: View {
    @Environment(\.colorScheme) var colorScheme
    @State var width: CGFloat? = 350
    @State var height: CGFloat? = 55
    @Binding var ison: Bool
    var body: some View {
        if(!ison)
        {
            let result = LinearGradient(gradient: Gradient(
            colors:
            [
            .init(
                colorScheme == .light ?
                UIColor(red: 0.00, green: 0.76, blue: 0.85, alpha: 1.00):
                UIColor(red: 0.23, green: 0.60, blue: 0.67, alpha: 1.00)
                ),
            .init(
                colorScheme == .light ?
                UIColor(red: 0.00, green: 0.50, blue: 0.79, alpha: 1.00):
                UIColor(red: 0.35, green: 0.57, blue: 0.61, alpha: 1.00)
                )
            ]),
            startPoint: .topLeading, endPoint: .bottomTrailing)
            .frame(width: self.width, height: self.height)
            .shadow(color: Color.black.opacity(0.2),radius: 3, x: 0, y:3)
            return result
        }
        else
        {
            let result = LinearGradient(gradient: Gradient(
            colors:
            [
            .init(
                colorScheme == .light ?
                    UIColor(red: 0.56, green: 0.60, blue: 0.61, alpha: 1.00):
                    UIColor(red: 0.19, green: 0.23, blue: 0.27, alpha: 1.00)
                ),
            .init(
                colorScheme == .light ?
                    UIColor(red: 0.57, green: 0.60, blue: 0.61, alpha: 1.00):
                    UIColor(red: 0.16, green: 0.29, blue: 0.31, alpha: 1.00)
                )
            ]),
            startPoint: .topLeading, endPoint: .bottomTrailing)
            .frame(width: self.width, height: self.height)
            .shadow(color: Color.black.opacity(0.2),radius: 3, x: 0, y:3)
            return result
        }
    }
}

struct CardGroupBoxStyle_clear: GroupBoxStyle {
    @Environment(\.colorScheme) var colorScheme
    func makeBody(configuration: Configuration) -> some View {
        VStack(alignment: .leading) {
            configuration.label
            configuration.content
        }
        .padding()
        .background(Color(
            self.colorScheme == .light ?
            UIColor(red: 0.93, green: 0.94, blue: 0.95, alpha: 1.00) :
            UIColor(red: 0.14, green: 0.16, blue: 0.18, alpha: 1.00)
        ))
        .edgesIgnoringSafeArea(.all)
        .clipShape(RoundedRectangle(cornerRadius: 25, style: .continuous))
        .shadow(color: self.colorScheme == .dark ? Color.darkStart : Color.black.opacity(0.2), radius: self.colorScheme == .dark ? 10 : 10, x: self.colorScheme == .dark ? -10 : -5, y: self.colorScheme == .dark ? -10 : -5)
                            .shadow(color: self.colorScheme == .dark ? Color.darkEnd : Color.white.opacity(0.7), radius: self.colorScheme == .dark ? 10 : 10, x: self.colorScheme == .dark ? 10 : 10, y: self.colorScheme == .dark ? 10 : 10)
    }
}

extension Color
{
    static let darkStart = Color(red: 50 / 255, green: 60 / 255, blue: 65 / 255)
    static let darkEnd = Color(red: 25 / 255, green: 25 / 255, blue: 30 / 255)
}
