import UIKit
import QuickLayout

// MARK: - ScrollView 容器视图
/// 类似 SwiftUI ScrollView 风格的滚动视图封装
/// 参考: https://facebookincubator.github.io/QuickLayout/how-to-use/macro-layout-integration-donts/
final class ProxyScrollView: UIView, HasBody {

    // MARK: - Properties
    private(set) var scrollView = UIScrollView()
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

    /// 重写 bodyContainerView，让 body 的内容添加到 scrollView
    override var bodyContainerView: UIView {
        scrollView
    }

    /// body 返回内容布局
    var body: Layout {
        contentLayout()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        // 让 scrollView 填充整个视图
        scrollView.frame = bounds

        // 根据滚动方向设置对齐方式
        // 垂直滚动：内容从顶部开始
        // 水平滚动：内容从左侧开始
        let alignment: Alignment = axis == .vertical ? .top : .leading

        // 手动应用布局，指定对齐方式
        // 不能使用 _QuickLayoutViewImplementation.layoutSubviews(self)
        // 因为它会使用默认的居中对齐，导致滚动视图内容居中而不是从顶部/左侧开始
        body.applyFrame(bounds, alignment: alignment)

        // 更新 scrollView 的 contentSize
        scrollView.contentSize = sizeThatFits(bounds.size)
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
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

        // 使用 QuickLayout 的实现计算大小
        return _QuickLayoutViewImplementation.sizeThatFits(self, size: proposedSize) ?? .zero
    }

    // MARK: - Public Configuration

    /// 控制边界弹性效果
    var bounces: Bool {
        get { scrollView.bounces }
        set { scrollView.bounces = newValue }
    }

    /// 是否启用分页滚动
    var isPagingEnabled: Bool {
        get { scrollView.isPagingEnabled }
        set { scrollView.isPagingEnabled = newValue }
    }

    /// 当前滚动偏移量
    var contentOffset: CGPoint {
        get { scrollView.contentOffset }
        set { scrollView.setContentOffset(newValue, animated: false) }
    }

    /// 内容边距
    var contentInset: UIEdgeInsets {
        get { scrollView.contentInset }
        set {
            scrollView.contentInset = newValue
            setNeedsLayout()
        }
    }

    /// 滚动指示器边距（垂直）
    var verticalScrollIndicatorInsets: UIEdgeInsets {
        get { scrollView.verticalScrollIndicatorInsets }
        set { scrollView.verticalScrollIndicatorInsets = newValue }
    }

    /// 滚动指示器边距（水平）
    var horizontalScrollIndicatorInsets: UIEdgeInsets {
        get { scrollView.horizontalScrollIndicatorInsets }
        set { scrollView.horizontalScrollIndicatorInsets = newValue }
    }

    // MARK: - Public Methods

    /// 滚动到指定偏移量
    func scrollTo(offset: CGPoint, animated: Bool = true) {
        scrollView.setContentOffset(offset, animated: animated)
    }

    /// 滚动到顶部
    func scrollToTop(animated: Bool = true) {
        scrollView.setContentOffset(.zero, animated: animated)
    }

    /// 滚动到底部
    func scrollToBottom(animated: Bool = true) {
        // 强制布局以确保 contentSize 是最新的
        scrollView.layoutIfNeeded()

        // 获取实际生效的 contentInset（包含系统自动调整的安全区域）
        let adjustedInset = scrollView.adjustedContentInset

        let bottomOffset: CGPoint
        switch axis {
        case .vertical:
            // 计算滚动到底部的偏移量
            let offsetY = scrollView.contentSize.height - scrollView.bounds.height + adjustedInset.bottom
            bottomOffset = CGPoint(x: scrollView.contentOffset.x, y: max(-adjustedInset.top, offsetY))

        case .horizontal:
            // 计算滚动到最右侧的偏移量
            let offsetX = scrollView.contentSize.width - scrollView.bounds.width + adjustedInset.right
            bottomOffset = CGPoint(x: max(-adjustedInset.left, offsetX), y: scrollView.contentOffset.y)
        }

        scrollView.setContentOffset(bottomOffset, animated: animated)
    }

    /// 刷新布局（动态内容变化时调用）
    func refresh() {
        setNeedsLayout()
        layoutIfNeeded()
    }
}

// MARK: - 便捷扩展
extension ProxyScrollView {

    /// 设置代理
    func delegate(_ delegate: UIScrollViewDelegate?) -> Self {
        scrollView.delegate = delegate
        return self
    }

    /// 配置弹性效果
    func bounces(_ enabled: Bool) -> Self {
        scrollView.bounces = enabled
        return self
    }

    /// 配置分页
    func pagingEnabled(_ enabled: Bool) -> Self {
        scrollView.isPagingEnabled = enabled
        return self
    }

    /// 配置内容边距
    func contentInset(_ insets: UIEdgeInsets) -> Self {
        scrollView.contentInset = insets
        return self
    }

    /// 配置内容边距调整行为
    func contentInsetAdjustmentBehavior(_ behavior: UIScrollView.ContentInsetAdjustmentBehavior) -> Self {
        scrollView.contentInsetAdjustmentBehavior = behavior
        return self
    }
}
