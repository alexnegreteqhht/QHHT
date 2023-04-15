//
//  Security.swift
//  QHHT-BQH
//
//  Created by Alex Negrete on 4/15/23.
//

import Foundation

struct Security {
    static func generateRandomNonce(length: Int) -> String {
        let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        
        while remainingLength > 0 {
            let randomValues = (0 ..< remainingLength).map { _ in UInt8.random(in: 0 ... 255) }
            randomValues.forEach { value in
                if remainingLength == 0 {
                    return
                }
                if value < charset.count {
                    result.append(charset[Int(value)])
                    remainingLength -= 1
                }
            }
        }
        return result
    }
}
