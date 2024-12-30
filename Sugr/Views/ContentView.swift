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
    }
    
    
    private func fetchEntries() -> Void {
        let now : Double = Date.now.timeIntervalSince1970
        if self.model.networkMonitor.isConnected {
            if self.model.currentEntry == nil {
                debugPrint("No current entry found, fetching new entries")
                Task {
                    let entries : [GlucoEntry] = await RestController.getGlucoseData(url: Properties.instance.nightscoutUrl!, apiSecret: Properties.instance.nightscoutApiSecret!, token: Properties.instance.nightscoutToken!, useApiV2: Properties.instance.nightscoutApiV2!, numberOfEntries: 13, inBackground: false)!
                    self.model.last13Entries = entries.reversed()
                    Properties.instance.last13DaysUpdate = now
                }
            } else {
                if now - Properties.instance.last13DaysUpdate! > Constants.UPDATE_INTERVAL {
                    debugPrint("Fetching new entries")
                    Task {
                        let entries : [GlucoEntry] = await RestController.getGlucoseData(url: Properties.instance.nightscoutUrl!, apiSecret: Properties.instance.nightscoutApiSecret!, token: Properties.instance.nightscoutToken!, useApiV2: Properties.instance.nightscoutApiV2!, numberOfEntries: 13, inBackground: false)!
                        self.model.last13Entries = entries.reversed()
                        Properties.instance.last13DaysUpdate = now
                    }
                }
            }
        }
    }
    
    private func fetchLast30Days() -> Void {
        let now : Double = Date.now.timeIntervalSince1970
        if self.model.networkMonitor.isConnected {
            if self.model.last8640Entries.isEmpty {
                Task {
                    let entries : [GlucoEntry] = await RestController.getGlucoseData(url: Properties.instance.nightscoutUrl!, apiSecret: Properties.instance.nightscoutApiSecret!, token: Properties.instance.nightscoutToken!, useApiV2: Properties.instance.nightscoutApiV2!, numberOfEntries: Constants.VALUES_PER_30_DAYS, inBackground: false)!
                    self.model.last8640Entries = entries.reversed()
                }
            } else {
                if Date.now.timeIntervalSince1970 - Properties.instance.last30DaysUpdate! > Constants.SECONDS_PER_DAY {
                    Task {
                        let entries : [GlucoEntry] = await RestController.getGlucoseData(url: Properties.instance.nightscoutUrl!, apiSecret: Properties.instance.nightscoutApiSecret!, token: Properties.instance.nightscoutToken!, useApiV2: Properties.instance.nightscoutApiV2!, numberOfEntries: Constants.VALUES_PER_30_DAYS, inBackground: false)!
                        self.model.last8640Entries = entries.reversed()
                    }
                }
            }
        }
    }
}
