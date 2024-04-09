import SwiftUI

struct ForgotPasswordView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var email = ""
    @State private var showAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""

    var body: some View {
        NavigationView {
            VStack {
                Text("Reset Password")
                    .font(.largeTitle)
                    .bold()
                    .padding(.bottom, 20)

                InputView(text: $email, title: "Email Address", placeholder: "Enter your email")
                
                Button(action: {
                    viewModel.sendPasswordReset(withEmail: email) { success, errorMessage in
                        if success {
                            alertTitle = "Success"
                            alertMessage = "A link to reset your password has been sent to your email."
                        } else {
                            alertTitle = "Error"
                            alertMessage = errorMessage ?? "There was an error attempting to send the reset link. Please try again."
                        }
                        showAlert = true
                    }
                }) {
                    Text("Send Reset Link")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding(.top, 20)
                .alert(isPresented: $showAlert) {
                    Alert(title: Text("Check Your Email!"), message: Text(alertMessage), dismissButton: .default(Text("OK")) {
                        self.presentationMode.wrappedValue.dismiss()
                    })
                }
                
                Spacer()
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}

struct ForgotPasswordView_Previews: PreviewProvider {
    static var previews: some View {
        ForgotPasswordView()
    }
}
