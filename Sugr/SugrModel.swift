//
//  SugrModel.swift
//  Sugr
//
//  Created by Gerrit Grunwald on 25.12.24.
//

import Foundation
import SwiftData

@MainActor
public class SugrModel: ObservableObject {
    @Published var networkMonitor      : NetworkMonitor = NetworkMonitor()
    @Published var date                : Double         = Date.now.timeIntervalSince1970 {
        willSet {
            self.lastDate = self.date
        }
    }
    @Published var value               : Double         = 0.0 {
        willSet {
            self.lastValue = self.value
        }
        didSet {
            self.delta = self.value - self.lastValue
        }
    }
    @Published var lastDate            : Double         = Date.now.timeIntervalSince1970
    @Published var lastValue           : Double         = 0.0
    @Published var delta               : Double         = 0.0
    @Published var currentEntry        : GlucoEntry? {
        didSet {
            self.date  = (currentEntry?.date ?? 0)
            self.value = currentEntry?.sgv  ?? 0
        }
    }
    @Published var lastEntry           : GlucoEntry? {
        didSet {
            self.lastDate  = (lastEntry?.date ?? 0)
            self.lastValue = lastEntry?.sgv  ?? 0
        }
    }
    @Published var last13Entries       : [GlucoEntry]   = []
    @Published var last288Entries      : [GlucoEntry]   = [] {
        didSet {
            if last288Entries.count > 1 {
                let entry     : GlucoEntry = last288Entries.last!
                let lastEntry : GlucoEntry = last288Entries.dropLast().last!                
                
                self.currentEntry = entry
                self.lastEntry    = lastEntry

                Helper.storeEntriesToSharedUserDefaults(entries: [entry, lastEntry] )                                
                
                if last288Entries.count > 12 {
                    self.last13Entries.removeAll()
                    for i in 0..<12 {
                        self.last13Entries.append(last288Entries[last288Entries.count - i - 1])
                    }
                    self.last13Entries.reverse()
                }
                
                self.averageToday = Helper.getAverageForToday(entries: self.last288Entries)
                self.inRangeToday = Helper.getTimeInRangeForToday(entries: self.last288Entries)
                
                if !self.last8640Entries.isEmpty {
                    self.averagesLast30Days.removeAll()
                    for n in 0..<30 {
                        let day : Date = Date.now - (TimeInterval(n) * Constants.SECONDS_PER_DAY)
                        let avg : Double = Helper.getAverageForDay(entries: self.last8640Entries, day: day)
                        averagesLast30Days.append(avg)
                    }
                }                 
            }
        }
    }
    @Published var last8640Entries     : [GlucoEntry]   = [] {
        didSet {
            if !last8640Entries.isEmpty {
                let average   : Double = self.last8640Entries.reduce(0) { $0 + $1.sgv } / Double(self.last8640Entries.count)
                self.hba1c             = (0.0296 * average) + 2.419 // formula from 2014 (https://www.ncbi.nlm.nih.gov/pmc/articles/PMC4771657/)
                self.inRangeLast30Days = Helper.getTimeInRangeForLast30Days(entries: self.last8640Entries)
                self.averagesLast30Days.removeAll()
                for n in 0..<30 {
                    let day : Date = Date.now - (TimeInterval(n) * Constants.SECONDS_PER_DAY)
                    let avg : Double = Helper.getAverageForDay(entries: self.last8640Entries, day: day)
                    averagesLast30Days.append(avg)
                }
            }
        }
    }
    @Published var hba1c               : Double         = 0.0
    @Published var averageToday        : Double         = 0.0
    @Published var inRangeToday        : Double         = 0.0
    @Published var inRangeLast30Days   : Double         = 0.0
    @Published var averagesLast30Days  : [Double]       = []
    

    init(glucoseUpdate: Double? = 0.0, glucoseValue: Double? = 0.0) {
        self.date  = glucoseUpdate!
        self.value = glucoseValue!
    }
}
