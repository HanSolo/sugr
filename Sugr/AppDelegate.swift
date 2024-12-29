//
//  AppDelegate.swift
//  Sugr
//
//  Created by Gerrit Grunwald on 25.12.24.
//

import Foundation
import BackgroundTasks
import UIKit



class AppDelegate: NSObject, UIApplicationDelegate, ObservableObject {
    static private(set) var instance: AppDelegate! = nil
    
    let model : SugrModel = SugrModel()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        AppDelegate.instance = self
        
        registerBackgroundTasks()
        
        return true
    }
    
    private func registerBackgroundTasks() -> Void {
        debugPrint("registerBackgroundTasks")
        BGTaskScheduler.shared.register(forTaskWithIdentifier: Constants.PROCESSING_TASK_REQUEST_ID, using: nil) { task in
            task.setTaskCompleted(success: true)
            self.handleAppProcessing(task: task as! BGProcessingTask)
        }
    }
    
    func scheduleAppProcessing() {
        debugPrint("scheduleAppProcessing")
        let request = BGProcessingTaskRequest(identifier: Constants.PROCESSING_TASK_REQUEST_ID)
        request.requiresExternalPower       = false
        request.requiresNetworkConnectivity = true
        request.earliestBeginDate = Date(timeIntervalSinceNow: Constants.PROCSSING_INTERVAL)
        
        BGTaskScheduler.shared.cancel(taskRequestWithIdentifier: Constants.PROCESSING_TASK_REQUEST_ID)
        do {
            try BGTaskScheduler.shared.submit(request)
            //debugPrint("AppProcessing task submitted to run at \(request.earliestBeginDate)")
        } catch {
            debugPrint("scheduleAppProcessing. Error: \(error.localizedDescription)")
        }
    }
    
    func handleAppProcessing(task: BGProcessingTask) {
        debugPrint("handleAppProcessing")
        DispatchQueue.global().async {
            let taskID = UIApplication.shared.beginBackgroundTask(withName: Constants.PROCESSING_TASK_ID, expirationHandler: ({}))
            let queue  = OperationQueue()
            queue.maxConcurrentOperationCount = 1
                    
            let processingOperation = ProcessingOperation(model: self.model)
            queue.addOperation(processingOperation)
            task.expirationHandler = {
                task.setTaskCompleted(success: false)
            }
            
            let lastOperation = queue.operations.last
            lastOperation?.completionBlock = {
                task.setTaskCompleted(success: !(lastOperation?.isCancelled ?? false))
            }
            UIApplication.shared.endBackgroundTask(taskID)
        }
        
        scheduleAppProcessing()
    }
}
