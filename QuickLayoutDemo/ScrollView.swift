//
//  ScrollView.swift
//  MessageCell
//
//  Created by Sondra on 2025/12/22.
//

import UIKit
import QuickLayout

// MARK: - ScrollView 容器视图
/// 类似 SwiftUI ScrollView 风格的滚动视图封装
//  @QuickLayout
//  https://facebookincubator.github.io/QuickLayout/how-to-use/macro-layout-integration-donts/
final class ScrollView: UIView, HasBody {

    // MARK: - Properties
    let scrollView = UIScrollView()
    private let contentLayout: () -> Layout

    /// 滚动方向
    enum Axis {
        case vertical
        case horizontal
    }

    private let axis: Axis
    private let showsIndicators: Bool

    // MARK: - Initialization
    /// 创建 ScrollView
    /// - Parameters:
    ///   - axis: 滚动方向，默认垂直
    ///   - showsIndicators: 是否显示滚动指示器，默认 true
    ///   - content: 内容布局构建闭包
    init(
        _ axis: Axis = .vertical,
        showsIndicators: Bool = true,
        @LayoutBuilder content: @escaping () -> Layout
    ) {
        self.axis = axis
        self.showsIndicators = showsIndicators
        self.contentLayout = content
        super.init(frame: .zero)
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup
    private func setupViews() {
        addSubview(scrollView)

        // 配置 scrollView
        scrollView.showsVerticalScrollIndicator = axis == .vertical && showsIndicators
        scrollView.showsHorizontalScrollIndicator = axis == .horizontal && showsIndicators
        scrollView.alwaysBounceVertical = axis == .vertical
        scrollView.alwaysBounceHorizontal = axis == .horizontal
    }

    // MARK: - QuickLayout Integration

    // 重写 bodyContainerView，让 body 的内容添加到 scrollView
    override var bodyContainerView: UIView {
        scrollView
    }

    // body 返回内容布局
    var body: Layout {
        contentLayout()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

       // _QuickLayoutViewImplementation.layoutSubviews(self)

        let alignment: Alignment
        switch axis {
        case .vertical:
            alignment = .top
        case .horizontal:
            alignment = .leading
        }

        body.applyFrame(bounds, alignment: alignment)

        scrollView.frame = bounds
        scrollView.contentSize = sizeThatFits(bounds.size)
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        // 根据滚动方向计算内容大小
        let proposedSize: CGSize
        switch axis {
        case .vertical:
            proposedSize = CGSize(width: size.width, height: .infinity)
        case .horizontal:
            proposedSize = CGSize(width: .infinity, height: size.height)
        }

        return _QuickLayoutViewImplementation.sizeThatFits(self, size: proposedSize) ?? .zero
    }


    // MARK: - Public Configuration
    var bounces: Bool {
        get { scrollView.bounces }
        set { scrollView.bounces = newValue }
    }

    var isPagingEnabled: Bool {
        get { scrollView.isPagingEnabled }
        set { scrollView.isPagingEnabled = newValue }
    }

    var contentOffset: CGPoint {
        get { scrollView.contentOffset }
        set { scrollView.setContentOffset(newValue, animated: false) }
    }

    // MARK: - Public Methods
    func scrollTo(offset: CGPoint, animated: Bool = true) {
        scrollView.setContentOffset(offset, animated: animated)
    }

    func scrollToTop(animated: Bool = true) {
        scrollView.setContentOffset(.zero, animated: animated)
    }
}
