//
//  FetchOperation.swift
//  Sugr
//
//  Created by Gerrit Grunwald on 25.12.24.
//

import Foundation
import UserNotifications
import WidgetKit


class ProcessingOperation: Operation, @unchecked Sendable {
    let model : SugrModel?
    
    
    init(model: SugrModel?) {
        self.model = model
        debugPrint("ProcessingOperation inialized")
    }
    
    
    override func main() {
        if isCancelled {
            debugPrint("ProcessingOperation cancelled")
            return
        }
        if nil != self.model {
            debugPrint("main -> start background processing")
            Task {
                let entries : [GlucoEntry] = await RestController.getGlucoseData(url: Properties.instance.nightscoutUrl!, apiSecret: Properties.instance.nightscoutApiSecret!, token: Properties.instance.nightscoutToken!, useApiV2: Properties.instance.nightscoutApiV2!, numberOfEntries: 2, inBackground: true)!
                if entries.count > 1 {
                    let entry     : GlucoEntry = entries[0]
                    let lastEntry : GlucoEntry = entries[1]
                    
                    Helper.entriesToUserDefaults(entries: [entry, lastEntry])
                    
                    WidgetCenter.shared.reloadAllTimelines()
                    debugPrint("background processing successful")
                }
            }
        }
    }
}
