import SwiftUI

struct FlexibleTextField: View {
    
    @FocusState private var isFocused: Bool
    
    @State private var fieldWidth: CGFloat = 0
    
    private var isCorrectInput: TextValidation
    private var label: String
    private var text: Binding<String>
    
    init(label: String, text: Binding<String>, isCorrectInput: TextValidation = .empty) {
        self.text = text
        self.label = label
        self.isCorrectInput = isCorrectInput
    }
    
    enum TextValidation {
        case valid
        case invalid
        case empty
    }
    
    var body: some View {
        ZStack {
            HStack {
                background
                    .overlay {
                        focusedFrame
                    }
                    .overlay(alignment: .trailing) {
                        clearButton.opacity(textFieldCondition() ? 1.0 : 0)
                    }
                Spacer()
            }
            textField
        }
        
        // animations
        .animation(.default, value: isFocused)
        .animation(.bouncy, value: fieldWidth)
        
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                initTextField(text: text.wrappedValue)
            }
        }
        
        .onChange(of: text.wrappedValue) { newText in
            initTextField(text: newText)
            fieldWidth = fieldWidth > UIScreen.main.bounds.width - 36 ? UIScreen.main.bounds.width - 36 : fieldWidth
        }
        
        .onChange(of: isFocused) { _ in
            initTextField(text: text.wrappedValue)
        }
        .onTapGesture {
            isFocused = true
        }
    }
    
    
    // MARK: PROPERTIES
    
    // Clear button
    private var clearButton: some View {
        Button {
            text.wrappedValue = ""
        } label: {
            Image(systemName: "xmark.circle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 16, height: 16)
                .opacity(0.3)
                .padding(.trailing)
        }
    }
    
    // TextField background
    private var background: some View {
        RoundedRectangle(cornerRadius: DrawingConstants.fieldHeight / 2.3)
            .foregroundStyle(.gray.opacity(0.15))
            .frame(width: fieldWidth, height: DrawingConstants.fieldHeight)
    }
    
    // Background frame
    private var focusedFrame: some View {
        RoundedRectangle(cornerRadius: DrawingConstants.fieldHeight / 2.3)
            .strokeBorder(lineWidth: 2)
            .foregroundStyle(text.wrappedValue.isEmpty ? .blue : isCorrectInput == .valid || isCorrectInput == .empty ? .blue : .red)
            .opacity(isFocused ? 1 : 0)
            .frame(width: fieldWidth, height: DrawingConstants.fieldHeight)
    }
    
    // Textfield
    private var textField: some View {
        TextField(label, text: text)
            .font(Font(DrawingConstants.font))
            .padding(.horizontal, 12)
            .textFieldStyle(.plain)
            .focused($isFocused)
            .allowsHitTesting(false)
            .frame(width: UIScreen.main.bounds.width - 36)
    }
    
    // MARK: FUNCTIONS
    
    // Get TextField condition
    private func textFieldCondition() -> Bool {
        if !text.wrappedValue.isEmpty && isFocused {
            return true
        } else {
            return false
        }
    }
    
    // Get TextField width
    private func initTextField(text: String) {
        fieldWidth = text.sizeOfString(font: DrawingConstants.font).width
        if fieldWidth == 0  {
            fieldWidth = label.sizeOfString(font: DrawingConstants.font).width + DrawingConstants.safeDistance
        } else if !text.isEmpty && isFocused {
            fieldWidth += DrawingConstants.safeDistance + 25
        } else {
            fieldWidth += DrawingConstants.safeDistance
        }
    }
    
    private struct DrawingConstants {
        static let font: UIFont = .systemFont(ofSize: 18)
        static let fieldHeight: CGFloat = 40
        static let safeDistance: CGFloat = 35
    }
}
