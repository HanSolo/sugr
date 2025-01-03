//
//  ChartView.swift
//  Sugr
//
//  Created by Gerrit Grunwald on 28.12.24.
//

import SwiftUI
import CoreGraphics


struct DeltaChartView: View {
    @Environment(\.colorScheme)  var colorScheme
    @EnvironmentObject           var model : SugrModel
    
    private let dateFormatter : DateFormatter = DateFormatter()
    
    
    var body: some View {
        GeometryReader { geometry in            
            Canvas(opaque: false, colorMode: .linear, rendersAsynchronously: false) { ctx, size in
                let darkMode      : Bool    = self.colorScheme == .dark
                let width         : Double  = size.width
                let height        : Double  = size.height
                let unitMgDl      : Bool    = Properties.instance.unitMgDl!
                let chartOffset   : Double  = 10
                let chartWidth    : Double  = width - (2 * chartOffset)
                let chartHeight   : Double  = height - (2 * chartOffset)
                let centerY       : Double  = height * 0.5
                let fgdColor      : Color   = .primary
                let deltaFontSize : Double  = height * 0.09
                let deltaFont     : Font    = Font.system(size: deltaFontSize, weight: .regular, design: .rounded)
                let barWidth      : Double  = 10
                                
                var deltas : [(Double, Double)] = []
                if !self.model.last288Entries.isEmpty {
                    for index in 1 ..< self.model.last288Entries.count {
                        let lastEntry : GlucoEntry = self.model.last288Entries[index - 1]
                        let entry     : GlucoEntry = self.model.last288Entries[index]
                        let delta     : Double     = unitMgDl ? (entry.sgv  - lastEntry.sgv) : Helper.mgToMmol(mgPerDl: (entry.sgv - lastEntry.sgv))
                        let date      : Double     = (entry.date - lastEntry.date) * 0.5
                        deltas.append((date, delta))
                    }
                }
                
                let maxDelta : Double  = max(abs(deltas.min(by: { $0.1 < $1.1 })?.1 ?? 0), abs(deltas.max(by: { $0.1 < $1.1 })?.1 ?? 0))
                let scaleY   : Double  = ((chartHeight - deltaFontSize * 3) / maxDelta) * 0.5
                
                if !self.model.last288Entries.isEmpty {
                    let now          : Double = Date.now.timeIntervalSince1970
                    let visibleRange : Double = 86400 // Visible range in seconds (86400 -> 24h)
                    let minDate      : Double = now - visibleRange
                    let maxDate      : Double = now
                    let scaleX       : Double = chartWidth / (maxDate - minDate)
                    
                    var xAxis : Path = Path()
                    xAxis.move(to: CGPoint(x: chartOffset, y: chartOffset + centerY))
                    xAxis.addLine(to: CGPoint(x: chartOffset + chartWidth, y: chartOffset + centerY))
                    ctx.stroke(xAxis, with: darkMode ? Constants.GC_WHITE : Constants.GC_GRAY)
                    
                    for n in 1..<self.model.last288Entries.count {
                        let lastEntry : GlucoEntry = self.model.last288Entries[n - 1]
                        let entry     : GlucoEntry = self.model.last288Entries[n]
                        let delta     : Double     = unitMgDl ? (entry.sgv  - lastEntry.sgv) : Helper.mgToMmol(mgPerDl: (entry.sgv - lastEntry.sgv))
                        let barDate   : Double     = (entry.date - lastEntry.date) * 0.5
                        var x         : Double     = chartOffset + (entry.date - minDate - barDate) * scaleX
                        x = Helper.clamp(min: chartOffset, max: chartOffset + chartWidth, value: x)
                        
                        let barHeight : Double     = abs(delta * scaleY)
                        let barX      : Double     = x - barWidth * 0.5
                        let barY      : Double     = delta > 0 ? chartOffset + centerY - barHeight : chartOffset + centerY
                        if barX > chartOffset {
                            var bar       : Path       = Path()
                            bar.move(to: CGPoint(x: barX, y: barY))
                            bar.addRect(CGRect(x: barX, y: barY, width: barWidth, height: barHeight))
                            ctx.fill(bar, with: darkMode ? Constants.GC_WHITE : Constants.GC_DARK_GRAY)
                            
                            let deltaText : Text       = Text(verbatim: "\(delta > 0 ? "+" : "")\(String(format: unitMgDl ? "%.0f" : "%.1f", delta))").foregroundStyle(fgdColor).font(deltaFont)
                            ctx.draw(deltaText, at: CGPoint(x: x, y: delta < 0 ? barY + barHeight + deltaFontSize * 0.9 : barY - deltaFontSize * 0.9), anchor: .center)
                        }
                    }
                }
            }
        }
    }
}
