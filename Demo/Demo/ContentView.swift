import DemoKit
import SwiftUI

struct ContentView: View {
    var body: some View {
        DemoPickerView(demos: [
            IntersectionDemoView.self,
            ThickenDemoView.self,
            LineSegmentsDemoView.self
        ])
    }
}
