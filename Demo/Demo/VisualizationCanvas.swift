import SwiftUI
import Geometry
import Visualization

struct VisualizationCanvas <Element>: View where Element: VisualizationRepresentable {

    let elements: [Element]

    var body: some View {
        Canvas { context, size in
            for element in elements {
                element.visualize(in: context, style: .init(), transform: .identity)
            }
        }
    }

}

