//
//  Constants.swift
//  Sugr
//
//  Created by Gerrit Grunwald on 25.12.24.
//

import Foundation
import SwiftUI


public class Constants {
    public static let APP_NAME                            : String = "Sugr"
    public static let APP_GROUP_ID                        : String = "group.eu.hansolo.Sugr"
    public static let APP_REFRESH_ID                      : String = "eu.hansolo.Sugr.refresh"
    public static let APP_REFRESH_INTERVAL                : Double = 1800 // refresh app every 30 minutes in background
    public static let OUTDATED_DURATION                   : Double = 420  // seconds before the attention sign will popup up
    public static let UPDATE_INTERVAL                     : Double = 150  // seconds before next entries will be fetched
    public static let CANVAS_REFRESH_INTERVAL             : Double = 1
    public static let WIDGET_KIND                         : String = "eu.hansolo.Sugr.widget"
    
    public static let LAST_TWO_ENTRIES_KEY_UD             : String = "lastTwoEntries"

    public static let DTF_MG_DL                           : String = "d.M.yy HH:MM"
    public static let DTF_MMOL_L                          : String = "M/d/yy hh:mma"
    
    public static let DF_MG_DL                            : String = "dd.MM.yyyy, HH:mm"
    public static let TF_MG_DL_SHORT                      : String = "H:mm"
    public static let DF_MMOL_L                           : String = "MM/dd/yyyy, hh:mma"
    public static let TF_MMOL_L_SHORT                     : String = "h:mm"
    
    public static let API_SGV_V2_JSON                     : String = "/api/v2/entries/sgv.json"
    public static let API_SGV_V1_JSON                     : String = "/api/v1/entries/sgv.json"
    
    public static let SECONDS_PER_DAY                     : Double = 86400
    public static let VALUES_PER_24_HOURS                 : Int    = 288
    public static let VALUES_PER_30_DAYS                  : Int    = 8640
    
    public static let MG_PER_ML_TO_MMOL_PER_L             : Double =  0.0555000000001  // FActor to convert mg/dl  -> mmol/l
    public static let MMOL_PER_L_TO_MG_PER_ML             : Double = 18.0180180179856  // Factor to convert mmol/l -> mg/dl
    
    public static let DEFAULT_MIN_VALUE_MG_DL             : Double =   0.0
    public static let DEFAULT_MAX_VALUE_MG_DL             : Double = 400.0
    public static let DEFAULT_MIN_CRITICAL_MG_DL          : Double =  55.0
    public static let DEFAULT_MIN_ACCEPTABLE_MG_DL        : Double =  65.0
    public static let DEFAULT_MIN_NORMAL_MG_DL            : Double =  70.0
    public static let DEFAULT_MAX_NORMAL_MG_DL            : Double = 140.0
    public static let DEFAULT_MAX_ACCEPTABLE_MG_DL        : Double = 180.0
    public static let DEFAULT_MAX_CRITICAL_MG_DL          : Double = 350.0
    public static let DEFAULT_GLUCO_RANGE_MG_DL           : Double = DEFAULT_MAX_VALUE_MG_DL - DEFAULT_MIN_VALUE_MG_DL
    public static let DEFAULT_MIN_CRITICAL_FACTOR_MG_DL   : Double = 1.0 - DEFAULT_MIN_CRITICAL_MG_DL   / DEFAULT_GLUCO_RANGE_MG_DL
    public static let DEFAULT_MIN_ACCEPTABLE_FACTOR_MG_DL : Double = 1.0 - DEFAULT_MIN_ACCEPTABLE_MG_DL / DEFAULT_GLUCO_RANGE_MG_DL
    public static let DEFAULT_MIN_NORMAL_FACTOR_MG_DL     : Double = 1.0 - DEFAULT_MIN_NORMAL_MG_DL     / DEFAULT_GLUCO_RANGE_MG_DL
    public static let DEFAULT_MAX_NORMAL_FACTOR_MG_DL     : Double = 1.0 - DEFAULT_MAX_NORMAL_MG_DL     / DEFAULT_GLUCO_RANGE_MG_DL
    public static let DEFAULT_MAX_ACCEPTABLE_FACTOR_MG_DL : Double = 1.0 - DEFAULT_MAX_ACCEPTABLE_MG_DL / DEFAULT_GLUCO_RANGE_MG_DL
    public static let DEFAULT_MAX_CRITICAL_FACTOR_MG_DL   : Double = 1.0 - DEFAULT_MAX_CRITICAL_MG_DL   / DEFAULT_GLUCO_RANGE_MG_DL
    
    public static let DARK_GRAY                           : Color  = Color(red: 0.156, green: 0.137, blue: 0.149, opacity: 1.00)
    public static let BLACK                               : Color  = Color.black
    public static let WHITE                               : Color  = Color.white
    public static let GRAY                                : Color  = Color.gray
    public static let RED                                 : Color  = Color(red: 0.96, green: 0.12, blue: 0.14, opacity: 1.00)
    public static let ORANGE                              : Color  = Color(red: 1.00, green: 0.47, blue: 0.00, opacity: 1.00)
    public static let YELLOW                              : Color  = Color(red: 1.00, green: 0.72, blue: 0.00, opacity: 1.00)
    public static let GREEN                               : Color  = Color(red: 0.177, green: 0.76, blue: 0.0, opacity: 1.00)
    public static let DARK_GREEN                          : Color  = Color(red: 0.00, green: 0.50, blue: 0.13, opacity: 1.00)
    public static let LIGHT_BLUE                          : Color  = Color(red: 0.01, green: 0.60, blue: 0.93, opacity: 1.00)
    public static let BLUE                                : Color  = Color(red: 0.00, green: 0.43, blue: 1.00, opacity: 1.00)
        
    public static let GC_DARK_GRAY                        : GraphicsContext.Shading = GraphicsContext.Shading.color(DARK_GRAY)
    public static let GC_BLACK                            : GraphicsContext.Shading = GraphicsContext.Shading.color(BLACK)
    public static let GC_WHITE                            : GraphicsContext.Shading = GraphicsContext.Shading.color(WHITE)
    public static let GC_GRAY                             : GraphicsContext.Shading = GraphicsContext.Shading.color(GRAY)
    public static let GC_RED                              : GraphicsContext.Shading = GraphicsContext.Shading.color(RED)
    public static let GC_ORANGE                           : GraphicsContext.Shading = GraphicsContext.Shading.color(ORANGE)
    public static let GC_YELLOW                           : GraphicsContext.Shading = GraphicsContext.Shading.color(YELLOW)
    public static let GC_GREEN                            : GraphicsContext.Shading = GraphicsContext.Shading.color(GREEN)
    public static let GC_DARK_GREEN                       : GraphicsContext.Shading = GraphicsContext.Shading.color(DARK_GREEN)
    public static let GC_LIGHT_BLUE                       : GraphicsContext.Shading = GraphicsContext.Shading.color(LIGHT_BLUE)
    public static let GC_BLUE                             : GraphicsContext.Shading = GraphicsContext.Shading.color(BLUE)
    public static let GC_NIGHT_DARK                       : GraphicsContext.Shading = GraphicsContext.Shading.color(Color(red: 0.122, green: 0.110, blue: 0.120, opacity: 1.0))
    public static let GC_NIGHT_BRIGHT                     : GraphicsContext.Shading = GraphicsContext.Shading.color(.gray.opacity(0.15))
    
    public static let GC_GREEN_AREA_COLOR                 : GraphicsContext.Shading = GraphicsContext.Shading.color(Color(red: 0.177, green: 0.76, blue: 0.0, opacity: 0.2))
    
    public static let WEEKDAYS                            : [String] = ["S", "M", "T", "W", "T", "F", "S"]
    
    public static let STOPS                               : [Gradient.Stop] = [
        Gradient.Stop(color: RED,    location: 0.0),
        Gradient.Stop(color: RED,    location: 0.1375),
        Gradient.Stop(color: YELLOW, location: 0.15625),
        Gradient.Stop(color: GREEN,  location: 0.175),
        Gradient.Stop(color: GREEN,  location: 0.35),
        Gradient.Stop(color: YELLOW, location: 0.4),
        Gradient.Stop(color: ORANGE, location: 0.5375),
        Gradient.Stop(color: ORANGE, location: 0.625),
        Gradient.Stop(color: RED,    location: 1.0)
    ]
        
    
    public enum Direction: String, Equatable, CaseIterable, Sendable {
        case FLAT
        case SINGLE_UP
        case DOUBLE_UP
        case DOUBLE_DOWN
        case SINGLE_DOWN
        case FORTY_FIVE_UP
        case FORTY_FIVE_DOWN
        case NONE
        
        var name: String {
            switch self {
            case .FLAT            : return "Flat"
            case .SINGLE_UP       : return "SingleUp"
            case .DOUBLE_UP       : return "DoubleUp"
            case .DOUBLE_DOWN     : return "DoubleDown"
            case .SINGLE_DOWN     : return "SingleDown"
            case .FORTY_FIVE_DOWN : return "FortyFiveDown"
            case .FORTY_FIVE_UP   : return "FortyFiveUp"
            case .NONE            : return ""
            }
        }
        
        var arrow: String {
            switch self {
            case .FLAT            : return "→"
            case .SINGLE_UP       : return "↑"
            case .DOUBLE_UP       : return "↑↑"
            case .DOUBLE_DOWN     : return "↓↓"
            case .SINGLE_DOWN     : return "↓"
            case .FORTY_FIVE_DOWN : return "↘"
            case .FORTY_FIVE_UP   : return "↗"
            case .NONE            : return ""
            }
        }
        
        public static func fromText(text: String) -> Direction {
            switch (text) {
            case "Flat"          : return .FLAT
            case "SingleUp"      : return .SINGLE_UP
            case "DoubleUp"      : return .DOUBLE_UP
            case "DoubleDown"    : return .DOUBLE_DOWN
            case "SingleDown"    : return .SINGLE_DOWN
            case "FortyFiveDown" : return .FORTY_FIVE_DOWN
            case "FortyFiveUp"   : return .FORTY_FIVE_UP
            default              : return .NONE
            }
        }
    }
    
    public enum Interval: String, Equatable, CaseIterable, Sendable {
        case LAST_720_HOURS
        case LAST_336_HOURS
        case LAST_168_HOURS
        case LAST_72_HOURS
        case LAST_48_HOURS
        case LAST_24_HOURS
        case LAST_12_HOURS
        case LAST_6_HOURS
        case LAST_3_HOURS
        
        var id: Int {
            switch self {
            case .LAST_720_HOURS : return 8
            case .LAST_336_HOURS : return 7
            case .LAST_168_HOURS : return 6
            case .LAST_72_HOURS  : return 5
            case .LAST_48_HOURS  : return 4
            case .LAST_24_HOURS  : return 3
            case .LAST_12_HOURS  : return 2
            case .LAST_6_HOURS   : return 1
            case .LAST_3_HOURS   : return 0
            }
        }
        
        var noOfEntries: Int {
            switch self {
            case .LAST_720_HOURS : return 8640
            case .LAST_336_HOURS : return 4032
            case .LAST_168_HOURS : return 2016
            case .LAST_72_HOURS  : return 864
            case .LAST_48_HOURS  : return 576
            case .LAST_24_HOURS  : return 288
            case .LAST_12_HOURS  : return 144
            case .LAST_6_HOURS   : return 72
            case .LAST_3_HOURS   : return 36
            }
        }
        
        var days: Int {
            switch self {
            case .LAST_720_HOURS: return 30
            case .LAST_336_HOURS: return 14
            case .LAST_168_HOURS: return 7
            case .LAST_72_HOURS : return 3
            case .LAST_48_HOURS : return 2
            case .LAST_24_HOURS : return 1
            case .LAST_12_HOURS : return 1
            case .LAST_6_HOURS  : return 1
            case .LAST_3_HOURS  : return 1
            }
        }
        var hours: TimeInterval {
            switch self {
            case .LAST_720_HOURS : return 720
            case .LAST_336_HOURS : return 336
            case .LAST_168_HOURS : return 168
            case .LAST_72_HOURS  : return 72
            case .LAST_48_HOURS  : return 48
            case .LAST_24_HOURS  : return 24
            case .LAST_12_HOURS  : return 12
            case .LAST_6_HOURS   : return 6
            case .LAST_3_HOURS   : return 3
            }
        }
        var seconds: TimeInterval {
            switch self {
            case .LAST_720_HOURS : return 2592000
            case .LAST_336_HOURS : return 1209600
            case .LAST_168_HOURS : return 604800
            case .LAST_72_HOURS  : return 259200
            case .LAST_48_HOURS  : return 172800
            case .LAST_24_HOURS  : return 86400
            case .LAST_12_HOURS  : return 43200
            case .LAST_6_HOURS   : return 21600
            case .LAST_3_HOURS   : return 10800
            }
        }
        var tickLabelDistance : Int {
            switch self {
            case .LAST_720_HOURS : return 30
            case .LAST_336_HOURS : return 30
            case .LAST_168_HOURS : return 30
            case .LAST_72_HOURS  : return 30
            case .LAST_48_HOURS  : return 30
            case .LAST_24_HOURS  : return 30
            case .LAST_12_HOURS  : return 20
            case .LAST_6_HOURS   : return 10
            case .LAST_3_HOURS   : return 5
            }
        }
        var text : String {
            switch self {
            case .LAST_720_HOURS : return "30 Days"
            case .LAST_336_HOURS : return "14 Days"
            case .LAST_168_HOURS : return "7 Days"
            case .LAST_72_HOURS  : return "3 Days"
            case .LAST_48_HOURS  : return "48 Hours"
            case .LAST_24_HOURS  : return "24 Hours"
            case .LAST_12_HOURS  : return "12 Hours"
            case .LAST_6_HOURS   : return "6 Hours"
            case .LAST_3_HOURS   : return "3 Hours"
            }
        }
    }
    
    public enum GlucoseColor: String, Equatable, CaseIterable {
        case RED
        case ORANGE
        case YELLOW
        case GREEN
        case DARK_GREEN
        case LIGHT_BLUE
        case BLUE
        
        var id: Int {
            switch self {
                case .RED        : return 6
                case .ORANGE     : return 5
                case .YELLOW     : return 4
                case .GREEN      : return 3
                case .DARK_GREEN : return 2
                case .LIGHT_BLUE : return 1
                case .BLUE       : return 0
            }
        }
        
        var color: Color {
            switch self {
                case .RED        : return Color(red: 0.94, green: 0.11, blue: 0.13, opacity: 1.00)
                case .ORANGE     : return Color(red: 0.93, green: 0.43, blue: 0.00, opacity: 1.00)
                case .YELLOW     : return Color(red: 1.00, green: 0.74, blue: 0.01, opacity: 1.00)
                case .GREEN      : return Color(red: 0.57, green: 0.79, blue: 0.23, opacity: 1.00)
                case .DARK_GREEN : return Color(red: 0.00, green: 0.50, blue: 0.13, opacity: 1.00)
                case .LIGHT_BLUE : return Color(red: 0.01, green: 0.60, blue: 0.93, opacity: 1.00)
                case .BLUE       : return Color(red: 0.00, green: 0.43, blue: 1.00, opacity: 1.00)
            }
        }
        
        var name: String {
            switch self {
                case .RED        : return "RED"
                case .ORANGE     : return "ORANGE"
                case .YELLOW     : return "YELLOW"
                case .GREEN      : return "GREEN"
                case .DARK_GREEN : return "DARK_GREEN"
                case .LIGHT_BLUE : return "LIGHT_BLUE"
                case .BLUE       : return "BLUE"
            }
        }
        
        public static func fromText(text: String) -> GlucoseColor {
            switch (text) {
            case "RED"        : return RED
            case "ORANGE"     : return ORANGE
            case "YELLOW"     : return YELLOW
            case "GREEN"      : return GREEN
            case "DARK_GREEN" : return DARK_GREEN
            case "LIGHT_BLUE" : return LIGHT_BLUE
            case "BLUE"       : return BLUE
            default           : return RED
            }
        }
    }
}
