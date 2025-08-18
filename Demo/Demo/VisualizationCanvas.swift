import Geometry
import SwiftUI
import Visualization

struct VisualizationCanvas <Element>: View where Element: VisualizationRepresentable {
    let elements: [Element]

    var body: some View {
        Canvas { context, _ in
            for element in elements {
                element.visualize(in: context, style: .init(), transform: .identity)
            }
        }
    }
}
