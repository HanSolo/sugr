//
//  Storage.swift
//  GlucoTracker
//
//  Created by Gerrit Grunwald on 01.08.20.
//  Copyright © 2020 Gerrit Grunwald. All rights reserved.
//

import Foundation
import SwiftUI
import os.log


extension Key {
    static let nightscoutUrl            : Key = "nightscoutUrl"
    static let nightscoutToken          : Key = "nightscoutToken"
    static let nightscoutApiSecret      : Key = "nightscoutApiSecret"
    static let nightscoutApiV2          : Key = "nightscoutApiV2"
    
    static let unitMgDl                 : Key = "unitMgDl"

    static let minCritical              : Key = "minCritical"
    static let minAcceptable            : Key = "minAcceptable"
    static let minNormal                : Key = "minNormal"
    static let maxNormal                : Key = "maxNormal"
    static let maxAcceptable            : Key = "maxAcceptable"
    static let maxCritical              : Key = "maxCritical"

    static let last2EntriesUpddate      : Key = "last2EntriesUpddate"
    static let last13EntriesUpdate      : Key = "last13EntriesUpdate"
    static let last288EntriesUpdate     : Key = "last288EntriesUpdate"
    static let last30DaysUpdate         : Key = "last30DaysUpdate"
    
    static let nightBeginOffset         : Key = "nightBeginOffset"
    static let nightEndOffset           : Key = "nightEndOffset"
}



// Define storage
public struct Properties {
    
    static var instance = Properties()
    
    @UserDefault(key: .nightscoutUrl, defaultValue: "")
    var nightscoutUrl: String?
    
    @UserDefault(key: .nightscoutToken, defaultValue: "")
    var nightscoutToken: String?
    
    @UserDefault(key: .nightscoutApiSecret, defaultValue: "")
    var nightscoutApiSecret: String?
    
    @UserDefault(key: .nightscoutApiV2, defaultValue: false)
    var nightscoutApiV2: Bool?
    
    @UserDefault(key: .unitMgDl, defaultValue: true)
    var unitMgDl: Bool?
    
    
    @UserDefault(key: .minCritical, defaultValue: Constants.DEFAULT_MIN_CRITICAL_MG_DL)
    var minCritical: Double?
    
    @UserDefault(key: .minAcceptable, defaultValue: Constants.DEFAULT_MIN_ACCEPTABLE_MG_DL)
    var minAcceptable: Double?
    
    @UserDefault(key: .minNormal, defaultValue: Constants.DEFAULT_MIN_NORMAL_MG_DL)
    var minNormal: Double?
    
    @UserDefault(key: .maxNormal, defaultValue: Constants.DEFAULT_MAX_NORMAL_MG_DL)
    var maxNormal: Double?
    
    @UserDefault(key: .maxAcceptable, defaultValue: Constants.DEFAULT_MAX_ACCEPTABLE_MG_DL)
    var maxAcceptable: Double?
    
    @UserDefault(key: .maxCritical, defaultValue: Constants.DEFAULT_MAX_CRITICAL_MG_DL)
    var maxCritical: Double?
    

    @UserDefault(key: .last2EntriesUpddate, defaultValue: 0.0)
    var last2EntriesUpddate: Double?
    
    @UserDefault(key: .last13EntriesUpdate, defaultValue: 0.0)
    var last13EntriesUpdate: Double?
    
    @UserDefault(key: .last288EntriesUpdate, defaultValue: 0.0)
    var last288EntriesUpdate: Double?
    
    @UserDefault(key: .last30DaysUpdate, defaultValue: 0.0)
    var last30DaysUpdate: Double?
    
    @UserDefault(key: .nightBeginOffset, defaultValue: 14400) // Offset in seconds from midnight: 20h -> -4h -> 14400
    var nightBeginOffset: Double?
    
    @UserDefault(key: .nightEndOffset, defaultValue: 21600) // Offset in seconds from midnight: 6H -> 21600
    var nightEndOffset: Double?

    private init() {}
}
