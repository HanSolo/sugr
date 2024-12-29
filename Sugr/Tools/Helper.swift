//
//  Helper.swift
//  Sugr
//
//  Created by Gerrit Grunwald on 26.12.24.
//

import Foundation
import SwiftUI


public struct Helper {
    
    public static func clamp(min: Int, max: Int, value: Int) -> Int {
        if value < min { return min }
        if value > max { return max }
        return value
    }

    public static func clamp(min: Double, max: Double, value: Double) -> Double {
        if value < min { return min }
        if value > max { return max }
        return value
    }

    public static func clamp(min: CGFloat, max: CGFloat, value: CGFloat) -> CGFloat {
        if value < min { return min }
        if value > max { return max }
        return value
    }
    
    public static func roundTo(value: Double, decimals: Int) -> Double {
        if decimals < 0 { return value }
        let factor = pow(10, Double(decimals))
        return Double(round(factor * value) / factor)
    }
    
    public static func directionToArrow(direction: String) -> String {
        
        if direction == "Flat" {
            return "→"
        } else if direction == "SingleUp" {
            return "↑"
        } else if direction == "DoubleUp" {
            return "↑↑"
        } else if direction == "DoubleDown" {
            return "↓↓"
        } else if direction == "SingleDown" {
            return "↓"
        } else if direction == "FortyFiveDown" {
            return "↘"
        } else if direction == "FortyFiveUp" {
            return "↗"
        } else {
            return " "
        }
    }
        
    public static func mgToMmol(mgPerDl: Double) -> Double {
        return roundTo(value: mgPerDl * Constants.MG_PER_ML_TO_MMOL_PER_L, decimals: 3)
    }

    public static func mmolToMg(mmolPerLiter: Double) -> Double {
        return roundTo(value: mmolPerLiter * Constants.MMOL_PER_L_TO_MG_PER_ML, decimals: 0)
    }
    
    public static func secondsToHHMMString(seconds: Double) -> String {
        if seconds.isInfinite || seconds.isNaN { return "--:--" }
        let hhmmss : (Int, Int) = secondsToHHMM(seconds: seconds)
        return String(format:"%02d:%02d", hhmmss.0, hhmmss.1)
    }
    public static func secondsToHHMM(seconds: Double) -> (Int, Int) {
        if seconds.isInfinite || seconds.isNaN { return (0,0) }
        let minutes : Int = Int((seconds / 60.0).truncatingRemainder(dividingBy: 60.0))
        let hours   : Int = Int((seconds / (3600.0)).truncatingRemainder(dividingBy: 24.0))
        return ( hours, minutes )
    }
    
    public static func secondsToDDHHMMString(seconds: Double) -> String {
        if seconds.isInfinite || seconds.isNaN { return "--:--" }
        let ddhhmm : (Int, Int, Int) = secondsToDDHHMM(seconds: seconds)
        if ddhhmm.0 == 0 && ddhhmm.1 == 0 {
            return ddhhmm.2 == 0 ? "now" : String(format:"%2d min ago", ddhhmm.2)
        } else if ddhhmm.0 == 0 {
            return String(format:"%2d:%02d ago", ddhhmm.1, ddhhmm.2)
        } else {
            return String(format:"%2d:%02d:%02d ago", ddhhmm.0, ddhhmm.1, ddhhmm.2)
        }
        
    }
    public static func secondsToDDHHMM(seconds: Double) -> (Int, Int, Int) {
        if seconds.isInfinite || seconds.isNaN { return (0, 0, 0) }
        let minutes : Int = Int((seconds / 60.0).truncatingRemainder(dividingBy: 60.0))
        let hours   : Int = Int((seconds / (3_600.0)).truncatingRemainder(dividingBy: 24.0))
        let days    : Int = Int((seconds / (86_400.0)))
        return ( days, hours, minutes )
    }
    
    public static func secondsToHHMMSSString(seconds: Double) -> String {
        if seconds.isInfinite || seconds.isNaN { return "--:--:--"}
        let hhmmss : (Int, Int, Int) = secondsToHHMMSS(seconds: seconds)
        return String(format:"%02d:%02d:%02d", hhmmss.0, hhmmss.1, hhmmss.2)
    }
    public static func secondsToHHMMSS(seconds: Double) -> (Int, Int, Int) {
        if seconds.isInfinite || seconds.isNaN { return (0, 0, 0) }
        let secs    : Int = Int(seconds.truncatingRemainder(dividingBy: 60))
        let minutes : Int = Int((seconds / 60.0).truncatingRemainder(dividingBy: 60.0))
        let hours   : Int = Int((seconds / (3600.0)).truncatingRemainder(dividingBy: 24.0))
        return ( hours, minutes, secs )
    }
    
    public static func getColorForValue(value : Double) -> Color {
        let minCritical   = Properties.instance.minCritical!.rounded()
        let minAcceptable = Properties.instance.minAcceptable!.rounded()
        let minNormal     = Properties.instance.minNormal!.rounded()
        let maxNormal     = Properties.instance.maxNormal!.rounded()
        let maxAcceptable = Properties.instance.maxAcceptable!.rounded()
        let maxCritical   = Properties.instance.maxCritical!.rounded()
                       
        switch value {
            case 0 ..< minCritical                                : return Constants.RED
            case minCritical   ..< minAcceptable                  : return Constants.ORANGE
            case minAcceptable ..< minNormal                      : return Constants.YELLOW
            case minNormal     ..< maxNormal                      : return Constants.GREEN
            case maxNormal     ..< maxAcceptable                  : return Constants.YELLOW
            case maxAcceptable ..< maxCritical                    : return Constants.ORANGE
            case maxCritical   ..< Double.greatestFiniteMagnitude : return Constants.RED
            default                                               : return Color.white
        }
    }
    
    public static func getGCColorForValue(value : Double) -> GraphicsContext.Shading {
        let minCritical   = Properties.instance.minCritical!.rounded()
        let minAcceptable = Properties.instance.minAcceptable!.rounded()
        let minNormal     = Properties.instance.minNormal!.rounded()
        let maxNormal     = Properties.instance.maxNormal!.rounded()
        let maxAcceptable = Properties.instance.maxAcceptable!.rounded()
        let maxCritical   = Properties.instance.maxCritical!.rounded()
                       
        switch value {
            case 0 ..< minCritical                                : return Constants.GC_RED
            case minCritical   ..< minAcceptable                  : return Constants.GC_ORANGE
            case minAcceptable ..< minNormal                      : return Constants.GC_YELLOW
            case minNormal     ..< maxNormal                      : return Constants.GC_GREEN
            case maxNormal     ..< maxAcceptable                  : return Constants.GC_YELLOW
            case maxAcceptable ..< maxCritical                    : return Constants.GC_ORANGE
            case maxCritical   ..< Double.greatestFiniteMagnitude : return Constants.GC_RED
            default                                               : return Constants.GC_GRAY
        }
    }
        
    public static func getColorForValue2(value : Double) -> Constants.GlucoseColor {
        let minCritical   = Properties.instance.minCritical!.rounded()
        let minAcceptable = Properties.instance.minAcceptable!.rounded()
        let minNormal     = Properties.instance.minNormal!.rounded()
        let maxNormal     = Properties.instance.maxNormal!.rounded()
        let maxAcceptable = Properties.instance.maxAcceptable!.rounded()
        let maxCritical   = Properties.instance.maxCritical!.rounded()
                       
        switch value {
            case 0 ..< minCritical                                : return Constants.GlucoseColor.BLUE
            case minCritical   ..< minAcceptable                  : return Constants.GlucoseColor.LIGHT_BLUE
            case minAcceptable ..< minNormal                      : return Constants.GlucoseColor.DARK_GREEN
            case minNormal     ..< maxNormal                      : return Constants.GlucoseColor.GREEN
            case maxNormal     ..< maxAcceptable                  : return Constants.GlucoseColor.YELLOW
            case maxAcceptable ..< maxCritical                    : return Constants.GlucoseColor.ORANGE
            case maxCritical   ..< Double.greatestFiniteMagnitude : return Constants.GlucoseColor.RED
            default                                               : return Constants.GlucoseColor.RED
        }
    }
    
    public static func entriesToUserDefaults(entries: [GlucoEntry]) -> Void {
        let encoder : JSONEncoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        do {
            let jsonData = try encoder.encode(entries)
            UserDefaults(suiteName: "group.eu.hansolo.Sugr")!.set(jsonData, forKey: Constants.LAST_TWO_ENTRIES_KEY_UD)
            debugPrint("Saved entries to user defaults")
        } catch {
            debugPrint("Error encode json entries and save to user defaults")
        }
    }
    public static func entriesFromUserDefaults() -> [GlucoEntry] {
        let decoder : JSONDecoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        var entries : [GlucoEntry] = []
        let encodedData = UserDefaults(suiteName: "group.eu.hansolo.Sugr")!.object(forKey: Constants.LAST_TWO_ENTRIES_KEY_UD) as? Data
        if let jsonEncoded = encodedData {
            do {
                try decoder.decode([GlucoEntry].self, from: jsonEncoded).forEach { entries.append($0) }
                debugPrint("Decoded json entries from user defaults")
            } catch {
                debugPrint("Error decoding json entries from user defaults")
            }
        }
        return entries
    }
}
