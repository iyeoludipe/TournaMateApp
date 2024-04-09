import SwiftUI

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var showAlert = false
    @EnvironmentObject var viewModel: AuthViewModel
    

    
    var body: some View {
        NavigationStack{
            VStack {
                // image
                Image("TournaMateLogo")
                    .resizable()
                    .scaledToFill()
                    .frame(width:100, height: 120)
                    . padding(.vertical, 32)
                
                
                // form fields
                VStack(spacing:24) {
                    InputView(text: $email,
                              title: "Email Address",
                              placeholder: "name@example.com")
                    .autocapitalization(/*@START_MENU_TOKEN@*/.none/*@END_MENU_TOKEN@*/)
                    
                    InputView(text: $password,
                              title: "Password",
                              placeholder: "Enter Your Password",
                              isSecureField: true)
                }
                .padding(.horizontal)
                .padding(.top, 12)
                
                //forgot passowrd
                
                NavigationLink {
                    ForgotPasswordView()
                        .navigationBarBackButtonHidden(true)
                } label: {
                    HStack(spacing: 3) {
                        Text("Forgot Password?")
                            .fontWeight(.bold)
                        Text("Reset it here")
                            
                    }
                    .font(.system(size: 14))
                    .padding(.top, 10)
                }
                
                //sign in button
                
                Button {
                    Task {
                        try await viewModel.signIn(withEmail: email, password: password)
                    }
                } label: {
                    HStack {
                        Text("SIGN IN")
                            .fontWeight(.semibold)
                        Image(systemName: "arrow.right")
                    }
                    .foregroundColor(.white)
                    .frame(width: UIScreen.main.bounds.width - 32, height: 48)
                }
                .background(Color(.systemBlue))
                .disabled(!formIsValid)
                .opacity(formIsValid ? 1.0 : 0.5)
                .cornerRadius(10)
                .padding(.top, 24)
                
                Spacer()
                
                //sign up button
                
                NavigationLink {
                    RegistrationView()
                        .navigationBarBackButtonHidden(true)
                } label: {
                    HStack(spacing: 3) {
                        Text("Don't have an account?")
                        Text("Sign Up")
                            .fontWeight(.bold)
                    }
                    .font(.system(size: 14))
                }
            }
            .alert("Error", isPresented: $showAlert, actions: {
                Button("OK", role: .cancel) { }
            }, message: {
                Text(viewModel.authError?.message ?? "An unknown error occurred.")
            })
            .onChange(of: viewModel.authError) { _ in
                showAlert = viewModel.authError != nil
            }

            
        }
    }
}

extension LoginView: AuthenticationFormProtocol {
    var formIsValid: Bool {
        return !email.isEmpty
        && email.contains("@")
        && !password.isEmpty
        && password.count > 5
    }
    
    
}

#Preview {
    LoginView()
}
