import SwiftUI

struct AccountView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.dismiss) var dismiss

    // State for controlling navigation
    @State private var navigateToForgotPassword = false

    // State for showing alert
    @State private var showAlert = false
    @State private var alertMessage = ""

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
                            alertMessage = message  // Set the error message
                            showAlert = true  // Show alert on error
                        }
                    }
                }) {
                    Text("Delete Account").foregroundColor(.red)
                }
                .padding()
                .alert(isPresented: $showAlert) {
                    Alert(
                        title: Text("Error"),
                        message: Text(alertMessage),
                        dismissButton: .default(Text("OK"))
                    )
                }

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
