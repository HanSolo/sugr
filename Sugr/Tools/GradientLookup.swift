//
//  GradientLookup.swift
//  Sugr
//
//  Created by Gerrit Grunwald on 26.12.24.
//

import Foundation
import SwiftUI


public struct GradientLookup {
    private var stops : [Double:Stop]
    
    
    init() {
        self.init(stops: [Double:Stop]())
    }
    init(stops: [Double:Stop]) {
        self.stops = stops
        
        if !stops.isEmpty {
            let minFraction = self.stops.map({ $0.key }).min { $0 > $1 } ?? 0.0
            let maxFraction = self.stops.map({ $0.key }).max { $0 > $1 } ?? 1.0
            if 0.0.isLess(than: minFraction) { self.stops[0.0] = self.stops[minFraction] }
            if maxFraction.isLess(than: 1.0) { self.stops[1.0] = self.stops[maxFraction] }
        }
    }
    
    
    public func getColorAt(position: Double) -> Color {
        if self.stops.isEmpty { return Color.black }
        
        let pos = Helper.clamp(min: 0.0, max: 1.0, value: position)
        let color : Color
        
        if stops.count == 1 {
            let oneEntry : [Double:Stop] = [self.stops.first!.key : self.stops.first!.value]
            color = self.stops[oneEntry.first!.key]!.color
        } else {
            var lowerBound : Stop = self.stops[0.0]!
            var upperBound : Stop = self.stops[1.0]!
            for fraction in self.stops.keys {
                if fraction.isLess(than: pos) {
                    lowerBound = self.stops[fraction]!
                }
                if pos.isLess(than: fraction) {
                    upperBound = self.stops[fraction]!
                    break
                }
            }
            color = interpolateColor(lowerBound: lowerBound, upperBound: upperBound, position: pos)
        }
        
        return color
    }
        
    public func interpolateColor(lowerBound: Stop, upperBound: Stop, position: Double) -> Color {
        let pos        = CGFloat((position - lowerBound.fraction) / (upperBound.fraction - lowerBound.fraction));

        let lbRed      = lowerBound.color.components().r ;
        let lbGreen    = lowerBound.color.components().g ;
        let lbBlue     = lowerBound.color.components().b ;
        let lbAlpha    = lowerBound.color.components().a ;
        
        let deltaRed   = (upperBound.color.components().r - lbRed)   * pos
        let deltaGreen = (upperBound.color.components().g - lbGreen) * pos
        let deltaBlue  = (upperBound.color.components().b - lbBlue)  * pos
        let deltaAlpha = (upperBound.color.components().a - lbAlpha) * pos

        let red        = Helper.clamp(min: 0.0, max: 1.0, value: lbRed   + deltaRed)
        let green      = Helper.clamp(min: 0.0, max: 1.0, value: lbGreen + deltaGreen)
        let blue       = Helper.clamp(min: 0.0, max: 1.0, value: lbBlue  + deltaBlue)
        let alpha      = Helper.clamp(min: 0.0, max: 1.0, value: lbAlpha + deltaAlpha)
                
        return Color(UIColor(red: red, green: green, blue: blue, alpha: alpha))
    }
}

public struct Stop {
    var fraction : Double {
        didSet {
            self.fraction = Helper.clamp(min: 0.0, max: 1.0, value: self.fraction)
        }
    }
    var color    : Color
}
