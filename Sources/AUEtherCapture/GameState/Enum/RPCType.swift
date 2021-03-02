//
//  File.swift
//  
//
//  Created by user on 2021/03/02.
//

import Foundation

enum RPCType: UInt8 {
    case playAnimation = 0x00
    case completeTask = 0x01
    case syncSettings = 0x02
    case setInfected = 0x03
    case setName = 0x06
    case setColor = 0x08
    case murderPlayer = 0x0C
    case sendChat = 0x0D
    case startMeeting = 0x0E
    case sendChatNote = 0x10
    case setStartCounter = 0x12
    case enterVent = 0x13
    case exitVent = 0x14
    case snapTo = 0x15
    case votingComplete = 0x17
    case updateGameData = 0x1e
}
