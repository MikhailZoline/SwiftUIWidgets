//
//  Skeleton.swift
//
//
//  Created by Mikhail Zoline on 11/21/24.
//

import SwiftUI

struct Skeleton: ViewModifier {
    @Binding private var isLoading: Bool?
    @State private var isAnimating: Bool = false
    // gradient animation params
    private let min = -0.5
    private let max = 1.5
    private let animation = Animation.linear(duration: 1.5).repeatForever(autoreverses: false)
    private let gradient = Gradient(colors: [.gray, .white.opacity(0.5), .gray])
    private let angle = Angle.degrees(0.0)
    
    init(isLoading: Binding<Bool?>){
        self._isLoading = isLoading
    }
    
    func body(content: Content) -> some View {
        if isLoading ?? false {
            content
            .overlay {
                ///Apply skeleton animation
                    shimmer
            }
            .mask(alignment: .center) {
                ///Apply content mask, so the content shapes (Image, Text, etc) will be skeletonized
                ///The content shapes are provided by the `redacted` view modifier
                ///If we don't apply content mask, the whole content recangle will be skeletonized
                    content
            }
        } else {
            content
        }
    }
    
    var startPoint: UnitPoint {
        isAnimating ? UnitPoint(x: 1, y: 1) : UnitPoint(x: min, y: min)
    }
    var endPoint: UnitPoint {
        isAnimating ? UnitPoint(x: max, y: max) : UnitPoint(x: 0, y: 0)
    }
    
    var shimmer: some View {
        LinearGradient(
            gradient: self.gradient,
            startPoint: startPoint,
            endPoint: endPoint
        )
        .rotationEffect(angle)
        .scaleEffect(1.5)
        .clipped()
        .animation(animation, value: isAnimating)
        .onAppear {
            guard isLoading ?? false else {return}
            isAnimating = true
        }
        .onChange(of: isLoading, perform: { value in
            isAnimating.toggle()
        })
    }
}

public extension View {
    func skeleton(_ isLoading: Binding<Bool?>) -> some View {
        self.modifier(Skeleton(isLoading: isLoading))
    }
}

/// Shows the usage of `skeleton` View Modifier together with the `redacted` Modifier
///
struct SkeletonPreview: View {
    @State var isLoading: Bool? = true
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack {
                    ForEach(0..<8) { _ in
                        VStack {
                            if isLoading ?? false {
                                skeletonCard
                                    .transition(.opacity.animation(.easeInOut(duration: 1)))
                                /// apply `skeleton` in conjunction with `redacted`
                                    .redacted(reason: isLoading ?? false ? .placeholder : [])
                                    .skeleton($isLoading)
                            } else {
                                skeletonCard
                                    .transition(.opacity.animation(.easeInOut(duration: 1)))
                            }
                        }
                    }
                }
            }
            .navigationTitle(isLoading ?? false ? "Loading in progress..." : "Loaded content")
            /// Demo Skeleton Controls
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        withAnimation(.easeInOut(duration: 1)) {
                            isLoading?.toggle()
                        }
                    } label: {
                        VStack {
                            Text(isLoading ?? false ? "Stop loading" : "Start loading")
                                .font(.system(size: 16, weight: .bold))
                        }
                    }
                }
            }
        }
    }
    
    var skeletonCard: some View {
        HStack(alignment: .center) {
            if isLoading ?? false {/// isLoading based rendering is not necessary here it could be the Image alone
                VStack {
                    Circle()
                        .fill(.blue)
                        .frame(width: 72, height: 72)
                        .padding(.leading)
                }
            } else {
                Image(systemName: "person.circle")
                    .font(.system(size: 80))
                    .padding(.leading)
            }
            Spacer()
            Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam")
                .frame(height: .infinity)
                .padding()
        }
        .overlay {
            RoundedRectangle(cornerRadius: 12, style: .circular)
                .stroke(lineWidth: 1)
        }
        .padding(.horizontal)
    }
    
}

#Preview {
    SkeletonPreview()
}
