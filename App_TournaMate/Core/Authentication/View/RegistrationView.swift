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
                
                InputView(text: $confirmPassword, title: "Confirm Password", placeholder: "Confirm Your Password", isSecureField: true)
            }
            .padding(.horizontal)
            .padding(.top, 12)
            
            Text(validationError)
                .foregroundColor(.red)
                .font(.caption)
                .padding(.bottom, 5)
            
            Button(action: {
                Task {
                    await signUpAction()
                }
            }) {
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
        .onChange(of: email) { _ in validateFields() }
        .onChange(of: fullname) { _ in validateFields() }
        .onChange(of: password) { _ in validateFields() }
        .onChange(of: confirmPassword) { _ in validateFields() }
    }
    
    var formIsValid: Bool {
        email.contains("@") &&
        fullname.split(separator: " ").count >= 2 &&
        password.count >= 6 &&
        password.range(of: "[A-Z]", options: .regularExpression) != nil &&
        password.range(of: "\\d", options: .regularExpression) != nil &&
        password == confirmPassword
    }
    
    func signUpAction() async {
            if formIsValid {
                do {
                    try await viewModel.createUser(withEmail: email, password: password, fullname: fullname)
                    // Handle successful sign up, navigate or update UI accordingly
                    print("User created successfully")
                } catch {
                    // If createUser throws an error, handle it here
                    print("Failed to create user: \(error.localizedDescription)")
                }
            } else {
                print("Form is not valid")
            }
        }
    
    private func validateFields() {
        var errors = [String]()
        if !email.contains("@") { errors.append("Email must contain an '@'.") }
        if fullname.split(separator: " ").count < 2 { errors.append("Full name must be at least 2 words.") }
        if password.count < 6 { errors.append("Password must be at least 6 characters.") }
        if password.range(of: "[A-Z]", options: .regularExpression) == nil { errors.append("Password must contain an uppercase letter.") }
        if password.range(of: "\\d", options: .regularExpression) == nil { errors.append("Password must contain a number.") }
        if password != confirmPassword { errors.append("Passwords do not match.") }
        
        validationError = errors.joined(separator: " ")
    }
}
