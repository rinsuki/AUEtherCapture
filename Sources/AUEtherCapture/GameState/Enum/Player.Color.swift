//
//  File.swift
//  
//
//  Created by user on 2021/03/02.
//

import Foundation

extension Player {
    enum Color: UInt8, Encodable {
        case red = 0
        case blue
        case green
        case pink
        case orange
        case yellow
        case grey
        case white
        case purple
        case brown
        case cyan
        case lightGreen
        
        var key: String {
            switch self {
            case .red:
                return "Red"
            case .blue:
                return "Blue"
            case .green:
                return "Green"
            case .pink:
                return "Pink"
            case .orange:
                return "Orange"
            case .yellow:
                return "Yellow"
            case .grey:
                return "Grey"
            case .white:
                return "White"
            case .purple:
                return "Purple"
            case .brown:
                return "Brown"
            case .cyan:
                return "Cyan"
            case .lightGreen:
                return "LightGreen"
            }
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            try container.encode(self.key)
        }
    }
}
