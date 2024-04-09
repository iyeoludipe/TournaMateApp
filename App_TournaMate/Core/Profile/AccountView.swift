import SwiftUI

struct AccountView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack {
            Text("Account Management")
                .font(.title)
                .padding()
            
            // Implement your account management UI and functionality here
            
            
            Button(action: {
                // Call signOut method
                viewModel.signOut()
                
                // Dismiss the AccountView
                presentationMode.wrappedValue.dismiss()
            }) {
                Text("Sign Out")
            }
            
            Button("Close") {
                dismiss()
            }
            
            .padding()
        }
    }
}
