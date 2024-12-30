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
    
    static let date                     : Key = "date"
    static let value                    : Key = "value"
    static let lastDate                 : Key = "lastDate"
    static let lastValue                : Key = "lastValue"
    static let delta                    : Key = "delta"
    static let direction                : Key = "direction"
    
    static let last2DaysUpddate         : Key = "last2DaysUpddate"
    static let last13DaysUpdate         : Key = "last13DaysUpdate"
    static let last30DaysUpdate         : Key = "last30DaysUpdate"
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
    
    
    @UserDefault(key: .date, defaultValue: 0.0)
    var date: Double?
    
    @UserDefault(key: .value, defaultValue: 0.0)
    var value: Double?
    
    @UserDefault(key: .lastDate, defaultValue: 0.0)
    var lastDate: Double?
    
    @UserDefault(key: .lastValue, defaultValue: 0.0)
    var lastValue: Double?
    
    @UserDefault(key: .delta, defaultValue: 0.0)
    var delta: Double?
    
    @UserDefault(key: .direction, defaultValue: "")
    var direction: String?
    
    
    @UserDefault(key: .last2DaysUpddate, defaultValue: 0.0)
    var last2DaysUpddate: Double?
    
    @UserDefault(key: .last13DaysUpdate, defaultValue: 0.0)
    var last13DaysUpdate: Double?
    
    @UserDefault(key: .last30DaysUpdate, defaultValue: 0.0)
    var last30DaysUpdate: Double?

    private init() {}
}
