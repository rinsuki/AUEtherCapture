//
//  File.swift
//  
//
//  Created by user on 2021/03/06.
//

#if os(Windows)
import WinSDK
func sleep(_ seconds: UInt32) {
    // Win32 Sleep is milliseconds, *NIX sleep is seconds
    Sleep(seconds * 1000)
}
#endif
