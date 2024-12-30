//
//  SugrModel.swift
//  Sugr
//
//  Created by Gerrit Grunwald on 25.12.24.
//

import Foundation
import SwiftData
import WidgetKit

@MainActor
public class SugrModel: ObservableObject {
    @Published var networkMonitor      : NetworkMonitor = NetworkMonitor()
    @Published var date                : Double         = Properties.instance.date! {
        willSet {
            self.lastDate = self.date
        }
        didSet {
            self.glucoseDeltaSeconds = self.date - self.lastDate
        }
    }
    @Published var value               : Double         = Properties.instance.value! {
        willSet {
            self.lastValue = self.value
        }
        didSet {
            self.glucoseDeltaValue = self.value - self.lastValue
        }
    }
    @Published var lastDate            : Double         = Properties.instance.lastDate! {
        didSet {
            Properties.instance.lastDate = self.lastDate
        }
    }
    @Published var lastValue           : Double         = Properties.instance.lastValue! {
        didSet {
            Properties.instance.lastValue = self.lastValue
        }
    }
    @Published var glucoseDeltaValue   : Double         = 0.0
    @Published var glucoseDeltaSeconds : Double         = 0.0
    @Published var last13Entries       : [GlucoEntry]   = [] {
        didSet {
            if last13Entries.count > 1 {
                let entry     : GlucoEntry = last13Entries.last!
                let lastEntry : GlucoEntry = last13Entries.dropLast().last!                
                self.currentEntry = entry
                self.lastEntry    = lastEntry
                Properties.instance.value     = entry.sgv
                Properties.instance.date      = entry.date
                Properties.instance.direction = entry.direction
                Properties.instance.delta     = entry.sgv - lastEntry.sgv
                //Helper.entriesToUserDefaults(entries: [entry, lastEntry])
                
                //WidgetCenter.shared.reloadAllTimelines()
            }
        }
    }
    @Published var currentEntry        : GlucoEntry? {
        didSet {
            self.date = (currentEntry?.date ?? 0)
            self.value  = currentEntry?.sgv  ?? 0
        }
    }
    @Published var lastEntry           : GlucoEntry? {
        didSet {
            self.lastDate = (lastEntry?.date ?? 0)
            self.lastValue  = lastEntry?.sgv  ?? 0
        }
    }
    @Published var last8640Entries     : [GlucoEntry]   = [] {
        didSet {
            if !last8640Entries.isEmpty {
                let average : Double = self.last8640Entries.reduce(0) { $0 + $1.sgv } / Double(self.last8640Entries.count)
                self.hba1c = (0.0296 * average) + 2.419 // formula from 2014 (https://www.ncbi.nlm.nih.gov/pmc/articles/PMC4771657/)
            }
        }
    }
    @Published var hba1c               : Double         = 0.0
    

    init(glucoseUpdate: Double? = 0.0, glucoseValue: Double? = 0.0) {
        self.date = glucoseUpdate!
        self.value  = glucoseValue!
    }
}
