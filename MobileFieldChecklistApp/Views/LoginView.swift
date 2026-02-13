import SwiftUI

struct LoginView: View {
    @EnvironmentObject private var appState: AppState
    @StateObject private var vm = LoginViewModel()

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                VStack(spacing: 6) {
                    Text("Mobile Field Checklist")
                        .font(.title2).bold()
                    Text("Login → pilih job → checklist + foto + lokasi → submit → sync")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding(.top, 16)

                VStack(spacing: 10) {
                    TextField("Username", text: $vm.username)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .padding(12)
                        .background(.thinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 12))

                    SecureField("Password", text: $vm.password)
                        .padding(12)
                        .background(.thinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 12))

                    if let err = vm.errorMessage {
                        Text(err)
                            .font(.footnote)
                            .foregroundStyle(.red)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    Button {
                        vm.submit(auth: appState.auth)
                    } label: {
                        HStack {
                            Image(systemName: "lock.open")
                            Text(vm.isBusy ? "Memproses..." : "Login")
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(vm.isBusy)
                }
                .padding(.horizontal)

                Spacer()

                VStack(spacing: 6) {
                    Text("Demo login offline-friendly")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("Isi username apa saja, password minimal 4 karakter.")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                .padding(.bottom, 18)
            }
            .navigationTitle("Login")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
