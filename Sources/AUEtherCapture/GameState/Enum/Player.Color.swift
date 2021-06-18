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
        case maroon
        case rose
        case banana
        case lightGrey
        case tan
        case coral
        case unknown
        
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
            case .maroon:
                return "Maroon"
            case .rose:
                return "Rose"
            case .banana:
                return "Banana"
            case .lightGrey:
                return "LightGrey"
            case .tan:
                return "Tan"
            case .coral:
                return "Coral"
            case .unknown:
                return "Unknown"
            }
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            try container.encode(self.key)
        }
        
        func discordEmoji(dead: Bool) -> String {
            switch self {
            case .red:
                return dead ? "<:aureddead:762397192362393640>" : "<:aured:762392085768175646>"
            case .blue:
                return dead ? "<:aubluedead:762397192349679616>" : "<:aublue:762392085629632512>"
            case .green:
                return dead ? "<:augreendead:762397192060272724>" : "<:augreen:762392085889417226>"
            case .pink:
                return dead ? "<:aupinkdead:762397192643805194>" : "<:aupink:762392085726363648>"
            case .orange:
                return dead ? "<:auorangedead:762397192333819904>" : "<:auorange:762392085264728095>"
            case .yellow:
                return dead ? "<:auyellowdead:762397192425046016>" : "<:auyellow:762392085541158923>"
            case .grey:
                return dead ? "<:aublackdead:762397192291090462>" : "<:aublack:762392086493790249>"
            case .white:
                return dead ? "<:auwhitedead:762397192409186344>" : "<:auwhite:762392085990866974>"
            case .purple:
                return dead ? "<:aupurpledead:762397192404860958>" : "<:aupurple:762392085973303376>"
            case .brown:
                return dead ? "<:aubrowndead:762397192102739989>" : "<:aubrown:762392086023634986>"
            case .cyan:
                return dead ? "<:aucyandead:762397192307867698>" : "<:aucyan:762392087945281557>"
            case .lightGreen:
                return dead ? "<:aulimedead:762397192366325793>" : "<:aulime:762392088121442334>"
            case .maroon:
                return dead ? "<:aumaroondead:855108016890576906>" : "<:aumaroon:855108016881008670>"
            case .rose:
                return dead ? "<:aurosedead:855108016817700936>" : "<:aurose:855108016734732329>"
            case .banana:
                return dead ? "<:aubananadead:855108016746266644>" : "<:aubanana:855108016420552736>"
            case .lightGrey:
                return dead ? "<:augraydead:855108016898048020>" : "<:augray:855108016801054760>"
            case .tan:
                return dead ? "<:autandead:855108017007886356>" : "<:autan:855108016546250753>"
            case .coral:
                // AutoMuteUs uses Sunset instead of Coral (maybe mistake?)
                return dead ? "<:ausunsetdead:855108017096097802>" : "<:ausunset:855108016466821151>"
            case .unknown:
                return dead ? "🤔(dead)" : "🤔"
            }
        }
    }
}
