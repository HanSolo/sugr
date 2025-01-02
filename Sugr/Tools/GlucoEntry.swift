//
//  GlucoEntry.swift
//  Sugr
//
//  Created by Gerrit Grunwald on 26.12.24.
//

import Foundation

public struct GlucoEntry: Codable, Equatable, Sendable {
    let _id         : String
    let sgv         : Double
    let datelong    : Double
    let date        : Double
    let dateString  : String
    let trend       : MetadataType
    let direction   : String
    let device      : String
    let type        : String
    let utcOffset   : Int64

    let noise       : Int64
    let filtered    : Double
    let unfiltered  : Double
    let rssi        : Int64
    let delta       : Double
    let sysTime     : String
    let mills       : Double
    
    public static func == (lhs: GlucoEntry, rhs: GlucoEntry) -> Bool {
        return lhs._id == rhs._id
    }
}

extension GlucoEntry {
    enum CodingKeys: String, CodingKey {
        case _id        = "_id"
        case sgv        = "sgv"
        case datelong   = "date"
        case dateString = "dateString"
        case trend      = "trend"
        case direction  = "direction"
        case device     = "device"
        case type       = "type"
        case utcOffset  = "utcOffset"
        case noise      = "noise"
        case filtered   = "filtered"
        case unfiltered = "unfiltered"
        case rssi       = "rssi"
        case delta      = "delta"
        case sysTime    = "sysTime"
        case mills      = "mills"
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self._id         = try container.decode(String.self, forKey: ._id)
        self.sgv         = container.contains(.sgv)        ? try container.decode(Double.self, forKey: .sgv)         : 0
        self.datelong    = container.contains(.datelong)   ? try container.decode(Double.self, forKey: .datelong)    : Date.init().timeIntervalSince1970
        self.date        = datelong / 1000
        self.dateString  = container.contains(.dateString) ? try container.decode(String.self, forKey: .dateString)  : ""
        self.trend       = container.contains(.trend)      ? try container.decode(MetadataType.self, forKey: .trend) : MetadataType.int(0)
        self.direction   = self.trend.isString()           ? container.contains(.trend) ? try container.decode(String.self, forKey: .trend) : "" : container.contains(.direction) ? try container.decode(String.self, forKey: .direction) : ""
        self.device      = container.contains(.device)     ? try container.decode(String.self, forKey: .device)      : ""
        self.type        = container.contains(.type)       ? try container.decode(String.self, forKey: .type)        : ""
        self.utcOffset   = container.contains(.utcOffset)  ? try container.decode(Int64.self,  forKey: .utcOffset)   : 0
        self.noise       = container.contains(.noise)      ? try container.decode(Int64.self,  forKey: .noise)       : 0
        self.filtered    = container.contains(.filtered)   ? try container.decode(Double.self, forKey: .filtered)    : 0
        self.unfiltered  = container.contains(.unfiltered) ? try container.decode(Double.self, forKey: .unfiltered)  : 0
        self.rssi        = container.contains(.rssi)       ? try container.decode(Int64.self,  forKey: .rssi)        : 0
        self.delta       = container.contains(.delta)      ? try container.decode(Double.self, forKey: .delta)       : 0
        self.sysTime     = container.contains(.sysTime)    ? try container.decode(String.self, forKey: .sysTime)     : ""
        self.mills       = container.contains(.mills)      ? try container.decode(Double.self, forKey: .mills)       : self.datelong
    }
    
    public init(entry: GlucoEntry) {
        self._id         = entry._id
        self.sgv         = entry.sgv
        self.datelong    = entry.date
        self.date        = datelong / 1000
        self.dateString  = entry.dateString
        self.trend       = entry.trend
        self.direction   = entry.direction
        self.device      = entry.device
        self.type        = entry.type
        self.utcOffset   = entry.utcOffset
        self.noise       = entry.noise
        self.filtered    = entry.filtered
        self.unfiltered  = entry.unfiltered
        self.rssi        = entry.rssi
        self.delta       = entry.delta
        self.sysTime     = entry.sysTime
        self.mills       = entry.mills
    }
    
    init(_id: String, sgv: Double, datelong: Double, dateString: String, trend: MetadataType, direction: String, device: String, type: String, utcOffset: Int, noise: Int, filtered: Double, unfiltered: Double, rssi: Int, delta: Double, sysTime: String, mills: Double) {
        self._id        = _id
        self.sgv        = sgv
        self.datelong   = datelong
        self.date       = datelong / 1000
        self.dateString = dateString
        self.trend      = trend
        self.direction  = direction
        self.device     = device
        self.type       = type
        self.utcOffset  = Int64(utcOffset)
        self.noise      = Int64(noise)
        self.filtered   = filtered
        self.unfiltered = unfiltered
        self.rssi       = Int64(rssi)
        self.delta      = delta
        self.sysTime    = sysTime
        self.mills      = mills
    }
    
    init(_id: String, sgv: Double, datelong: Double, dateString: String, trend: Int, direction: String, device: String, type: String, utcOffset: Int, noise: Int, filtered: Double, unfiltered: Double, rssi: Int, delta: Double, sysTime: String, mills: Double) {
        self.init(_id: _id, sgv: sgv, datelong: datelong, dateString: dateString, trend: MetadataType.int(trend), direction: direction, device: device, type: type, utcOffset: utcOffset, noise: noise, filtered: filtered, unfiltered: unfiltered, rssi: rssi, delta: delta, sysTime: sysTime, mills: mills)
    }
}

public struct GlucoEntryData: Codable {
    var _id        : String?
    var sgv        : Double?
    var date       : Double?
    var dateCorrect: Int64?
    var dateString : String?
    var trend      : Int64?
    var direction  : String?
    var device     : String?
    var type       : String?
    var utcOffset  : Int64?
    var noise      : Int64?
    var filtered   : Double?
    var unfiltered : Double?
    var rssi       : Int64?
    var delta      : Double?
    var sysTime    : String?
    var mills      : Double?
}


enum MetadataType: Codable {
    case int(Int)
    case string(String)
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        do {
            self = try .int(container.decode(Int.self))
        } catch DecodingError.typeMismatch {
            do {
                self = try .string(container.decode(String.self))
            } catch DecodingError.typeMismatch {
                throw DecodingError.typeMismatch(MetadataType.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Encoded payload not of an expected type"))
            }
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .int(let int):
            try container.encode(int)
        case .string(let string):
            try container.encode(string)
        }
    }
    
    func isString() -> Bool {
        switch self {
        case .int(_):
            return false
        case .string(_):
            return true;
        }
    }
    
    func toInt() -> Int {
        switch self {
        case .int(let int):
            return int
        case .string(let string):
            switch string {
                case "Flat"          : return 0
                case "SingleUp"      : return 1
                case "DoubleUp"      : return 2
                case "DoubleDown"    : return 3
                case "SingleDown"    : return 4
                case "FortyFiveDown" : return 5
                case "FortyFiveUp"   : return 6
                default              : return 0
            }
        }
    }
}
