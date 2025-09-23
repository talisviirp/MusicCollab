import SwiftUI

struct OnboardingView: View {
    var onComplete: () -> Void
    @State private var nickname: String = UserDefaults.standard.string(forKey: "nickname") ?? ""

    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                // Header
                VStack(spacing: 16) {
                    Image(systemName: "music.note.house.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.accentColor)
                    
                    Text("Welcome to MusicCollab!")
                        .font(.largeTitle.bold())
                        .multilineTextAlignment(.center)
                    
                    Text("Create music together with friends in real-time")
                        .font(.title3)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 40)
                
                // Input Section
                VStack(spacing: 20) {
                    Text("Pick a nickname to get started")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    TextField("Enter your nickname", text: $nickname)
                        .textFieldStyle(.roundedBorder)
                        .font(.title2)
                        .multilineTextAlignment(.center)
                        .autocapitalization(.words)
                        .disableAutocorrection(true)
                }
                .padding(.horizontal, 40)
                
                Spacer()
                
                // Continue Button
                Button(action: saveAndContinue) {
                    HStack {
                        Text("Continue")
                            .font(.title2.bold())
                        Image(systemName: "arrow.right")
                            .font(.title2)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(nickname.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? Color.gray : Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(15)
                }
                .disabled(nickname.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                .padding(.horizontal, 40)
                .padding(.bottom, 40)
            }
            .navigationTitle("Welcome")
            .navigationBarHidden(true)
        }
    }

    private func saveAndContinue() {
        let trimmed = nickname.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        UserDefaults.standard.set(trimmed, forKey: "nickname")
        if UserDefaults.standard.string(forKey: "userId") == nil {
            UserDefaults.standard.set(UUID().uuidString, forKey: "userId")
        }
        onComplete()
    }
}

// MARK: - Preview
struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView {
            print("Preview: Onboarding completed")
        }
        .previewDisplayName("Onboarding")
    }
}
