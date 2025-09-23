import SwiftUI

struct ContentView: View {
    var body: some View {
        AppCoordinatorView()
    }
}

// MARK: - Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .previewDisplayName("MusicCollab App")
    }
}
