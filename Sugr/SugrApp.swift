//
//  SugrApp.swift
//  Sugr
//
//  Created by Gerrit Grunwald on 25.12.24.
//

import SwiftUI
import SwiftData
import BackgroundTasks


@main
struct SugrApp: App {
    @Environment(\.scenePhase)  private var phase
    let model : SugrModel = SugrModel()
        
    
    init() {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: Constants.APP_PROCESSING_ID, using: nil) { task in
            task.setTaskCompleted(success: true)
            //self.handleAppProcessing(task: task as! BGProcessingTask)
        }
    }
    
    
    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(self.model)
        }
        .onChange(of: phase) {
            debugPrint("Scene phase changed to \(phase)")
            switch phase {
                case .active     : break
                case .inactive   : break
                case .background : scheduleAppProcessing() //scheduleAppRefresh()
                default          : break
            }
        }
        .backgroundTask(.appRefresh(Constants.APP_REFRESH_ID)) {
            debugPrint("App refresh started in background")
            let entries : [GlucoEntry] = await RestController.getGlucoseData(url: Properties.instance.nightscoutUrl!,
                                                                             apiSecret: Properties.instance.nightscoutApiSecret!,
                                                                             token: Properties.instance.nightscoutToken!,
                                                                             useApiV2: Properties.instance.nightscoutApiV2!,
                                                                             numberOfEntries: 13,
                                                                             inBackground: false)!
            if Task.isCancelled {
                debugPrint("Task was cancelled")
            } else {
                if entries.isEmpty {
                    debugPrint("Entries are empty")
                } else {
                    let entry     : GlucoEntry = entries[0]
                    let lastEntry : GlucoEntry = entries[1]
                    
                    Properties.instance.value     = entry.sgv
                    Properties.instance.date      = entry.date
                    Properties.instance.direction = entry.direction
                    Properties.instance.delta     = entry.sgv - lastEntry.sgv
                    
                    debugPrint("App refresh in background successful")
                    
                    self.model.last13Entries = entries
                }
                await scheduleAppRefresh()
            }
        }
        .backgroundTask(.urlSession(Constants.APP_PROCESSING_ID)) {
            debugPrint("App processing task started")
            let entries : [GlucoEntry] = await RestController.getGlucoseData(url: Properties.instance.nightscoutUrl!,
                                                                             apiSecret: Properties.instance.nightscoutApiSecret!,
                                                                             token: Properties.instance.nightscoutToken!,
                                                                             useApiV2: Properties.instance.nightscoutApiV2!,
                                                                             numberOfEntries: 13,
                                                                             inBackground: false)!
            if Task.isCancelled {
                debugPrint("Task was cancelled")
            } else {
                if entries.isEmpty {
                    debugPrint("Entries are empty")
                } else {
                    let entry     : GlucoEntry = entries[0]
                    let lastEntry : GlucoEntry = entries[1]
                    
                    Properties.instance.value     = entry.sgv
                    Properties.instance.date      = entry.date
                    Properties.instance.direction = entry.direction
                    Properties.instance.delta     = entry.sgv - lastEntry.sgv
                    
                    debugPrint("App processing in background successful")
                    
                    self.model.last13Entries = entries
                }
                await scheduleAppProcessing()
            }
        }
    }
    
    func scheduleAppRefresh() -> Void{
        let now     = Date.now
        let request = BGAppRefreshTaskRequest(identifier: Constants.APP_REFRESH_ID)
        request.earliestBeginDate = now.addingTimeInterval(Constants.APP_REFRESH_INTERVAL)
        try? BGTaskScheduler.shared.submit(request)
        debugPrint("scheduled app refresh")
    }
    
    func scheduleAppProcessing() -> Void {
        let now     = Date.now
        let request = BGProcessingTaskRequest(identifier: Constants.APP_PROCESSING_ID)
        request.earliestBeginDate = now.addingTimeInterval(Constants.APP_PROCESSING_INTERVAL)
        try? BGTaskScheduler.shared.submit(request)
        debugPrint("scheduled app processing")
        
    }
}
