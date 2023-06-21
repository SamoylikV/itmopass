import SwiftUI
import PythonKit


struct ContentView: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var username: String = ""
    @State private var password: String = ""
    

    
    
    var logoImage: Image {
        return colorScheme == .dark ? Image("dark_logo") : Image("light_logo")
    }
    
    var body: some View {

        GeometryReader { geometry in
            VStack(spacing: 20.0) {
                Spacer()
                Spacer()
                Spacer()
                
                logoImage
                    .resizable()
                    .frame(width: 182, height: 66)
                
                Spacer()
                Spacer()
                Spacer()
                
                List {
                    Section(header: Text("Пожалуйста войдите в свой аккаунт")) {
                        TextField("Логин или email", text: $username)
                            .frame(maxWidth: .infinity, maxHeight: 50)
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                            .multilineTextAlignment(.center)
                            .foregroundColor(colorScheme == .dark ? .white : .black)
                        SecureField("Пароль", text: $password)
                            .frame(maxWidth: .infinity, maxHeight: 50)
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                            .multilineTextAlignment(.center)
                            .foregroundColor(colorScheme == .dark ? .white : .black)
                    }


                    Section {
                        Button(action: submitLogin) {
                            Text("Войти")
                                .frame(maxWidth: .infinity, maxHeight: 50)
                                .background(Color.blue).foregroundColor(.white).cornerRadius(10).multilineTextAlignment(.center)
                        }
                    }
                }
                .listStyle(PlainListStyle())
                .padding()
            }
        }
        .background(colorScheme == .dark ? Color.black.edgesIgnoringSafeArea(.all) : Color.white.edgesIgnoringSafeArea(.all))
    }
    
    func submitLogin() {
        get_hex(username: username, password: password) { result in
            switch result {
            case .success(let hexcode):
                if let hexcode = hexcode {
                    print(hexcode)
                } else {
                    print("Error: Hexcode is nil")
                }
            case .failure(let error):
                print("Error:", error)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
