//
//  ContentView.swift
//  DraggablePopUp_POC
//
//  Created by Guru Mahan on 26/03/24.
//

import SwiftUI

struct ContentView: View {
    @State var startPoint: CGFloat = 0
    @State var curHeight: CGFloat = 0
    var body: some View {
        ZStack {
            VStack {
                Image(systemName: "globe")
                    .imageScale(.large)
                Text("Hello, world!")
            }
            .padding()
            .onTapGesture {
                withAnimation(.spring) {
                    startPoint = UIScreen.main.bounds.height * 0.50
                    curHeight = 400
                }
            }
            
            DraggablePopUpView(popUpView: .constant(popUpView()), currentHeight: $curHeight)
              
              
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity,alignment: .bottom)
        .ignoresSafeArea()
        .animation(.spring)
        .background(Color.white)
        
     
    }
}

#Preview {
    ContentView()
}

struct popUpView: View {
    var array: [String] = ["content1", "content2", "content3","content4", "content5"]
    var body: some View {
        List(array, id: \.self) { content in
         Text(content)
        }
    }
}

struct DraggablePopUpView<Content: View>: View {
    @Binding var currentHeight: CGFloat
    @State var endDragPoint: CGFloat = 0
    @State var previousValue: CGFloat = 0
    @Binding var contentView: Content
    let screenHeight = UIScreen.main.bounds.height
    let maxHeight: CGFloat = 700
    let minHeight: CGFloat = 400
    
    let startOpacity: Double = 0.2
    let endOpacity: Double = 0.3
    
    var dragPercentage: Double {
        let res = Double((currentHeight - minHeight) / (maxHeight - minHeight))
        return max(0, min(1, res))
    }
    
    init(popUpView: Binding<Content>, currentHeight:  Binding<CGFloat>) {
        _contentView = popUpView
        _currentHeight = currentHeight
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            let opacity = startOpacity + (endOpacity - startOpacity) * dragPercentage
            Color.black.opacity(currentHeight > 550 ? opacity : 0)
                .onTapGesture {
                    withAnimation(.spring) {
                        currentHeight = 0
                    }
                }
            VStack(spacing: 0) {
                ZStack {
                    Color.white
                        .frame(maxWidth: .infinity, maxHeight: 35)
                        .cornerRadius(10, corners: [.topLeft, .topRight])
                    RoundedRectangle(cornerRadius: 10)
                        .frame(width: 35, height: 4)
                        .foregroundColor(Color.gray)
                }
                .gesture(dragGesture)
                contentView
            }
            .frame(height: currentHeight)
            .background(Color.white
                .cornerRadius(10, corners: [.topLeft, .topRight])
                .shadow(color: Color.black.opacity(0.1),radius: 8))
        }
        .opacity(currentHeight > 0 ? 1 : 0)
        
    }
    
    var dragGesture: some Gesture {
        DragGesture(minimumDistance: 0, coordinateSpace: .global)
            .onChanged({ value in
                withAnimation(.spring) {
                    let dragHeight = value.translation.height - previousValue
                    if currentHeight > maxHeight || currentHeight < minHeight {
                        currentHeight -= dragHeight / 3
                    } else {
                        currentHeight -= dragHeight
                    }
                }
                previousValue = value.translation.height
            })
            .onEnded({ endValue in
                previousValue = 0
                withAnimation(.spring) {
                    if currentHeight > maxHeight {
                        currentHeight = maxHeight
                    } else if currentHeight < minHeight && currentHeight != 0 {
                        currentHeight = 0
                    }
                }
            })
    }
}


struct RoundedCorner: Shape {

    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape( RoundedCorner(radius: radius, corners: corners) )
    }
}

