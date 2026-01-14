import SwiftUI

// MARK: - SelectionModifier

struct SelectionModifier<Item: Identifiable>: ViewModifier where Item.ID: Hashable {
    @Binding var selection: Set<Item.ID>
    let items: [Item]
    let itemRect: (Item) -> CGRect
    let hitTest: (CGPoint) -> Item?
    let transform: CGAffineTransform
    let shiftKeyDown: Bool

    @State private var marqueeStart: CGPoint?
    @State private var marqueeEnd: CGPoint?
    @State private var selectionBeforeMarquee: Set<Item.ID> = []

    private var marqueeRect: CGRect? {
        guard let start = marqueeStart, let end = marqueeEnd else { return nil }
        return CGRect(
            x: min(start.x, end.x),
            y: min(start.y, end.y),
            width: abs(end.x - start.x),
            height: abs(end.y - start.y)
        )
    }

    func body(content: Content) -> some View {
        content
            .overlay {
                Canvas { context, _ in
                    if let rect = marqueeRect {
                        context.stroke(Path(rect), with: .color(.accentColor), lineWidth: 1)
                        context.fill(Path(rect), with: .color(.accentColor.opacity(0.1)))
                    }
                }
                .allowsHitTesting(false)
            }
            .gesture(
                DragGesture(minimumDistance: 5)
                    .onChanged { value in
                        if marqueeStart == nil {
                            marqueeStart = value.startLocation
                            selectionBeforeMarquee = shiftKeyDown ? selection : []
                        }
                        marqueeEnd = value.location
                        updateSelectionFromMarquee()
                    }
                    .onEnded { _ in
                        marqueeStart = nil
                        marqueeEnd = nil
                    }
            )
            .onTapGesture { location in
                let worldLocation = location.applying(transform.inverted())
                if let tappedItem = hitTest(worldLocation) {
                    if shiftKeyDown {
                        if selection.contains(tappedItem.id) {
                            selection.remove(tappedItem.id)
                        } else {
                            selection.insert(tappedItem.id)
                        }
                    } else {
                        selection = [tappedItem.id]
                    }
                } else {
                    selection.removeAll()
                }
            }
    }

    private func screenToWorld(_ point: CGPoint) -> CGPoint {
        point.applying(transform.inverted())
    }

    private func updateSelectionFromMarquee() {
        guard let rect = marqueeRect else { return }
        let topLeft = screenToWorld(rect.origin)
        let bottomRight = screenToWorld(CGPoint(x: rect.maxX, y: rect.maxY))
        let worldRect = CGRect(
            x: min(topLeft.x, bottomRight.x),
            y: min(topLeft.y, bottomRight.y),
            width: abs(bottomRight.x - topLeft.x),
            height: abs(bottomRight.y - topLeft.y)
        )

        var newSelection = selectionBeforeMarquee
        for item in items {
            let itemBounds = itemRect(item)
            if worldRect.intersects(itemBounds) {
                newSelection.insert(item.id)
            }
        }
        selection = newSelection
    }
}

// MARK: - View Extension

extension View {
    func selectable<Item: Identifiable>(
        selection: Binding<Set<Item.ID>>,
        items: [Item],
        itemRect: @escaping (Item) -> CGRect,
        hitTest: @escaping (CGPoint) -> Item?,
        transform: CGAffineTransform,
        shiftKeyDown: Bool
    ) -> some View where Item.ID: Hashable {
        modifier(SelectionModifier(
            selection: selection,
            items: items,
            itemRect: itemRect,
            hitTest: hitTest,
            transform: transform,
            shiftKeyDown: shiftKeyDown
        ))
    }
}
