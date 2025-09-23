import SwiftUI

struct AppCoordinatorView: View {
    @State private var hasCompletedOnboarding = false
    @State private var selectedRoom: Room?
    @State private var isShowingSequencer = false
    
    var body: some View {
        Group {
            if !hasCompletedOnboarding {
                OnboardingView {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        hasCompletedOnboarding = true
                    }
                }
            } else if isShowingSequencer, let room = selectedRoom {
                SequencerView(room: room)
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))
            } else {
                RoomListView { room in
                    selectedRoom = room
                    withAnimation(.easeInOut(duration: 0.5)) {
                        isShowingSequencer = true
                    }
                }
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))
            }
        }
        .onAppear {
            checkOnboardingStatus()
        }
    }
    
    private func checkOnboardingStatus() {
        hasCompletedOnboarding = UserDefaults.standard.string(forKey: "nickname") != nil
    }
}

// MARK: - Preview
struct AppCoordinatorView_Previews: PreviewProvider {
    static var previews: some View {
        AppCoordinatorView()
            .previewDisplayName("App Coordinator")
    }
}
