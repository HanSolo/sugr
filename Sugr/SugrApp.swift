//
//  SugrApp.swift
//  Sugr
//
//  Created by Gerrit Grunwald on 25.12.24.
//

import SwiftUI
import SwiftData
import BackgroundTasks
import WidgetKit


@main
struct SugrApp: App {
    @Environment(\.scenePhase)  private var phase
    let model : SugrModel = SugrModel()

    
    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(self.model)
        }
        .onChange(of: phase) {
            //debugPrint("Scene phase changed to \(phase)")
            switch phase {
                case .active     : break
                case .inactive   : break
                case .background : scheduleAppRefresh()
                default          : break
            }
        }
        .backgroundTask(.appRefresh(Constants.APP_REFRESH_ID)) {
            debugPrint("App refresh started in background")
            let entries : [GlucoEntry] = await fetchEntries(taskId: Constants.APP_REFRESH_ID)
            if Task.isCancelled {
                //debugPrint("Task was cancelled")
            } else {
                if (entries.count > 0) {
                    let entry     : GlucoEntry = entries[0]
                    let lastEntry : GlucoEntry = entries[1]
                    
                    Properties.instance.value     = entry.sgv
                    Properties.instance.date      = entry.date
                    Properties.instance.direction = entry.direction
                    Properties.instance.delta     = entry.sgv - lastEntry.sgv
                    
                    await MainActor.run {
                        self.model.last288Entries = entries
                        WidgetCenter.shared.reloadAllTimelines()
                        debugPrint("App refresh in background successful")
                    }
                } else {
                    //debugPrint("App refresh in background failed, empty entries")
                }
            }
            await scheduleAppRefresh()
        }        
    }
    
    
    func scheduleAppRefresh() -> Void{
        let now     = Date.now
        let request = BGAppRefreshTaskRequest(identifier: Constants.APP_REFRESH_ID)
        request.earliestBeginDate = now.addingTimeInterval(Constants.APP_REFRESH_INTERVAL)
        try? BGTaskScheduler.shared.submit(request)
        debugPrint("Scheduled App refresh")
    }
    
    func fetchEntries(taskId: String) async -> [GlucoEntry] {
        let url             : String = Properties.instance.nightscoutUrl!
        let token           : String = Properties.instance.nightscoutToken!
        let useApiV2        : Bool   = Properties.instance.nightscoutApiV2!
        let apiSecret       : String = Properties.instance.nightscoutApiSecret!
        let numberOfEntries : Int    = 288
        
        if url.isEmpty { return [] }
        
        let sessionConfig : URLSessionConfiguration = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest  = 30.0
        sessionConfig.timeoutIntervalForResource = 30.0
        sessionConfig.isDiscretionary            = false
     
        let urlString   : String         = "\(url)\(useApiV2 ? Constants.API_SGV_V2_JSON : Constants.API_SGV_V1_JSON)?count=\(numberOfEntries)\(token.isEmpty ? "" : "&token=\(token)")"
        let session     : URLSession     = URLSession(configuration: sessionConfig, delegate: nil, delegateQueue: .main)
        let finalUrl    : URL            = URL(string: urlString)!
        var request     : URLRequest     = URLRequest(url: finalUrl)
        request.addValue(apiSecret, forHTTPHeaderField: "API_SECRET")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "GET"
                
        do {
            let resp: (Data,URLResponse) = try await session.data(for: request)
            if let httpResponse = resp.1 as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    let data    : Data = resp.0
                    var entries : [GlucoEntry]?
                    do {
                        var jsonDecoder: JSONDecoder {
                            let decoder = JSONDecoder()
                            decoder.dateDecodingStrategy = .custom { decoder in
                                let container  = try decoder.singleValueContainer()
                                let dateString = try container.decode(String.self)
                                 
                                if let date = DateFormatter.fullISO8601.date(from: dateString) {
                                    return date
                                }
                                if let date = DateFormatter.fullISO8601_without_Z.date(from: dateString) {
                                    return date
                                }
                                throw DecodingError.dataCorruptedError(in: container, debugDescription: "Error parseJSONEntries cannot decode date string \(dateString)")
                            }
                            return decoder
                        }
                        entries = try jsonDecoder.decode([GlucoEntry].self, from: data)
                    } catch {
                        //print("Error parseJSONEntries (.fullISO8601 and .fullISO8601_without_Z): \(error)")
                        do {
                            let decoder = JSONDecoder()
                            decoder.dateDecodingStrategy = .millisecondsSince1970
                            entries = try decoder.decode([GlucoEntry].self, from: data)
                        } catch {
                            //print("Error parseJSONEntries (.millisecondsSince1970): \(error)")
                        }
                    }
                    if entries == nil {
                        //debugPrint("Entries nil")
                    } else {
                        //debugPrint("Entries successfully updated")
                        return entries!
                    }
                } else {
                    //debugPrint("http response status code != 200")
                    return []
                }
            } else {
                //debugPrint("No valid http response")
                return []
            }
        } catch {
            //debugPrint("Error calling Nightscout API. Error: \(error.localizedDescription)")
            return []
        }
        return []
    }
}
