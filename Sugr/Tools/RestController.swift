//
//  RestController.swift
//  Sugr
//
//  Created by Gerrit Grunwald on 26.12.24.
//

import Foundation
import Network
import SwiftUI


class RestController {
    public static func isConnected() async -> Bool {
        let sessionConfig : URLSessionConfiguration = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest  = 2.0
        sessionConfig.timeoutIntervalForResource = 2.0
        
        let urlString : String      = "https://apple.com"
        let session   : URLSession  = URLSession(configuration: sessionConfig, delegate: nil, delegateQueue: .main)
        let finalUrl  : URL         = URL(string: urlString)!
        var request   : URLRequest  = URLRequest(url: finalUrl)
        request.httpMethod = "HEAD"
        do {
            let resp : (Data,URLResponse) = try await session.data(for: request)
            
            if let httpResponse = resp.1 as? HTTPURLResponse {
                return httpResponse.statusCode == 200
            } else {
                return false
            }
        } catch {
            return false
        }
    }
    
    public static func getGlucoseData(url: String, apiSecret: String, token: String, useApiV2: Bool, numberOfEntries: Int) async -> [GlucoEntry]? {
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

        //debugPrint(urlString)
        
        do {
            let resp: (Data,URLResponse) = try await session.data(for: request)
            if let httpResponse = resp.1 as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    let data   : Data = resp.0
                    var result : [GlucoEntry]?
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
                        result = try jsonDecoder.decode([GlucoEntry].self, from: data)
                    } catch {
                        print("Error parseJSONEntries (.fullISO8601 and .fullISO8601_without_Z): \(error)")
                        do {
                            let decoder = JSONDecoder()
                            decoder.dateDecodingStrategy = .millisecondsSince1970
                            result = try decoder.decode([GlucoEntry].self, from: data)
                        } catch {
                            print("Error parseJSONEntries (.millisecondsSince1970): \(error)")
                        }
                    }
                    return result
                } else {
                    debugPrint("http response status code != 200")
                    return []
                }
            } else {
                debugPrint("No valid http response")
                return []
            }
        } catch {
            debugPrint("Error calling Nightscout API. Error: \(error.localizedDescription)")
            return []
        }
    }
    
    public static func getGlucoseData(url: String, apiSecret: String, token: String, useApiV2: Bool, from: Int, numberOfEntries: Int) async -> [GlucoEntry]? {
        if url.isEmpty { return [] }
        
        let sessionConfig : URLSessionConfiguration = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest  = 30.0
        sessionConfig.timeoutIntervalForResource = 30.0
        sessionConfig.isDiscretionary            = false
     
        let urlString   : String         = "\(url)\(useApiV2 ? Constants.API_SGV_V2_JSON : Constants.API_SGV_V1_JSON)?find[date][$gte]=\(from)&count=\(numberOfEntries)\(token.isEmpty ? "" : "&token=\(token)")"
        let session     : URLSession     = URLSession(configuration: sessionConfig, delegate: nil, delegateQueue: .main)
        let finalUrl    : URL            = URL(string: urlString)!
        var request     : URLRequest     = URLRequest(url: finalUrl)
        request.addValue(apiSecret, forHTTPHeaderField: "API_SECRET")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "GET"

        //debugPrint(urlString)
        
        do {
            let resp: (Data,URLResponse) = try await session.data(for: request)
            if let httpResponse = resp.1 as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    let data   : Data = resp.0
                    var result : [GlucoEntry]?
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
                        result = try jsonDecoder.decode([GlucoEntry].self, from: data)
                    } catch {
                        print("Error parseJSONEntries (.fullISO8601 and .fullISO8601_without_Z): \(error)")
                        do {
                            let decoder = JSONDecoder()
                            decoder.dateDecodingStrategy = .millisecondsSince1970
                            result = try decoder.decode([GlucoEntry].self, from: data)
                        } catch {
                            print("Error parseJSONEntries (.millisecondsSince1970): \(error)")
                        }
                    }
                    return result
                } else {
                    debugPrint("http response status code != 200")
                    return []
                }
            } else {
                debugPrint("No valid http response")
                return []
            }
        } catch {
            debugPrint("Error calling Nightscout API. Error: \(error.localizedDescription)")
            return []
        }
    }
}
