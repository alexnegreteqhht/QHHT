//
//  Text.swift
//  QHHT-BQH
//
//  Created by Alex Negrete on 4/15/23.
//

import Foundation

struct TextHelper {
    static func cleanURLString(_ urlString: String) -> String {
        return urlString
            .replacingOccurrences(of: "http://", with: "")
            .replacingOccurrences(of: "https://", with: "")
            .replacingOccurrences(of: "www.", with: "")
    }
}
