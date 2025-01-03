//
//  RangeView.swift
//  Sugr
//
//  Created by Gerrit Grunwald on 03.01.25.
//

import SwiftUI
import CoreGraphics


struct RangeView: View {
    @Environment(\.dismiss)      private var dismiss
    @Environment(\.colorScheme)  private var colorScheme
    @EnvironmentObject           private var model    : SugrModel
    @State                       private var interval : Constants.Interval {
        didSet {
            self.entries = self.model.last288Entries.reversed()[0 ..< Int(self.interval.noOfEntries)]
        }
    }
    @State                       private var entries  : ArraySlice<GlucoEntry> = []
    @State                       private var toggle   : Bool = false
    
    private let dateFormatter : DateFormatter        = DateFormatter()
    private let calendar      : Calendar             = Calendar.current
    private var intervals     : [Constants.Interval] = [ Constants.Interval.LAST_24_HOURS,
                                                         Constants.Interval.LAST_12_HOURS,
                                                         Constants.Interval.LAST_6_HOURS,
                                                         Constants.Interval.LAST_3_HOURS ]
    
    
    init(interval: Constants.Interval) {
        self.interval = interval
    }
    
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                HStack {
                    Spacer()
                    Button("Close") {
                        dismiss()
                    }
                    .foregroundStyle(.primary)
                    .buttonStyle(.plain)
                }
                .padding(EdgeInsets(top: 0, leading: 0, bottom: 10, trailing: 0))
                
                Text("Selected interval \(self.interval.text)")
                    .font(Font.system(size: geometry.size.width * 0.05, weight: .regular, design: .rounded))
                
                Canvas(opaque: false, colorMode: .linear, rendersAsynchronously: true) { ctx, size in
                    let darkMode       : Bool   = self.colorScheme == .dark
                    let width          : Double = size.width
                    let height         : Double = size.height
                    let unitMgDl       : Bool   = Properties.instance.unitMgDl!
                    let chartOffset    : Double = 10
                    let chartWidth     : Double = width - (2 * chartOffset)
                    let chartHeight    : Double = height - (2 * chartOffset)
                    let fgdColor       : Color  = .primary
                    let scaleXFontSize : Double = width * 0.032
                    let scaleXFont     : Font   = Font.system(size: scaleXFontSize, weight: .regular, design: .rounded)
                    
                    
                    // Set dateformatter to short format for the xAxis tickmarks
                    dateFormatter.dateFormat = unitMgDl ? Constants.TF_MG_DL_SHORT : Constants.TF_MMOL_L_SHORT
                    
                    if !self.model.last288Entries.isEmpty {
                        let numberOfEntries : Int    = Int(self.interval.noOfEntries)
                        let now             : Double = Date.now.timeIntervalSince1970
                        let visibleRange    : Double = self.interval.seconds
                        let minDate         : Double = now - visibleRange
                        let maxDate         : Double = now
                        let scaleX          : Double = chartWidth / (maxDate - minDate)
                        let tickStepX       : Double = chartWidth / Double(numberOfEntries)
                        let topY            : Double = chartOffset + scaleXFontSize * 2
                        let bottomY         : Double = chartOffset + chartHeight - scaleXFontSize * 2
                        let deltaY          : Double = bottomY - topY
                        let scaleY          : Double = deltaY / Constants.DEFAULT_MAX_VALUE_MG_DL
                        let dotRadius       : Double = 0.011981402 * chartHeight
                        let nightStart      : Double = Properties.instance.nightBeginOffset!
                        let nightEnd        : Double = Properties.instance.nightEndOffset!
                                                
                        // Nights
                        var midnights : Set<Double> = Set()
                        let firstMidnight : Double = calendar.startOfDay(for: Date(timeIntervalSince1970: minDate)).timeIntervalSince1970
                        midnights.insert(firstMidnight)
                        midnights.insert(firstMidnight + Constants.SECONDS_PER_DAY)
                        midnights.insert(firstMidnight + Constants.SECONDS_PER_DAY * 2)
                        
                        if darkMode {
                            var bkgRect : Path = Path()
                            bkgRect.addRect(CGRect(x: chartOffset, y: topY, width: chartWidth, height: bottomY - topY))
                            ctx.fill(bkgRect, with: Constants.GC_BLACK)
                        }
                        
                        for midnight in midnights {
                            let nightRectX : Double = chartOffset + (midnight - nightStart - minDate) * scaleX
                            let nightRectW : Double = (nightStart + nightEnd) * scaleX
                            var night : Path = Path()
                            night.addRect(CGRect(x: nightRectX, y: topY, width: nightRectW, height: bottomY - topY))
                            ctx.fill(night, with: darkMode ? Constants.GC_DARK_GRAY : Constants.GC_NIGHT_BRIGHT)
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
                        for n in 0..<numberOfEntries + 1 {
                            if n % self.interval.tickLabelDistance == 0 {
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
                        
                        let maxNormalText : Text = Text(verbatim: String(format: unitMgDl ? "%.0f" : "%.1f", unitMgDl ? Properties.instance.maxNormal! : Helper.mgToMmol(mgPerDl: Properties.instance.maxNormal!))).foregroundStyle(fgdColor).font(scaleXFont)
                        ctx.draw(maxNormalText, at: CGPoint(x: chartOffset, y: chartOffset + bottomY - Properties.instance.maxNormal! * scaleY - scaleXFontSize))
                        
                        let minNormalText : Text = Text(verbatim: String(format: unitMgDl ? "%.0f" : "%.1f", unitMgDl ? Properties.instance.minNormal! : Helper.mgToMmol(mgPerDl: Properties.instance.minNormal!))).foregroundStyle(fgdColor).font(scaleXFont)
                        ctx.draw(minNormalText, at: CGPoint(x: chartOffset, y: chartOffset + bottomY - Properties.instance.minNormal! * scaleY - scaleXFontSize))
                        
                        // Draw a line for the max acceptable value
                        var maxAcceptableLine : Path = Path()
                        maxAcceptableLine.move(to: CGPoint(x: chartOffset, y: bottomY - Properties.instance.maxAcceptable! * scaleY))
                        maxAcceptableLine.addLine(to: CGPoint(x: chartOffset + chartWidth, y: bottomY - Properties.instance.maxAcceptable! * scaleY))
                        ctx.stroke(maxAcceptableLine, with: Constants.GC_GRAY, lineWidth: 0.5)
                        
                        let maxAcceptableText : Text = Text(verbatim: String(format: unitMgDl ? "%.0f" : "%.1f", unitMgDl ? Properties.instance.maxAcceptable! : Helper.mgToMmol(mgPerDl: Properties.instance.maxAcceptable!))).foregroundStyle(fgdColor).font(scaleXFont)
                        ctx.draw(maxAcceptableText, at: CGPoint(x: chartOffset, y: chartOffset + bottomY - Properties.instance.maxAcceptable! * scaleY - scaleXFontSize))
                        
                        // Draw a line for the min critical value
                        var minCriticalLine : Path = Path()
                        minCriticalLine.move(to: CGPoint(x: chartOffset, y: bottomY - Properties.instance.minCritical! * scaleY))
                        minCriticalLine.addLine(to: CGPoint(x: chartOffset + chartWidth, y: bottomY - Properties.instance.minCritical! * scaleY))
                        ctx.stroke(minCriticalLine, with: Constants.GC_GRAY, lineWidth: 0.5)
                        
                        let minCriticalText : Text = Text(verbatim: String(format: unitMgDl ? "%.0f" : "%.1f", unitMgDl ? Properties.instance.minCritical! : Helper.mgToMmol(mgPerDl: Properties.instance.minCritical!))).foregroundStyle(fgdColor).font(scaleXFont)
                        ctx.draw(minCriticalText, at: CGPoint(x: chartOffset, y: chartOffset + bottomY - Properties.instance.minCritical! * scaleY - scaleXFontSize))
                        
                        // Draw a line for the min value
                        var minLine : Path = Path()
                        minLine.move(to: CGPoint(x: chartOffset, y: bottomY - 39 * scaleY))
                        minLine.addLine(to: CGPoint(x: chartOffset + chartWidth, y: bottomY - 39 * scaleY))
                        ctx.stroke(minLine, with: Constants.GC_GRAY, lineWidth: 0.5)
                        
                        let minText : Text = Text(verbatim: String(format: unitMgDl ? "%.0f" : "%.1f", unitMgDl ? 39.0 : Helper.mgToMmol(mgPerDl: 39.0))).foregroundStyle(fgdColor).font(scaleXFont)
                        ctx.draw(minText, at: CGPoint(x: chartOffset, y: chartOffset + bottomY - 39.0 * scaleY - scaleXFontSize))
                                                
                        // Draw chart line
                        var chartLine : Path = Path()
                        for entry in entries {
                            var x = chartOffset + (entry.date - minDate) * scaleX - dotRadius
                            let y = bottomY - entry.sgv * scaleY - dotRadius
                            x = Helper.clamp(min: chartOffset, max: chartOffset + chartWidth, value: x)
                            if entry == entries.first {
                                chartLine.move(to: CGPoint(x: x + dotRadius, y: y + dotRadius))
                            } else {
                                chartLine.addLine(to: CGPoint(x: x + dotRadius, y: y + dotRadius))
                            }
                        }
                        ctx.stroke(chartLine, with: darkMode ? Constants.GC_WHITE : Constants.GC_DARK_GRAY, lineWidth: 0.5)
                    }
                }.id(self.toggle)
                
                Picker("", selection: $interval) {
                    ForEach(intervals, id: \.self) {
                        Text($0.text)
                    }
                }
                .pickerStyle(.segmented)
                .onChange(of: interval) {
                    self.interval = interval
                }
            }
            .padding()
        }
        .task {
            self.interval = intervals.first!
            self.toggle.toggle()
        }
    }
}
