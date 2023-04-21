//
//  AdminView.swift
//  QHHT-BQH
//
//  Created by Alex Negrete on 4/21/23.
//

import Foundation
import SwiftUI

struct AdminView: View {
    var body: some View {
        VStack {
            Text("Admin Panel")
                .font(.largeTitle)
                .padding(.bottom)

            AdminPractitionerApprovalView()
        }
    }
}
