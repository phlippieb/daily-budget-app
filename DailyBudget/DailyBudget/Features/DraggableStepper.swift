//
//  DraggableStepper.swift
//
//  Created by Jack Hogan on 1/9/22.
//  Copyright © 2022 Jack Hogan. Licensed Under MIT License.
//

/*
MIT License
Copyright (c) 2022 Jack Hogan
Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/

import SwiftUI

struct DraggableStepper<Content: View, Value: Strideable>: View {
    @Binding var value: Value
    let range: ClosedRange<Value>
    let label: (Bool) -> Content // Bool: whether or not currently dragging

    @State private var lastStart: CGPoint = .zero
    @State private var translateDelta = 0

    var body: some View {
        Stepper(value: $value, in: range) {
            label(lastStart != .zero)
                .gesture(DragGesture().onChanged { gesture in
                    if lastStart == .zero {
                        lastStart = gesture.startLocation
                    }
                    translateDelta = Int((gesture.location.x - lastStart.x) / 10)
                    if translateDelta != 0 {
                        lastStart = gesture.location
                    }
                }.onEnded { _ in
                    lastStart = .zero
                })
                .onChange(of: translateDelta) { _ in
                    value = clamp(value: value.advanced(by: Value.Stride(exactly: translateDelta)!), range: range)
                }
        }
    }
}

fileprivate struct DraggableStepperView_Previews: PreviewProvider {
    @State private static var val = 0
    static var previews: some View {
        DraggableStepper(value: $val, range: 0...50) { isDragging in
            Text("Preview \(val) \(isDragging ? "D" : "ND")")
        }
    }
}

fileprivate func clamp<T: Comparable>(value: T, range: ClosedRange<T>) -> T {
    min(max(value, range.lowerBound), range.upperBound)
}
