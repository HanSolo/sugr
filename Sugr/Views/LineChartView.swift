//
//  LineChartView.swift
//  Sugr
//
//  Created by Gerrit Grunwald on 28.12.24.
//

import SwiftUI
import CoreGraphics


struct LineChartView: View {
    @Environment(\.colorScheme)  var colorScheme
    @EnvironmentObject           var model : SugrModel
    
    
    private let dateFormatter : DateFormatter = DateFormatter()
    private let calendar      : Calendar      = Calendar.current
    
    
    var body: some View {
        GeometryReader { geometry in
            Canvas(opaque: false, colorMode: .linear, rendersAsynchronously: false) { ctx, size in
                let darkMode       : Bool   = self.colorScheme == .dark
                let width          : Double = size.width
                let height         : Double = size.height
                let unitMgDl       : Bool   = Properties.instance.unitMgDl!
                let chartOffset    : Double = 10
                let chartWidth     : Double = width - (2 * chartOffset)
                let chartHeight    : Double = height - (2 * chartOffset)
                let fgdColor       : Color  = .primary
                let scaleXFontSize : Double = height * 0.032
                let scaleXFont     : Font   = Font.system(size: scaleXFontSize, weight: .regular, design: .rounded)
                let valueFontSize  : Double = height * 0.03
                let valueFont      : Font   = Font.system(size: valueFontSize, weight: .regular, design: .rounded)
                
                // Set dateformatter to short format for the xAxis tickmarks
                dateFormatter.dateFormat = unitMgDl ? Constants.TF_MG_DL_SHORT : Constants.TF_MMOL_L_SHORT
                
                if !self.model.last288Entries.isEmpty {
                    let now          : Double = Date.now.timeIntervalSince1970
                    let visibleRange : Double = 86400 // Visible range in seconds (86400 -> 24h)
                    let minDate      : Double = now - visibleRange
                    let maxDate      : Double = now
                    let scaleX       : Double = chartWidth / (maxDate - minDate)
                    let tickStepX    : Double = chartWidth / 288
                    let topY         : Double = chartOffset + scaleXFontSize * 2
                    let bottomY      : Double = chartOffset + chartHeight - scaleXFontSize * 2
                    let deltaY       : Double = bottomY - topY
                    let scaleY       : Double = deltaY / Constants.DEFAULT_MAX_VALUE_MG_DL
                    let dotRadius    : Double = 0.011981402 * chartHeight
                    let nightStart   : Double = Properties.instance.nightBeginOffset!
                    let nightEnd     : Double = Properties.instance.nightEndOffset!
                    
                    
                    // Nights
                    /*
                    if darkMode {
                        var bkgRect : Path = Path()
                        bkgRect.addRect(CGRect(x: chartOffset, y: topY, width: chartWidth, height: bottomY - topY))
                        ctx.fill(bkgRect, with: Constants.GC_DARK_GRAY.darkened(by: 0.5))
                    }
                    */
                    
                    var midnights : Set<Double> = Set()
                    let firstMidnight : Double = calendar.startOfDay(for: Date(timeIntervalSince1970: minDate)).timeIntervalSince1970
                    midnights.insert(firstMidnight)
                    midnights.insert(firstMidnight + Constants.SECONDS_PER_DAY)
                    midnights.insert(firstMidnight + Constants.SECONDS_PER_DAY * 2)                    
                    
                    for midnight in midnights {
                        let nightRectX : Double = chartOffset + (midnight - nightStart - minDate) * scaleX
                        let nightRectW : Double = (nightStart + nightEnd) * scaleX
                        var night : Path = Path()
                        night.addRect(CGRect(x: nightRectX, y: topY, width: nightRectW, height: bottomY - topY))
                        ctx.fill(night, with: darkMode ? Constants.GC_NIGHT_DARK : Constants.GC_NIGHT_BRIGHT)
                    }
                    
                    // Draw the top xAxis
                    var topXAxis : Path = Path()
                    topXAxis.move(to: CGPoint(x: chartOffset, y: topY))
                    topXAxis.addLine(to: CGPoint(x: chartOffset + chartWidth, y: topY))
                    ctx.stroke(topXAxis, with: darkMode ? Constants.GC_WHITE : Constants.GC_GRAY)
                    
                    // Draw the bottom xAxis
                    var bottomXAxis : Path = Path()
                    bottomXAxis.move(to: CGPoint(x: chartOffset, y: bottomY))
                    bottomXAxis.addLine(to: CGPoint(x: chartOffset + chartWidth, y: bottomY))
                    ctx.stroke(bottomXAxis, with: darkMode ? Constants.GC_WHITE : Constants.GC_GRAY)
                    
                    var toggle : Bool = false
                                                            
                    // Draw the tickmarks and labels
                    for n in 0..<289 {
                        let x          : Double = chartOffset + Double(n) * tickStepX
                        var topTick    : Path   = Path()
                        topTick.move(to: CGPoint(x: x, y: chartOffset + scaleXFontSize * 1.4))
                        topTick.addLine(to: CGPoint(x: x, y: topY))
                        ctx.stroke(topTick, with: Constants.GC_GRAY, lineWidth: 1)
                        
                        var vLine : Path = Path()
                        vLine.move(to: CGPoint(x: x, y: topY))
                        vLine.addLine(to: CGPoint(x: x, y: chartOffset + chartHeight - scaleXFontSize * 2))
                        ctx.stroke(vLine, with: Constants.GC_GRAY, lineWidth: 0.5)
                        
                        var bottomTick : Path   = Path()
                        bottomTick.move(to: CGPoint(x: x, y: bottomY))
                        bottomTick.addLine(to: CGPoint(x: x, y: chartOffset + chartHeight - scaleXFontSize * 1.4))
                        ctx.stroke(bottomTick, with: Constants.GC_GRAY, lineWidth: 1)
                        
                        if toggle {
                            let topTickText : Text = Text(verbatim: dateFormatter.string(from: Date(timeIntervalSince1970: minDate + Double(n * 300)))).foregroundStyle(fgdColor).font(scaleXFont)
                            ctx.draw(topTickText, at: CGPoint(x: x, y: chartOffset + scaleXFontSize * 0.4), anchor: .center)
                            
                            let bottomTickText : Text = Text(verbatim: dateFormatter.string(from: Date(timeIntervalSince1970: minDate + Double(n * 300)))).foregroundStyle(fgdColor).font(scaleXFont)
                            ctx.draw(bottomTickText, at: CGPoint(x: x, y: chartOffset + chartHeight - scaleXFontSize * 0.4), anchor: .center)
                        }
                        toggle.toggle()
                    }
                    
                    // Draw the ideal area
                    let greenAreaHeight : Double = (Properties.instance.maxNormal! - Properties.instance.minNormal!) * scaleY
                    var greenArea : Path = Path()
                    greenArea.addRect(CGRect(x: chartOffset, y: bottomY - Properties.instance.maxNormal! * scaleY, width: chartWidth, height: greenAreaHeight))
                    ctx.fill(greenArea, with: Constants.GC_GREEN_AREA_COLOR)
                    
                    // Draw a line for the max acceptable value
                    var maxAcceptableLine : Path = Path()
                    maxAcceptableLine.move(to: CGPoint(x: chartOffset, y: bottomY - Properties.instance.maxAcceptable! * scaleY))
                    maxAcceptableLine.addLine(to: CGPoint(x: chartOffset + chartWidth, y: bottomY - Properties.instance.maxAcceptable! * scaleY))
                    ctx.stroke(maxAcceptableLine, with: Constants.GC_GRAY, lineWidth: 0.5)
                    
                    // Draw a line for the min critical value
                    var minCriticalLine : Path = Path()
                    minCriticalLine.move(to: CGPoint(x: chartOffset, y: bottomY - Properties.instance.minCritical! * scaleY))
                    minCriticalLine.addLine(to: CGPoint(x: chartOffset + chartWidth, y: bottomY - Properties.instance.minCritical! * scaleY))
                    ctx.stroke(minCriticalLine, with: Constants.GC_GRAY, lineWidth: 0.5)
                    
                    
                    // Draw chart line
                    var chartLine : Path = Path()
                    for entry in self.model.last288Entries {
                        var x = chartOffset + (entry.date - minDate) * scaleX - dotRadius
                        let y = bottomY - entry.sgv * scaleY - dotRadius
                        x = Helper.clamp(min: chartOffset, max: chartOffset + chartWidth, value: x)
                        if entry == self.model.last288Entries.first {
                            chartLine.move(to: CGPoint(x: x + dotRadius, y: y + dotRadius))
                        } else {
                            chartLine.addLine(to: CGPoint(x: x + dotRadius, y: y + dotRadius))
                        }
                    }
                    ctx.stroke(chartLine, with: darkMode ? Constants.GC_WHITE : Constants.GC_DARK_GRAY, lineWidth: 0.5)
                                                            
                    // Draw dots on top of chart line
                    for entry in self.model.last288Entries {
                        let x = chartOffset + (entry.date - minDate) * scaleX - dotRadius
                        let y = bottomY - entry.sgv * scaleY - dotRadius
                        if x > chartOffset {
                            var dot : Path = Path()
                            dot.addEllipse(in: CGRect(origin: CGPoint(x: x, y: y), size: CGSize(width: 0.023962804 * chartHeight, height: 0.023962804 * chartHeight)))
                            ctx.fill(dot, with: Helper.getGCColorForValue(value: entry.sgv))
                            ctx.stroke(dot, with: darkMode ? Constants.GC_WHITE : Constants.GC_DARK_GRAY, lineWidth: 1)
                            
                            let valueText : Text = Text(verbatim: String(format: unitMgDl ? "%.0f" : "%.1f", unitMgDl ? entry.sgv : Helper.mgToMmol(mgPerDl: entry.sgv))).foregroundStyle(fgdColor).font(valueFont)
                            ctx.draw(valueText, at: CGPoint(x: x + dotRadius, y: entry.sgv > 350 ? y + valueFontSize + dotRadius * 2 : y - valueFontSize))
                        }
                    }
                }                                
            }
        }        
    }
}
