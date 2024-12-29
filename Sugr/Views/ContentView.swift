//
//  ContentView.swift
//  Sugr
//
//  Created by Gerrit Grunwald on 25.12.24.
//

import SwiftUI
import SwiftData


struct ContentView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject          var model : SugrModel
    
    @State var settingsViewVisible : Bool = false
    
    // Timer will be triggered every 30 sec to check if update is needed
    let timer = Timer.publish(every: 30, on: .main, in: .common).autoconnect()
    
    
    var body: some View {
        let darkMode    : Bool = self.colorScheme == .dark
        let isLandscape : Bool = UIDevice.current.orientation.isLandscape
        
        ZStack {
            (colorScheme == .dark ? Constants.DARK_GRAY : Constants.WHITE)
                .ignoresSafeArea(.all)
            GeometryReader { geometry in                
                VStack(alignment: .center, spacing: 0) {
                    TimelineView(.animation(minimumInterval: Constants.CANVAS_REFRESH_INTERVAL)) { timeline in
                        InfoView()
                            .frame(width: geometry.size.width, height: geometry.size.height * 0.32)
                        DeltaChartView()
                            .frame(width: geometry.size.width, height: geometry.size.height * 0.18)
                        LineChartView()
                            .frame(width: geometry.size.width, height: geometry.size.height * 0.4)
                    }
                    
                    
                    HStack {
                        Spacer()
                        
                        Button(action: {
                            self.settingsViewVisible = true
                        }) {
                            Image(systemName: "gear").imageScale(.large)
                                .foregroundColor(.primary)
                        }
                        .buttonStyle(.plain)
                    }.padding()
                }
                .sheet(isPresented: $settingsViewVisible) {
                    SettingsView()
                }
                .onReceive(timer) { _ in
                    fetchEntries()
                    fetchLast30Days()
                }
                .onAppear {
                    fetchEntries()
                    fetchLast30Days()
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { (_) in
            Sugr.AppDelegate.instance.scheduleAppProcessing()
        }
    }
    
    
    private func fetchEntries() -> Void {
        if self.model.networkMonitor.isConnected {
            if self.model.currentEntry == nil {
                debugPrint("No current entry found, fetching new entries")
                Task {
                    let entries : [GlucoEntry] = await RestController.getGlucoseData(url: Properties.instance.nightscoutUrl!, apiSecret: Properties.instance.nightscoutApiSecret!, token: Properties.instance.nightscoutToken!, useApiV2: Properties.instance.nightscoutApiV2!, numberOfEntries: 13, inBackground: false)!
                    self.model.last13Entries = entries.reversed()
                }
            } else {
                if Date.now.timeIntervalSince1970 - self.model.currentEntry!.date > Constants.UPDATE_INTERVAL {
                    debugPrint("Fetching new entries")
                    Task {
                        let entries : [GlucoEntry] = await RestController.getGlucoseData(url: Properties.instance.nightscoutUrl!, apiSecret: Properties.instance.nightscoutApiSecret!, token: Properties.instance.nightscoutToken!, useApiV2: Properties.instance.nightscoutApiV2!, numberOfEntries: 13, inBackground: false)!
                        self.model.last13Entries = entries.reversed()
                    }
                } else {
                    debugPrint("Entries still up to date")
                }
            }
        }
    }
    
    private func fetchLast30Days() -> Void {
        if self.model.networkMonitor.isConnected {
            if self.model.last8640Entries.isEmpty {
                //debugPrint("No data for last 30 days found, fetching new entries")
                Task {
                    let entries : [GlucoEntry] = await RestController.getGlucoseData(url: Properties.instance.nightscoutUrl!, apiSecret: Properties.instance.nightscoutApiSecret!, token: Properties.instance.nightscoutToken!, useApiV2: Properties.instance.nightscoutApiV2!, numberOfEntries: Constants.VALUES_PER_30_DAYS, inBackground: false)!
                    self.model.last8640Entries = entries.reversed()
                }
            } else {
                if Date.now.timeIntervalSince1970 - self.model.last8640Entries.last!.date > Constants.SECONDS_PER_DAY {
                    //debugPrint("Fetching new entries for last 30 days")
                    Task {
                        let entries : [GlucoEntry] = await RestController.getGlucoseData(url: Properties.instance.nightscoutUrl!, apiSecret: Properties.instance.nightscoutApiSecret!, token: Properties.instance.nightscoutToken!, useApiV2: Properties.instance.nightscoutApiV2!, numberOfEntries: Constants.VALUES_PER_30_DAYS, inBackground: false)!
                        self.model.last8640Entries = entries.reversed()
                    }
                } else {
                    //debugPrint("Entries for last 30 days still up to date")
                }
            }
        }
    }
}
