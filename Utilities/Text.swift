//
//  Text.swift
//  QHHT-BQH
//
//  Created by Alex Negrete on 4/15/23.
//

import Foundation
import SwiftUI

struct TextHelper {
    static func cleanURLString(_ urlString: String) -> String {
        return urlString
            .replacingOccurrences(of: "http://", with: "")
            .replacingOccurrences(of: "https://", with: "")
            .replacingOccurrences(of: "www.", with: "")
    }
}

struct Validator {
    static func validateStringLength(_ string: inout String, maxLength: Int) -> Bool {
        if string.count > maxLength {
            string = String(string.prefix(maxLength))
            return true
        }
        return false
    }
}
