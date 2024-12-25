//
//  Item.swift
//  Sugr
//
//  Created by Gerrit Grunwald on 25.12.24.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
