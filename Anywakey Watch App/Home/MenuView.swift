
import SwiftUI

struct MenuView: View {
    
    @State private var rotationAngle = 0.0
    let action: () -> Void
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("To start PC just press button.")
            Spacer()
            Button {
                action()
                WKHapticManager.instance.play(.success)
                withAnimation(.smooth) {
                    rotationAngle -= 360
                }
            } label: {
                HStack {
                    Text("Update devices")
                    Spacer()
                    Image(systemName: "arrow.circlepath")
                        .rotationEffect(.degrees(rotationAngle))
                }
            }
            .buttonBorderShape(.roundedRectangle)
        }
        .navigationTitle("Menu")
        .padding(.horizontal, 4)
    }
}
