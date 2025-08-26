import SwiftUI

struct ContentView: View {
    @State private var showAuthorizationView = true

    var body: some View {
        NavigationStack {
            if showAuthorizationView {
                AuthorizationView()
                    .navigationTitle("Вход")
                    .navigationBarHidden(true)
            } else {
                RegistrationView()
                    .navigationTitle("Регистрация")
                    .navigationBarHidden(true)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
