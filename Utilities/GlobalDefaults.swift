//
//  GlobalDefaults.swift
//  QHHT-BQH
//
//  Created by Alex Negrete on 4/15/23.
//

import Foundation
import SwiftUI

struct GlobalDefaults {
    static let dateFormatter: DateFormatter = {
           let formatter = DateFormatter()
           formatter.dateStyle = .medium
           formatter.timeStyle = .none
           return formatter
        
    }()
    
    static func dateStringToDate(dateString: String) -> Date {
        if let date = GlobalDefaults.dateFormatter.date(from: dateString) {
            return date
        } else {
            return Date()
        }
    }
}
