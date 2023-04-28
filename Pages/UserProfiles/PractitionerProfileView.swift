//
//  PractitionerProfileView.swift
//  QHHT-BQH
//
//  Created by Alex Negrete on 4/27/23.
//

import Foundation
import SwiftUI

struct PractitionerProfileView: View {
    var practitioner: UserProfile

    var body: some View {
        Text("User profile for \(practitioner.name)")
    }
}
