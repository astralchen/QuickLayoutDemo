//
//  ScrollViewController.swift
//  MessageCell
//
//  Created by Sondra on 2025/12/22.
//

import UIKit
import QuickLayout

// This view is the "VStack { ViewA; ViewB; ViewC }" part.
@QuickLayout
final class ScrollContentView: UIView {

    let viewA =  {
        let view = UIView()
        view.backgroundColor = .systemCyan
        view.layer.cornerRadius = 5
        return view
    }()
    let viewB = {
        let view = UIView()
        view.backgroundColor = .systemBrown
        view.layer.cornerRadius = 16
        return view
    }()

    let viewC = {
        let view = UIView()
        view.backgroundColor = .systemPink
        view.layer.cornerRadius = 16
        return view
    }()

    var body: Layout {
        VStack(spacing: 8) {

            // 没有固有尺寸，理想尺寸默认10
            viewA

            viewB
                .frame(height: 400)


            viewC
                .frame(height: 500)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
    }
}

class ScrollViewController: UIViewController {

    private let scrollView = UIScrollView()
    private let contentView = ScrollContentView()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        scrollView.frame = view.bounds

        // Ask QuickLayout how big the content wants to be for a given width
        // `sizeThatFits` is implemented for @QuickLayout views
        let proposedSize = CGSize(width: scrollView.bounds.width, height: .infinity)
        let contentSize = contentView.sizeThatFits(proposedSize)

        // Fix the content view to that size, pinned to (0, 0)
        contentView.frame = CGRect(origin: .zero, size: contentSize)

        // Let UIScrollView know how much it can scroll
        scrollView.contentSize = contentView.bounds.size
    }

}


#Preview {
    ScrollViewController()
}


// MARK: - 使用示例

// 示例 1: 最简洁的使用方式
class VerticalScrollViewController: UIViewController {

    private let colorView1 = UIView()
    private let colorView2 = UIView()
    private let colorView3 = UIView()

    private lazy var scrollView = ProxyScrollView { [unowned self] in

        VStack(spacing: 8) {
            colorView1
                .frame(height: 150)

            colorView2
                .frame(height: 400)

            colorView3
                .frame(height: 500)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        // 配置视图
        colorView1.backgroundColor = .systemTeal
        colorView1.layer.cornerRadius = 16

        colorView2.backgroundColor = .systemBrown
        colorView2.layer.cornerRadius = 16

        colorView3.backgroundColor = .systemPink
        colorView3.layer.cornerRadius = 16

        view.addSubview(scrollView)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.frame = view.bounds
    }
}

// 示例 2: 水平滚动
class HorizontalScrollViewController: UIViewController {

    private let items: [UIView] = {
        return (0..<10).map { index in
            let view = UIView()
            view.backgroundColor = [
                .systemRed, .systemBlue, .systemGreen,
                .systemYellow, .systemOrange, .systemPurple
            ].randomElement()
            view.layer.cornerRadius = 12
            return view
        }
    }()

    private lazy var scrollView = ProxyScrollView(.horizontal, showsIndicators: false) { [weak self] in
        guard let self = self else { return EmptyLayout() }
        return HStack(spacing: 12) {
            ForEach(self.items) { item in
                item.frame(width: 150, height: 200)
            }
        }
        .padding(.all, 16)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.addSubview(scrollView)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.frame = view.bounds
    }
}

// 示例 3: 复杂布局
class ComplexScrollViewController: UIViewController {

    private let headerView = UIView()
    private let cardViews: [UIView] = {
        return (0..<5).map { _ in
            let view = UIView()
            view.backgroundColor = .systemGray6
            view.layer.cornerRadius = 12
            view.layer.shadowColor = UIColor.black.cgColor
            view.layer.shadowOpacity = 0.1
            view.layer.shadowOffset = CGSize(width: 0, height: 2)
            view.layer.shadowRadius = 4
            return view
        }
    }()
    private let footerView = UIView()

    private lazy var scrollView = ProxyScrollView(.vertical, showsIndicators: true) { [unowned self] in
        VStack(spacing: 16) {
            // Header
            self.headerView
                .frame(height: 200)

            // Cards
            ForEach(self.cardViews) { card in
                card
                    .frame(height: 120)
                    .padding(.horizontal, 8)
            }

            // Footer
            self.footerView
                .frame(height: 100)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 20)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        // 配置视图
        headerView.backgroundColor = .systemIndigo
        headerView.layer.cornerRadius = 16

        footerView.backgroundColor = .systemGray4
        footerView.layer.cornerRadius = 8

        view.addSubview(scrollView)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.frame = view.bounds
    }
}

// 示例 4: 嵌套布局
class NestedLayoutScrollViewController: UIViewController {

    private let topSection = UIView()
    private let leftCard = UIView()
    private let rightCard = UIView()
    private let bottomSection = UIView()

    private lazy var scrollView = ProxyScrollView { [unowned self] in
        VStack(spacing: 20) {
            // 顶部区域
            self.topSection
                .frame(height: 150)

            // 中间两栏布局
            HStack(spacing: 12) {
                self.leftCard

                self.rightCard
            }
            .frame(height: 200)

            // 底部区域
            self.bottomSection
                .frame(height: 300)
        }
        .padding(.all, 16)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        topSection.backgroundColor = .systemTeal
        topSection.layer.cornerRadius = 12

        leftCard.backgroundColor = .systemOrange
        leftCard.layer.cornerRadius = 12

        rightCard.backgroundColor = .systemPurple
        rightCard.layer.cornerRadius = 12

        bottomSection.backgroundColor = .systemMint
        bottomSection.layer.cornerRadius = 12

        view.addSubview(scrollView)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.frame = view.bounds
    }
}

// 示例 5: 动态内容
class DynamicScrollViewController: UIViewController {

    private var items: [UIView] = []

    private lazy var scrollView = ProxyScrollView { [unowned self] in
        VStack(spacing: 12) {
            ForEach(self.items) { item in
                item
                    .frame(height: 80)
            }
        }
        .padding(.all, 16)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        // 初始化项目
        addItems(count: 10)

        view.addSubview(scrollView)

        // 添加按钮用于动态添加内容
        let addButton = UIButton(type: .system)
        addButton.setTitle("Add Item", for: .normal)
        addButton.addTarget(self, action: #selector(addItemTapped), for: .touchUpInside)
        addButton.frame = CGRect(x: 16, y: 50, width: 100, height: 44)
        view.addSubview(addButton)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let scrollFrame = CGRect(
            x: 0,
            y: 100,
            width: view.bounds.width,
            height: view.bounds.height - 100
        )
        scrollView.frame = scrollFrame
    }

    @objc private func addItemTapped() {
        addItems(count: 1)
        scrollView.refresh()
        scrollView.scrollToBottom()
    }

    private func addItems(count: Int) {
        let colors: [UIColor] = [
            .systemRed, .systemBlue, .systemGreen,
            .systemYellow, .systemOrange, .systemPurple,
            .systemPink, .systemIndigo, .systemTeal
        ]

        for _ in 0..<count {
            let view = UIView()
            view.backgroundColor = colors.randomElement()
            view.layer.cornerRadius = 8
            items.append(view)
        }
    }
}


#Preview("VerticalScrollView") {
    VerticalScrollViewController()
}


#Preview("HorizontalScrollView") {
    HorizontalScrollViewController()
}

#Preview("ComplexScrollView") {
    ComplexScrollViewController()
}

#Preview("NestedLayoutScrollView") {
    NestedLayoutScrollViewController()
}



#Preview("DynamicScrollView") {
    DynamicScrollViewController()
}




