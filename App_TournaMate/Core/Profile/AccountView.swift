import SwiftUI

struct AccountView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.dismiss) var dismiss
    
    // State for controlling navigation
    @State private var navigateToForgotPassword = false
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Account Management")
                    .font(.title)
                    .padding()

                // Sign Out button
                Button(action: {
                    viewModel.signOut()
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Sign Out")
                }
                .padding()
                
                // Reset Password button
                Button(action: {
                    // Trigger navigation
                    navigateToForgotPassword = true
                }) {
                    Text("Reset Password")
                }
                .padding()
                .background(
                    NavigationLink(
                        destination: ForgotPasswordView(),
                        isActive: $navigateToForgotPassword
                    ) {
                        EmptyView()
                    }
                    .hidden() // Hide the NavigationLink itself
                )

                // Delete Account button
                Button(action: {
                    viewModel.deleteAccount { success, message in
                        if success {
                            presentationMode.wrappedValue.dismiss()  // Dismiss view if account is deleted
                        } else {
                            print(message)  // Handle error
                        }
                    }
                }) {
                    Text("Delete Account").foregroundColor(.red)
                }
                .padding()

                // Close button
                Button("Close") {
                    dismiss()
                }
                .padding()
            }
            .navigationBarTitle("Account Management", displayMode: .inline)
        }
    }
}
