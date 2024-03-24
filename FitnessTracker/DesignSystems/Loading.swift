import SwiftUI

struct Loading: View {
    let loadingMessage: String  // Property for the message

    @State private var isAnimating = false

    var body: some View {
        VStack(spacing: 20) {
            ProgressView()
            .onAppear {
                isAnimating = true
            }
            Text(loadingMessage)
                .font(.headline)
                .foregroundColor(.blue)
        }
    }
}

struct LoadingTextView_Previews: PreviewProvider {
    static var previews: some View {
        Loading(loadingMessage: "Loading")
    }
}
