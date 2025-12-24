//
//  ScrollViewWraper.swift
//  QuickLayoutDemo
//
//  Created by Sondra on 2025/12/24.
//

import UIKit
import QuickLayout

public func ScrollView(
    _ scrollView: UIScrollView,
    alignment: Alignment,
    @FastArrayBuilder<Element> children: () -> [Element]
    ) -> Element  {
    ScrollElement(scrollView: scrollView,children: children(), alignment: alignment)
}

public struct ScrollElement: LeafElement {

    let scrollView: UIScrollView
    let children: [Element]
    let alignment: Alignment

    public init(
        scrollView: UIScrollView,
        children: [Element],
        alignment: Alignment = .center
    ) {
        self.scrollView = scrollView
        self.children = children
        self.alignment = alignment
    }

    public func quick_layoutThatFits(_ proposedSize: CGSize) -> LayoutNode {
        assert(Thread.isMainThread, "UIViews can be laid out only on the main thread.")

        return ScrollViewLayout.layoutThatFits(view: scrollView, proposedSize: proposedSize)
    }


    public func quick_flexibility(for axis: Axis) -> Flexibility {
        assert(Thread.isMainThread, "UIViews can be laid out only on the main thread.")

        return ScrollViewLayout.flexibility(for: axis)
    }

    public func quick_layoutPriority() -> CGFloat {
        return 0
    }

    public func quick_extractViewsIntoArray(_ views: inout [UIView]) {
        views.append(scrollView)
    }

    public func backingView() -> UIView? {
        scrollView
    }

}

@MainActor
private struct ScrollViewLayout {

    static func layoutThatFits(view: UIView, proposedSize: CGSize) -> LayoutNode {
        var size = proposedSize
        let selector = #selector(UIScrollView.sizeThatFits(_:))
        if view.method(for: selector) != UIScrollView.instanceMethod(for: selector) {
            size = view.sizeThatFits(proposedSize)
        }
        return LayoutNode(view: view, dimensions: ElementDimensions(sanitizeSize(size)))
    }

    static func flexibility(for axis: Axis) -> Flexibility {
        .fullyFlexible
    }
}

private func sanitizeSize(_ size: CGSize) -> CGSize {
    CGSize(
        width: size.width.isFinite ? size.width : 10,
        height: size.height.isFinite ? size.height : 10
    )
}
