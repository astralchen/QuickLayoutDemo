//
//  ScrollViewWraper.swift
//  QuickLayoutDemo
//
//  Created by Sondra on 2025/12/24.
//

import UIKit
import QuickLayout

// MARK: - ScrollView 容器视图
/// 类似 SwiftUI ScrollView 风格的滚动视图封装
/// 参考: https://facebookincubator.github.io/QuickLayout/how-to-use/macro-layout-integration-donts/

public func ScrollView(
    _ scrollView: QLSrollView,
    axis: QuickLayout.Axis = .vertical,
    @FastArrayBuilder<Element> children: () -> [Element]
) -> ScrollElement   {
    ScrollElement(scrollView, axis: axis, children: children())
}

public class QLSrollView: UIScrollView, HasBody {

    public var axis: QuickLayout.Axis = .vertical

    public var children: [Element] = []

    public var body: Layout {
        switch axis {
        case .vertical:
            VStack(alignment: .leading) {
                return children
            }
        case .horizontal:
            HStack(alignment: .top) {
                return children
            }
        }
    }

    public override func layoutSubviews() {
        super.layoutSubviews()

        // 根据滚动方向设置对齐方式
        // 垂直滚动：内容从顶部开始
        // 水平滚动：内容从左侧开始
        let alignment: Alignment = axis == .vertical ? .top : .leading

        // 手动应用布局，指定对齐方式
        // 不能使用 _QuickLayoutViewImplementation.layoutSubviews(self)
        // 因为它会使用默认的居中对齐，导致滚动视图内容居中而不是从顶部/左侧开始
        body.applyFrame(CGRect(origin: .zero, size: frame.size), alignment: alignment)

        let size = frame.size

        // 根据滚动方向计算内容大小
        let proposedSize = fittingSize(size)

        // 使用 QuickLayout 的实现计算大小
        let  bodySize = _QuickLayoutViewImplementation.sizeThatFits(self, size: proposedSize) ?? .zero

        // 更新 scrollView 的 contentSize
        contentSize = bodySize
        
    }

    private func fittingSize(_ size: CGSize) -> CGSize {
        // 根据滚动方向计算内容大小
        let proposedSize: CGSize
        switch axis {
        case .vertical:
            // 垂直滚动：宽度固定，高度无限
            proposedSize = CGSize(width: size.width, height: .infinity)
        case .horizontal:
            // 水平滚动：高度固定，宽度无限
            proposedSize = CGSize(width: .infinity, height: size.height)
        }

        return proposedSize
    }

    public override func sizeThatFits(_ size: CGSize) -> CGSize {
        // 根据滚动方向计算内容大小
        let proposedSize = fittingSize(size)

        // 使用 QuickLayout 的实现计算大小
        return _QuickLayoutViewImplementation.sizeThatFits(self, size: proposedSize) ?? .zero
    }

}

public struct ScrollElement: Layout, LeafElement {



    let scrollView: QLSrollView
    let axis: Axis


    public init(
        _ scrollView: QLSrollView,
        axis: Axis,
        children: [Element],

    ) {
        self.scrollView = scrollView
        self.axis = axis
        scrollView.children = children

    }

    public func quick_layoutThatFits(_ proposedSize: CGSize) -> LayoutNode {

        return scrollView.quick_layoutThatFits(proposedSize)
    }

    public func quick_flexibility(for axis: Axis) -> Flexibility {
        return scrollView.quick_flexibility(for: axis)
    }

    public func quick_layoutPriority() -> CGFloat {
        return scrollView.quick_layoutPriority()
    }

    public func quick_extractViewsIntoArray(_ views: inout [UIView]) {
        views.append(scrollView)
    }

    public func backingView() -> UIView? {
        scrollView
    }


}




class VerticalScrollViewViewController: QLHostingController {

    let scrollView = QLSrollView()

    let views: [UIView] =  {

        let colors: [UIColor] = [.systemRed, .systemPink, .systemOrange, .systemPurple, .systemCyan]

        return (1...20).map { _ in
            let view = UIView()
            view.backgroundColor = colors.randomElement()
            view.layer.cornerRadius = 16
            return view
        }

    }()

    override var body: Layout {

        ScrollView(scrollView, axis: .vertical) {
            VStack(spacing: 8) {
                ForEach(views) { view in
                    view
                        .frame(height: 200)
                }
            }
            .padding(16)

        }
        .resizable()
        .frame(width: view.frame.width, height: view.frame.height)

    }


    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.backgroundColor = .systemTeal.withAlphaComponent(0.5)
    }

}


class HorizontalScrollViewViewController: QLHostingController {

    let scrollView = QLSrollView()

    let views: [UIView] =  {

        let colors: [UIColor] = [.systemRed, .systemPink, .systemOrange, .systemPurple, .systemCyan]

        return (1...10).map { _ in
            let view = UIView()
            view.backgroundColor = colors.randomElement()
            view.layer.cornerRadius = 16
            return view
        }

    }()

    override var body: Layout {

        ScrollView(scrollView, axis: .horizontal) {
            HStack(spacing: 0) {
                ForEach(views) { view in
                    view
                        .frame(width: 200)
                }
            }
//            .padding(16)

        }
        .resizable()
        .frame(width: view.frame.width, height: view.frame.height)

    }


    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.backgroundColor = .systemGray6
    }

}


#Preview("VerticalScroll") {
    VerticalScrollViewViewController()
}

#Preview("HorizontalScroll") {
    HorizontalScrollViewViewController()
}


