//
//  SugrWidget.swift
//  SugrWidget
//
//  Created by Gerrit Grunwald on 29.12.24.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    @EnvironmentObject private var model : SugrModel
    
    
    func placeholder(in context: Context) -> SugrEntry {
        //let glucoEntries : [GlucoEntry] = Helper.entriesFromUserDefaults()
        //let glucoEntry   : GlucoEntry   = glucoEntries.last!
        //return SugrEntry(date: Date(), value: glucoEntry.sgv, timestamp: glucoEntry.date, direction: glucoEntry.direction)
        return SugrEntry(date: Date(), value: Properties.instance.value!, timestamp: Properties.instance.date!, delta: Properties.instance.delta!, direction: Properties.instance.direction!)
    }

    func getSnapshot(in context: Context, completion: @escaping (SugrEntry) -> ()) {
        //let glucoEntries : [GlucoEntry] = Helper.entriesFromUserDefaults()
        //let glucoEntry   : GlucoEntry   = glucoEntries.last!
        //let entry        : SugrEntry    = SugrEntry(date: Date(), value: glucoEntry.sgv, timestamp: glucoEntry.date, direction: glucoEntry.direction)
        let entry        : SugrEntry    = SugrEntry(date: Date(), value: Properties.instance.value!, timestamp: Properties.instance.date!, delta: Properties.instance.delta!, direction: Properties.instance.direction!)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries : [SugrEntry] = []
        let now     : Date        = Date()
        
        for hourOffset in 0 ..< 2 {
            let entryDate    : Date         = Calendar.current.date(byAdding: .hour, value: hourOffset, to: now)!
            //let glucoEntries : [GlucoEntry] = Helper.entriesFromUserDefaults()
            //let glucoEntry   : GlucoEntry   = glucoEntries.last!
            //let entry        : SugrEntry    = SugrEntry(date: entryDate, value: glucoEntry.sgv, timestamp: glucoEntry.date, direction: glucoEntry.direction)
            
            let entry        : SugrEntry    = SugrEntry(date: entryDate, value: Properties.instance.value!, timestamp: Properties.instance.date!, delta: Properties.instance.delta!, direction: Properties.instance.direction!)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct SugrEntry: TimelineEntry {
    let date      : Date
    let value     : Double
    let timestamp : Double
    let delta     : Double
    let direction : String
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
        let unitMgDl      : Bool   = Properties.instance.unitMgDl!
        let value         : Double = unitMgDl ? Properties.instance.value! : Helper.mgToMmol(mgPerDl: Properties.instance.value!)
        let arrow         : String = Constants.Direction.fromText(text: self.entry.direction).arrow
        let delta         : Double = unitMgDl ? Properties.instance.delta! : Helper.mgToMmol(mgPerDl: Properties.instance.delta!)
        let date          : Double = Properties.instance.date!
        let secondsDelta  : Double = Date.now.timeIntervalSince1970 - date
        let timeSinceLast : String = Helper.secondsToDDHHMMString(seconds: secondsDelta)
        
        if family == .systemMedium {
            VStack {
                Text("\(String(format: unitMgDl ? "%.0f" : "%.1f", value)) \(arrow)")
                    .font(Font.system(size: 48, weight: .bold, design: .rounded))
                Text("\(unitMgDl ? "mg/dl" : "mmol/L") \(delta > 0 ? "+" : "")\(String(format: unitMgDl ? "%.0f" : "%.1f", delta))")
                    .font(Font.system(size: 14, weight: .regular, design: .rounded))
                Text("\(timeSinceLast)")
                    .font(Font.system(size: 14, weight: .regular, design: .rounded))
            }
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
            .background(Helper.getColorForValue(value: self.entry.value))
            .containerBackground(for: .widget) {
                Helper.getColorForValue(value: self.entry.value)
            }
            .cornerRadius(5)
            .edgesIgnoringSafeArea(.all)
        } else if family == .systemSmall {
            VStack {
                Text("\(String(format: unitMgDl ? "%.0f" : "%.1f", value)) \(arrow)")
                    .font(Font.system(size: 36, weight: .bold, design: .rounded))
                Text("\(unitMgDl ? "mg/dl" : "mmol/L") \(delta > 0 ? "+" : "")\(String(format: unitMgDl ? "%.0f" : "%.1f", delta))")
                    .font(Font.system(size: 14, weight: .regular, design: .rounded))
                Text("\(timeSinceLast)")
                    .font(Font.system(size: 14, weight: .regular, design: .rounded))
            }
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
            .background(Helper.getColorForValue(value: self.entry.value))
            .containerBackground(for: .widget) {
                Helper.getColorForValue(value: self.entry.value)
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
                Text("\(timeSinceLast)")
                    .font(Font.system(size: 10, weight: .regular, design: .rounded))
                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                    .containerBackground(for: .widget) {
                        Color.clear
                    }
                    .foregroundColor(.primary)
            }
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, alignment: .center)
            .containerBackground(for: .widget) {
                Color.clear
            }
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
    
    let kind: String = "SugrWidget"

    var body: some WidgetConfiguration {
    
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            SugrWidgetEntryView(entry: entry)
                .background()
                .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                .cornerRadius(10)
        }
        .configurationDisplayName("SugrMon Widget")
        .description("Glucose value")
        .supportedFamilies([.systemMedium, .systemSmall, .accessoryRectangular, .accessoryCircular])
    }
}
