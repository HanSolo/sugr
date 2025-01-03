//
//  ContentView.swift
//  Sugr
//
//  Created by Gerrit Grunwald on 25.12.24.
//

import SwiftUI
import SwiftData
import WidgetKit


struct ContentView: View {
    @Environment(\.scenePhase)  private var phase
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject          private var model : SugrModel
    
    @State private var settingsViewVisible : Bool = false
    @State private var rangeViewVisible    : Bool = false
    @State private var scrollPosition      : ScrollPosition = ScrollPosition()
    
    
    // Timer will be triggered every 30 sec to check if update is needed
    let timer = Timer.publish(every: 30, on: .main, in: .common).autoconnect()
    
    
    var body: some View {
        //let darkMode    : Bool = self.colorScheme == .dark
        //let isLandscape : Bool = UIDevice.current.orientation.isLandscape
        
        ZStack {            
            (colorScheme == .dark ? Constants.DARK_GRAY : Constants.WHITE)
                .ignoresSafeArea(.all)
            GeometryReader { geometry in
                VStack(alignment: .center, spacing: 0) {
                    TimelineView(.animation(minimumInterval: Constants.CANVAS_REFRESH_INTERVAL)) { timeline in
                        InfoView()
                            .frame(width: geometry.size.width, height: geometry.size.height * 0.32)
                            .padding(EdgeInsets(top: 0, leading: 0, bottom: -5, trailing: 0))
                        AverageView()
                            .frame(width: geometry.size.width, height: geometry.size.height * 0.044)
                            .padding(EdgeInsets(top: 0, leading: 0, bottom: -5, trailing: 0))
                        ScrollView(.horizontal) {
                            DeltaChartView()
                                .frame(width: geometry.size.width / 3600 * 86400, height: geometry.size.height * 0.18)
                                .padding(EdgeInsets(top: 0, leading: 0, bottom: -5, trailing: 0))
                            LineChartView()
                                .frame(width: geometry.size.width / 3600 * 86400, height: geometry.size.height * 0.4)
                        }
                        .scrollPosition(self.$scrollPosition, anchor: .trailing)
                    }
                    
                    HStack {
                        Button(action: {
                            self.rangeViewVisible = true
                        }) {
                            Image(systemName: "chart.xyaxis.line").imageScale(.large)
                                .foregroundColor(.primary)
                        }
                        .buttonStyle(.plain)
                        
                        Spacer()
                        
                        Button(action: {
                            self.settingsViewVisible = true
                        }) {
                            Image(systemName: "gear").imageScale(.large)
                                .foregroundColor(.primary)
                        }
                        .buttonStyle(.plain)
                    }.padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
                }
                .scrollTargetLayout()
                .sheet(isPresented: $rangeViewVisible) {
                    RangeView(interval: Constants.Interval.LAST_24_HOURS)
                }
                .sheet(isPresented: $settingsViewVisible) {
                    SettingsView()
                }
                .onReceive(timer) { _ in
                    fetchLast288Entries(force: false)
                    fetchLast30Days()
                }
                .onChange(of: phase) {
                    switch phase {
                        case .active     :
                            fetchLast288Entries(force: true)
                            fetchLast30Days()
                        scrollPosition.scrollTo(edge: Edge.trailing)
                        case .inactive   : break
                        case .background : break
                        default          : break
                    }
                }
            }
        }
    }
    
    private func fetchLast288Entries(force: Bool) -> Void {
        let now : Double = Date.now.timeIntervalSince1970
        if self.model.networkMonitor.isConnected {
            if self.model.currentEntry == nil || force {
                debugPrint(force ? "Forced update" : "No current entry found, fetching new entries")
                Task {
                    let entries : [GlucoEntry] = await RestController.getGlucoseData(url: Properties.instance.nightscoutUrl!, apiSecret: Properties.instance.nightscoutApiSecret!, token: Properties.instance.nightscoutToken!, useApiV2: Properties.instance.nightscoutApiV2!, numberOfEntries: 288)!
                    self.model.last288Entries = entries.reversed()
                    Properties.instance.last288EntriesUpdate = now
                    if phase == .active {
                        WidgetCenter.shared.reloadAllTimelines()
                        debugPrint("WidgetCenter reloaded")
                    }
                }
            } else {
                if now - Properties.instance.last288EntriesUpdate! > Constants.UPDATE_INTERVAL {
                    debugPrint("Fetching new entries")
                    Task {
                        let entries : [GlucoEntry] = await RestController.getGlucoseData(url: Properties.instance.nightscoutUrl!, apiSecret: Properties.instance.nightscoutApiSecret!, token: Properties.instance.nightscoutToken!, useApiV2: Properties.instance.nightscoutApiV2!, numberOfEntries: 288)!
                        self.model.last288Entries = entries.reversed()
                        Properties.instance.last288EntriesUpdate = now
                        if phase == .active {
                            WidgetCenter.shared.reloadAllTimelines()
                            debugPrint("WidgetCenter reloaded")
                        }
                    }
                }
            }
        }
    }
    
    private func fetchLast30Days() -> Void {
        let now  : Double = Date.now.timeIntervalSince1970
        let from : Int    = Int(now * 1000) - Int(Constants.Interval.LAST_720_HOURS.seconds * 1000)
        if self.model.networkMonitor.isConnected {
            if self.model.last8640Entries.isEmpty {
                Task {
                    let entries : [GlucoEntry] = await RestController.getGlucoseData(url: Properties.instance.nightscoutUrl!, apiSecret: Properties.instance.nightscoutApiSecret!, token: Properties.instance.nightscoutToken!, useApiV2: Properties.instance.nightscoutApiV2!, from: from, numberOfEntries: Constants.VALUES_PER_30_DAYS)!
                    self.model.last8640Entries = entries.reversed()
                    Properties.instance.last30DaysUpdate = now
                }
            } else {
                if now - Properties.instance.last30DaysUpdate! > Constants.SECONDS_PER_DAY {
                    debugPrint("self.model.last8640Entries.isEmpty = true -> reload")
                    Task {
                        let entries : [GlucoEntry] = await RestController.getGlucoseData(url: Properties.instance.nightscoutUrl!, apiSecret: Properties.instance.nightscoutApiSecret!, token: Properties.instance.nightscoutToken!, useApiV2: Properties.instance.nightscoutApiV2!, from: from, numberOfEntries: Constants.VALUES_PER_30_DAYS)!
                        self.model.last8640Entries = entries.reversed()
                        Properties.instance.last30DaysUpdate = now
                    }
                }
            }
        }
    }
}
