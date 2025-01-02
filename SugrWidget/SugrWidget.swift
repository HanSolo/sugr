//
//  SugrWidget.swift
//  SugrWidget
//
//  Created by Gerrit Grunwald on 29.12.24.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    
    func placeholder(in context: Context) -> SugrEntry {
        //debugPrint("SugrWidget.placeholder()")
        let unitMgDl : Bool         = Properties.instance.unitMgDl!
        let glucoEntries  : [GlucoEntry] = Helper.getEntriesFromSharedUserDefaults()
        if glucoEntries.count > 1 {
            let currentEntry : GlucoEntry = glucoEntries.first!
            let lastEntry    : GlucoEntry = glucoEntries.last!
            let value        : Double     = unitMgDl ? currentEntry.sgv : Helper.mgToMmol(mgPerDl: currentEntry.sgv)
            let date         : Double     = currentEntry.date
            let delta        : Double     = unitMgDl ? (value - lastEntry.sgv) : Helper.mgToMmol(mgPerDl: (value - lastEntry.sgv))
            let arrow        : String     = Constants.Direction.fromText(text: currentEntry.direction).arrow
            return SugrEntry(date: Date.now, value: value, delta: delta, update: date, arrow: arrow, unitMgDl: unitMgDl)
        } else {
            return SugrEntry(date: Date.now, value: 0.0, delta: 0.0, update: Date.now.timeIntervalSince1970, arrow: "", unitMgDl: true)
        }
    }

    func getSnapshot(in context: Context, completion: @escaping (SugrEntry) -> ()) {
        //debugPrint("SugrWidget.getSnapshot()")
        let unitMgDl : Bool         = Properties.instance.unitMgDl!
        let glucoEntries  : [GlucoEntry] = Helper.getEntriesFromSharedUserDefaults()
        var entry    : SugrEntry
        if glucoEntries.count > 1 {
            let currentEntry : GlucoEntry = glucoEntries.first!
            let lastEntry    : GlucoEntry = glucoEntries.last!
            let value        : Double     = unitMgDl ? currentEntry.sgv : Helper.mgToMmol(mgPerDl: currentEntry.sgv)
            let date         : Double     = currentEntry.date
            let delta        : Double     = unitMgDl ? (value - lastEntry.sgv) : Helper.mgToMmol(mgPerDl: (value - lastEntry.sgv))
            let arrow        : String     = Constants.Direction.fromText(text: currentEntry.direction).arrow
            entry = SugrEntry(date: Date.now, value: value, delta: delta, update: date, arrow: arrow, unitMgDl: unitMgDl)
        } else {
            entry = SugrEntry(date: Date.now, value: 0.0, delta: 0.0, update: Date.now.timeIntervalSince1970, arrow: "", unitMgDl: true)
        }
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SugrEntry>) -> ()) {
        //debugPrint("SugrWidget.getTimeline()")
        var entries : [SugrEntry] = []
        let now     : Date        = Date.now
        for minOffset in 0 ..< 2 {
            let entryDate    : Date         = Calendar.current.date(byAdding: .minute, value: minOffset * 30, to: now)!
            let unitMgDl     : Bool         = Properties.instance.unitMgDl!
            let glucoEntries : [GlucoEntry] = Helper.getEntriesFromSharedUserDefaults()
            var entry        : SugrEntry
            if glucoEntries.count > 1 {
                let currentEntry : GlucoEntry = glucoEntries.first!
                let lastEntry    : GlucoEntry = glucoEntries.last!
                let value        : Double     = unitMgDl ? currentEntry.sgv : Helper.mgToMmol(mgPerDl: currentEntry.sgv)
                let date         : Double     = currentEntry.date
                let delta        : Double     = unitMgDl ? (value - lastEntry.sgv) : Helper.mgToMmol(mgPerDl: (value - lastEntry.sgv))
                let arrow        : String     = Constants.Direction.fromText(text: currentEntry.direction).arrow
                entry = SugrEntry(date: entryDate, value: value, delta: delta, update: date, arrow: arrow, unitMgDl: unitMgDl)
            } else {
                entry = SugrEntry(date: entryDate, value: 0.0, delta: 0.0, update: Date.now.timeIntervalSince1970, arrow: "", unitMgDl: true)
            }
            entries.append(entry)
        }
        let timeline : Timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)        
    }
}


struct SugrEntry: TimelineEntry {
    let date     : Date
    let value    : Double
    let delta    : Double
    let update   : Double
    let arrow    : String
    let unitMgDl : Bool
}


struct SugrWidgetEntryView : View {
    @Environment(\.widgetFamily) private var family    
    var entry     : Provider.Entry
    var formatter : DateFormatter = DateFormatter()
    
    init(entry: Provider.Entry) {
        self.entry = entry
        self.formatter.dateStyle = .short
        self.formatter.timeStyle = .short
        if !Properties.instance.unitMgDl! {
            self.formatter.locale = Locale(identifier: "en_US_POSIX")
        }
    }
    
    var body: some View {
        let unitMgDl : Bool   = entry.unitMgDl
        let value    : Double = entry.value
        let delta    : Double = entry.delta
        let date     : Double = entry.update
        let arrow    : String = entry.arrow
        
        if family == .systemMedium {
            VStack {
                Text("\(String(format: unitMgDl ? "%.0f" : "%.1f", value)) \(arrow)")
                    .font(Font.system(size: 48, weight: .bold, design: .rounded))
                Text("\(unitMgDl ? "mg/dl" : "mmol/L") \(delta > 0 ? "+" : "")\(String(format: unitMgDl ? "%.0f" : "%.1f", delta))")
                    .font(Font.system(size: 14, weight: .regular, design: .rounded))
                Text("\(formatter.string(from: Date(timeIntervalSince1970: date)))")
                    .font(Font.system(size: 14, weight: .regular, design: .rounded))
            }
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
            .background(Helper.getColorForValue(value: value))
            .containerBackground(for: .widget) {
                Helper.getColorForValue(value: value)
            }
            .cornerRadius(5)
            .edgesIgnoringSafeArea(.all)
        } else if family == .systemSmall {
            VStack {
                Text("\(String(format: unitMgDl ? "%.0f" : "%.1f", value)) \(arrow)")
                    .font(Font.system(size: 36, weight: .bold, design: .rounded))
                Text("\(unitMgDl ? "mg/dl" : "mmol/L") \(delta > 0 ? "+" : "")\(String(format: unitMgDl ? "%.0f" : "%.1f", delta))")
                    .font(Font.system(size: 14, weight: .regular, design: .rounded))
                Text("\(formatter.string(from: Date(timeIntervalSince1970: date)))")
                    .font(Font.system(size: 14, weight: .regular, design: .rounded))
            }
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
            .background(Helper.getColorForValue(value: value))
            .containerBackground(for: .widget) {
                Helper.getColorForValue(value: value)
            }
            .cornerRadius(5)
            .edgesIgnoringSafeArea(.all)
        } else if family == .accessoryRectangular {
            VStack {
                HStack(alignment: .center, spacing: .some(0)) {
                    Text("\(String(format: unitMgDl ? "%.0f" : "%.1f", value))")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                        .foregroundColor(.primary)
                    Text("\(arrow)")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                        .containerBackground(for: .widget) {
                            Color.clear
                        }
                        .foregroundColor(.primary)
                }
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, alignment: .center)
                .padding(EdgeInsets(top: 5, leading: 0, bottom: 5, trailing: 0))
                Text("\(String(format: unitMgDl ? "%.0f" : "%.1f", delta)) \(unitMgDl ? "mg/dl" : "mmol/L")")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                    .containerBackground(for: .widget) {
                        Color.clear
                    }
                    .foregroundColor(.primary)
                Text("\(formatter.string(from: Date(timeIntervalSince1970: date)))")
                    .font(Font.system(size: 10, weight: .regular, design: .rounded))
                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                    .containerBackground(for: .widget) {
                        Color.clear
                    }
                    .foregroundColor(.primary)
            }
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, alignment: .center)
            .containerBackground(.regularMaterial, for: .widget)
            .background(.clear)
            .padding()
        } else if family == .accessoryCircular {
            VStack(alignment: .center, spacing: .some(0)) {
                Text("\(String(format: unitMgDl ? "%.0f" : "%.1f", value))")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                    .foregroundColor(.primary)
                Text("\(arrow)")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                    .containerBackground(for: .widget) {
                        Color.clear
                    }
                    .foregroundColor(.primary)
            }
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, alignment: .center)
            .padding()
            .cornerRadius(100)
            .edgesIgnoringSafeArea(.all)
            .containerBackground(for: .widget) {
                Color.clear
            }
            .background(.clear)
        }
    }
}


struct SugrWidget: Widget {
    @Environment(\.widgetFamily) private var family
        
    var body: some WidgetConfiguration {
    
        StaticConfiguration(kind: Constants.WIDGET_KIND, provider: Provider()) { entry in
            SugrWidgetEntryView(entry: entry)
                .background(Color.clear)
                .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                .cornerRadius(10)
        }
        .configurationDisplayName("SugrMon Widget")
        .description("A widget to show the glucose value fetched from a nightscout server")
        .supportedFamilies([.systemMedium, .systemSmall, .accessoryRectangular, .accessoryCircular])
    }
}
