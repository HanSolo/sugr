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
                let darkMode         : Bool            = self.colorScheme == .dark
                let isLandscape      : Bool            = UIDevice.current.orientation.isLandscape
                let width            : Double          = size.width
                let height           : Double          = size.height
                let minSize          : Double          = (width < height ? width : height)
                let center           : CGPoint         = isLandscape ? CGPoint(x: width * 0.175, y: height * 0.5) : CGPoint(x: width * 0.5, y: height * 0.175)
                let unitMgDl         : Bool            = Properties.instance.unitMgDl!
                
                let currentValue     : Double          = self.model.value
                let currentDate      : Date            = Date(timeIntervalSince1970: self.model.date)
                let currentDirection : String          = Helper.directionToArrow(direction: self.model.currentEntry?.direction ?? "")
                let secondsDelta     : Double          = Date.now.timeIntervalSince1970 - currentDate.timeIntervalSince1970
                let timeSinceLast    : String          = Helper.secondsToDDHHMMString(seconds: secondsDelta)
                                    
                let outdated         : Bool            = secondsDelta > Constants.OUTDATED_DURATION
                let foregroundFill   : Color           = .primary
                let valueFontSize    : Double          = minSize * 0.485
                let valueFont        : Font            = Font.system(size: valueFontSize, weight: .bold, design: .rounded)
                let unitFontSize     : Double          = isLandscape ? minSize * 0.04 : minSize * 0.06
                let unitFont         : Font            = Font.system(size: unitFontSize, weight: .regular, design: .rounded)
                let arrowFontSize    : Double          = minSize * 0.34
                let arrowFont        : Font            = Font.system(size: arrowFontSize, weight: .bold, design: .rounded)
                let spacer           : Double          = width * 0.025
                let datetimeFontSize : Double          = minSize * 0.085
                let datetimeFont     : Font            = Font.system(size: datetimeFontSize, weight: .regular, design: .rounded)
                let infoFontSize     : Double          = minSize * 0.075
                let infoFont         : Font            = Font.system(size: infoFontSize, weight: .regular, design: .rounded)
                                                
                var valueRect : Path = Path()
                valueRect.addRect(CGRect(x: 0, y: 0, width: width, height: height))
                ctx.fill(valueRect, with: Helper.getGCColorForValue(value: currentValue))
                
                let value     : Double = unitMgDl ? currentValue : Helper.mgToMmol(mgPerDl: currentValue)
                let valueText : Text   = Text(verbatim: "\(String(format: unitMgDl ? "%.0f" : "%.1f", value))").foregroundStyle(foregroundFill).font(valueFont)
                ctx.draw(valueText, at: CGPoint(x: center.x + width * 0.175, y: height * 0.38), anchor: .trailing)
                
                let unitText : Text = Text(verbatim: unitMgDl ? "mg/dl" : "mmol/L").foregroundStyle(foregroundFill).font(unitFont)
                ctx.draw(unitText, at: CGPoint(x: center.x + spacer + width * 0.225, y: height * 0.525), anchor: .leading)
                
                let arrowText : Text = Text(verbatim: currentDirection).foregroundStyle(foregroundFill).font(arrowFont)
                ctx.draw(arrowText, at: CGPoint(x: center.x + spacer + width * 0.175, y: height * 0.32), anchor: .leading)
                
                dateFormatter.dateFormat = unitMgDl ? Constants.DF_MG_DL : Constants.DF_MMOL_L
                let dateText : Text = Text(verbatim: dateFormatter.string(from: currentDate)).foregroundStyle(foregroundFill).font(datetimeFont)
                ctx.draw(dateText, at: CGPoint(x: 20, y: height * 0.75), anchor: .leading)
                
                dateFormatter.dateFormat = unitMgDl ? Constants.TF_MG_DL : Constants.TF_MMOL_L
                let timeText : Text = Text(verbatim: dateFormatter.string(from: currentDate)).foregroundStyle(foregroundFill).font(datetimeFont)
                ctx.draw(timeText, at: CGPoint(x: width - 20, y: height * 0.75), anchor: .trailing)
                
                if self.model.hba1c > 0 {
                    let hba1cText : Text = Text(verbatim: "HbA1c \(String(format: "%.1f%%", self.model.hba1c))").foregroundStyle(foregroundFill).font(infoFont)
                    ctx.draw(hba1cText, at: CGPoint(x: 20, y: height * 0.9), anchor: .leading)
                }
                
                let agoText : Text = Text(verbatim: timeSinceLast).foregroundStyle(foregroundFill).font(infoFont)
                ctx.draw(agoText, at: CGPoint(x: width - 20, y: height * 0.9), anchor: .trailing)
                
                if outdated {
                    let attentionImg : Image = Image(systemName: "exclamationmark.triangle.fill")
                    ctx.draw(attentionImg, at: CGPoint(x: center.x, y: height * 0.9), anchor: .center)
                }
            }
        }
    }
}
