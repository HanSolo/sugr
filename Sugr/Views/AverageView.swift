//
//  AverageView.swift
//  Sugr
//
//  Created by Gerrit Grunwald on 31.12.24.
//

import SwiftUI
import CoreGraphics


struct AverageView: View {
    @Environment(\.colorScheme)  var colorScheme
    @EnvironmentObject           var model : SugrModel
    
    private let dateFormatter : DateFormatter = DateFormatter()
    
    
    var body: some View {
        GeometryReader { geometry in
            Canvas(opaque: false, colorMode: .linear, rendersAsynchronously: false) { ctx, size in
                let darkMode           : Bool     = self.colorScheme == .dark
                let width              : Double   = size.width
                //let height             : Double   = size.height
                let dayOfWeekFontSize  : Double   = width * 0.02
                let dayOfWeekFont      : Font     = Font.system(size: dayOfWeekFontSize, weight: .regular, design: .rounded)
                let dayOfMonthFontSize : Double   = width * 0.02
                let dayOfMonthFont     : Font     = Font.system(size: dayOfMonthFontSize, weight: .regular, design: .rounded)
                let boxSize            : Double   = width * 0.0223880597
                let offsetX            : Double   = width * 0.0199004975
                let offsetY            : Double   = dayOfWeekFontSize * 1.25
                let spacer             : Double   = width * 0.0099502488
                let calendar           : Calendar = Calendar.current
                                
                if !self.model.averagesLast30Days.isEmpty {
                    for n in 0..<30 {
                        let day        : Date   = Date.now - (TimeInterval(n) * Constants.SECONDS_PER_DAY)
                        let startOfDay : Date   = calendar.startOfDay(for: day)
                        let dayOfWeek    : String = Constants.WEEKDAYS[calendar.component(.weekday, from: startOfDay) - 1]
                        let dayOfMonth : Int    = calendar.component(.day, from: startOfDay)
                        
                        let dayOfWeekText : Text = Text(verbatim: "\(dayOfWeek)").foregroundStyle(.primary).font(dayOfWeekFont)
                        ctx.draw(dayOfWeekText, at: CGPoint(x: offsetX + boxSize * 0.5 + (boxSize + spacer) * Double(29 - n), y: dayOfWeekFontSize * 0.5))
                        
                        if (self.model.averagesLast30Days.count > n) {
                            var box : Path = Path()
                            box.addRect(CGRect(x: offsetX + (boxSize + spacer) * Double(29 - n), y: offsetY, width: boxSize, height: boxSize))
                            ctx.fill(box, with: Helper.getGCColorForValue(value: self.model.averagesLast30Days[n]))
                            ctx.stroke(box, with: darkMode ? Constants.GC_WHITE : Constants.GC_GRAY, lineWidth: 0.5)
                        }
                        
                        let dayOfMonthText : Text = Text(verbatim: "\(dayOfMonth)").foregroundStyle(.primary).font(dayOfMonthFont)
                        ctx.draw(dayOfMonthText, at: CGPoint(x: offsetX + boxSize * 0.5 + (boxSize + spacer) * Double(29 - n), y: offsetY + boxSize + dayOfMonthFontSize))
                    }
                }
            }
        }
    }
}
