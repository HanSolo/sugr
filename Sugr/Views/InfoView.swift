//
//  InfoView.swift
//  Sugr
//
//  Created by Gerrit Grunwald on 27.12.24.
//

import SwiftUI
import CoreGraphics


struct InfoView: View {
    @Environment(\.colorScheme)  var colorScheme
    @EnvironmentObject           var model : SugrModel
    
    private let dateFormatter : DateFormatter = DateFormatter()
    
    
    var body: some View {
        GeometryReader { geometry in
            Canvas(opaque: false, colorMode: .linear, rendersAsynchronously: false) { ctx, size in
                //let darkMode         : Bool            = self.colorScheme == .dark
                //let isLandscape      : Bool            = UIDevice.current.orientation.isLandscape
                let width            : Double          = size.width
                let height           : Double          = size.height
                let minSize          : Double          = min(width, height)
                let center           : CGPoint         = CGPoint(x: width * 0.5, y: height * 0.175)
                let unitMgDl         : Bool            = Properties.instance.unitMgDl!
                
                let currentValue     : Double          = self.model.value
                let currentDate      : Date            = Date(timeIntervalSince1970: self.model.date)
                let currentDirection : String          = Helper.directionToArrow(direction: self.model.currentEntry?.direction ?? "")
                let secondsDelta     : Double          = Date.now.timeIntervalSince1970 - currentDate.timeIntervalSince1970
                let timeSinceLast    : String          = Helper.secondsToDDHHMMString(seconds: secondsDelta)
                                    
                let outdated         : Bool            = secondsDelta > Constants.OUTDATED_DURATION
                let foregroundFill   : Color           = .white
                let valueFontSize    : Double          = minSize * 0.485
                let valueFont        : Font            = Font.system(size: valueFontSize, weight: .bold, design: .rounded)
                let unitFontSize     : Double          = width * 0.06
                let unitFont         : Font            = Font.system(size: unitFontSize, weight: .regular, design: .rounded)
                let arrowFontSize    : Double          = minSize * 0.3
                let arrowFont        : Font            = Font.system(size: arrowFontSize, weight: .bold, design: .rounded)
                let spacer           : Double          = minSize * 0.025
                let datetimeFontSize : Double          = minSize * 0.075
                let datetimeFont     : Font            = Font.system(size: datetimeFontSize, weight: .regular, design: .rounded)
                let infoFontSize     : Double          = minSize * 0.065
                let infoFont         : Font            = Font.system(size: infoFontSize, weight: .medium, design: .rounded)
                //let offlineFontSize  : Double          = minSize * 0.05
                //let offlineFont      : Font            = Font.system(size: offlineFontSize, weight: .regular, design: .rounded)
                                                       
                var valueRect : Path = Path()
                valueRect.addRect(CGRect(x: 0, y: 0, width: width, height: height))
                ctx.fill(valueRect, with: Helper.getGCColorForValue(value: currentValue))
                
                let value     : Double = unitMgDl ? currentValue : Helper.mgToMmol(mgPerDl: currentValue)
                let valueText : Text   = Text(verbatim: "\(String(format: unitMgDl ? "%.0f" : "%.1f", value))").foregroundStyle(foregroundFill).font(valueFont)
                ctx.draw(valueText, at: CGPoint(x: center.x + width * 0.125, y: height * 0.32), anchor: .trailing)
                
                let unitText : Text = Text(verbatim: unitMgDl ? "mg/dl" : "mmol/L").foregroundStyle(foregroundFill).font(unitFont)
                ctx.draw(unitText, at: CGPoint(x: center.x + spacer + width * 0.16, y: height * 0.465), anchor: .leading)
                
                let arrowText : Text = Text(verbatim: currentDirection).foregroundStyle(foregroundFill).font(arrowFont)
                ctx.draw(arrowText, at: CGPoint(x: center.x + spacer + width * 0.125, y: height * 0.26), anchor: .leading)
                                                
                dateFormatter.dateFormat = unitMgDl ? Constants.DF_MG_DL : Constants.DF_MMOL_L
                let dateTimeValue : String = dateFormatter.string(from: currentDate)
                let dateTimeText : Text = Text(verbatim: "\(dateTimeValue) (\(timeSinceLast))").foregroundStyle(foregroundFill).font(datetimeFont)
                ctx.draw(dateTimeText, at: CGPoint(x: center.x, y: height * 0.625), anchor: .center)
                                                
                if self.model.hba1c > 0 {
                    let avgValue : String = unitMgDl ? String(format: "%.0f", self.model.averageToday) : String(format: "%.1f", Helper.mgToMmol(mgPerDl: self.model.averageToday))
                    let avgText : Text = Text(verbatim: "ø \(avgValue)").foregroundStyle(foregroundFill).font(infoFont)
                    ctx.draw(avgText, at: CGPoint(x: 20, y: height * 0.775), anchor: .leading)
                
                    let todayText : Text = Text(verbatim: "\u{21E6}  Today  \u{21E8}").foregroundStyle(foregroundFill).font(infoFont)
                    ctx.draw(todayText, at: CGPoint(x: center.x, y: height * 0.775), anchor: .center)
                    
                    let inRangeTodayValue : String = String(format: "%.0f", self.model.inRangeToday)
                    let inRangeTodayText  : Text   = Text(verbatim: "in range \(inRangeTodayValue)%").foregroundStyle(foregroundFill).font(infoFont)
                    ctx.draw(inRangeTodayText, at: CGPoint(x: width - 20, y: height * 0.775), anchor: .trailing)
                    
                    let hba1cText : Text = Text(verbatim: "HbA1c \(String(format: "%.1f%%", self.model.hba1c))").foregroundStyle(foregroundFill).font(infoFont)
                    ctx.draw(hba1cText, at: CGPoint(x: 20, y: height * 0.9), anchor: .leading)
                    
                    let last30DaysText : Text = Text(verbatim: "\u{21E6}  30 days  \u{21E8}").foregroundStyle(foregroundFill).font(infoFont)
                    ctx.draw(last30DaysText, at: CGPoint(x: center.x, y: height * 0.9), anchor: .center)
                    
                    let timeInRangeLast30DaysValue : String = String(format: "%.0f", self.model.inRangeLast30Days)
                    let timeInRangeLast30DaysText  : Text   = Text(verbatim: "in range \(timeInRangeLast30DaysValue)%").foregroundStyle(foregroundFill).font(infoFont)
                    ctx.draw(timeInRangeLast30DaysText, at: CGPoint(x: width - 20, y: height * 0.9), anchor: .trailing)
                }
                
                if outdated {
                    if let attentionSymbol = ctx.resolveSymbol(id: 1) {
                        ctx.draw(attentionSymbol, at: CGPoint(x: width - 20, y: 20), anchor: .center)
                    }
                }
                /*
                if !self.model.networkMonitor.isConnectedToInternet {
                    var offlineRect : Path = Path()
                    offlineRect.addRoundedRect(in: CGRect(x: 10, y: 10, width: 60, height: 18), cornerRadii: RectangleCornerRadii(topLeading: 2.5, bottomLeading: 2.5, bottomTrailing: 2.5, topTrailing: 2.5))
                    ctx.stroke(offlineRect, with: Constants.GC_WHITE, lineWidth: 1)
                    let offlineText : Text = Text(verbatim: "OFFLINE").foregroundStyle(foregroundFill).font(offlineFont)
                    ctx.draw(offlineText, at: CGPoint(x: 10 + 30, y: 10 + 9), anchor: .center)
                }
                */
            } symbols: {
                Image(systemName: "exclamationmark.triangle.fill")
                    .resizable()
                    .frame(width: 24, height: 24)
                    .foregroundColor(.white)
                    .symbolEffect(.pulse.wholeSymbol, options: .repeat(.continuous))
                    .tag(1)
            }
        }
    }
}
