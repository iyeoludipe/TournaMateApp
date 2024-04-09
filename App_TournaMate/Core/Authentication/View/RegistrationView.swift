import SwiftUI

struct RegistrationView: View {
    @State private var email = ""
    @State private var fullname = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var validationError = ""
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var viewModel: AuthViewModel

    var body: some View {
        VStack {
            Image("TournaMateLogo")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 120)
                .padding(.vertical, 32)
            
            VStack(spacing: 24) {
                InputView(text: $email, title: "Email Address", placeholder: "name@example.com")
                    .autocapitalization(.none)
                
                InputView(text: $fullname, title: "Full Name", placeholder: "Enter Your Name")
                
                InputView(text: $password, title: "Password", placeholder: "Enter Your Password", isSecureField: true)
                
                ZStack(alignment: .trailing) {
                    InputView(text: $confirmPassword, title: "Confirm Password", placeholder: "Confirm Your Password", isSecureField: true)
                    
                    Image(systemName: password == confirmPassword && !password.isEmpty ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .imageScale(.large)
                        .foregroundColor(password == confirmPassword && !password.isEmpty ? .green : .red)
                }
            }
            .padding(.horizontal)
            .padding(.top, 12)
            
            Text(validationError)
                .foregroundColor(.red)
                .font(.caption)
                .padding(.bottom, 5)
            
            Button(action: signUpAction) {
                HStack {
                    Text("SIGN UP")
                        .fontWeight(.semibold)
                    Image(systemName: "arrow.right")
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(formIsValid ? Color.blue : Color.gray)
                .cornerRadius(10)
            }
            .disabled(!formIsValid)
            .padding(.top, 10)
            
            Spacer()
            
            Button(action: { dismiss() }) {
                HStack {
                    Text("Already have an account?")
                    Text("Sign In").fontWeight(.bold)
                }
                .font(.system(size: 14))
            }
        }
        .padding()
    }
    
    var formIsValid: Bool {
        let isValidEmail = email.contains("@")
        let isValidFullName = fullname.split(separator: " ").count >= 2 && fullname.split(separator: " ").allSatisfy { $0.count >= 2 }
        let isValidPassword = password.count >= 6 && password.range(of: "[A-Z]", options: .regularExpression) != nil && password.range(of: "\\d", options: .regularExpression) != nil
        let passwordsMatch = password == confirmPassword
        
        // Update validation error message
        if !isValidEmail { validationError = "Email must contain an '@'." }
        else if !isValidFullName { validationError = "Full name must be at least 2 words, each 2 characters long." }
        else if !isValidPassword { validationError = "Password must be at least 6 characters long, contain a number and an uppercase letter." }
        else if !passwordsMatch { validationError = "Passwords do not match." }
        else { validationError = "" } // Clear error message if everything is valid
        
        return isValidEmail && isValidFullName && isValidPassword && passwordsMatch
    }
    
    func signUpAction() {
        // Perform sign-up action
        // Check for existing user and show alert if necessary
    }
}

struct RegistrationView_Previews: PreviewProvider {
    static var previews: some View {
        RegistrationView().environmentObject(AuthViewModel())
    }
}
