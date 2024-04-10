import SwiftUI

struct ForgotPasswordView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
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

                TextField("Email Address", text: $email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                Button(action: {
                    authViewModel.sendPasswordReset(withEmail: email) { success, errorMessage in
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
                    Alert(title: Text(alertTitle), message: Text(alertMessage), dismissButton: .default(Text("OK")) {
                        if alertTitle == "Success" {
                            self.presentationMode.wrappedValue.dismiss()
                        }
                    })
                }
                
                Spacer()
            }
            .padding()
            .navigationBarTitle("Reset Password", displayMode: .inline)
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
        ForgotPasswordView().environmentObject(AuthViewModel())
    }
}
