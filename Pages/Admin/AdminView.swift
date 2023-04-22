//
//  AdminView.swift
//  QHHT-BQH
//
//  Created by Alex Negrete on 4/21/23.
//

import SwiftUI

struct AdminView: View {
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 16) {
                NavigationLink(destination: AdminPractitionerApprovalView()) {
                    Text("Practitioner Approval")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .padding(.vertical, 10)
                        .padding(.horizontal)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                
                // Add more admin features as needed

                Spacer()
            }
            .padding()
            .navigationBarTitle("Admin Panel", displayMode: .large)
        }
    }
}

struct AdminView_Previews: PreviewProvider {
    static var previews: some View {
        AdminView()
    }
}

struct AdminButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(RoundedRectangle(cornerRadius: 8)
                            .fill(Color.blue.opacity(0.1)))
            .foregroundColor(.blue)
    }
}
