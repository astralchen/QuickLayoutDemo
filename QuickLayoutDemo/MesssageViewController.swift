//
//  ViewController.swift
//  MessageCell
//
//  Created by Sondra on 2025/12/17.
//

import UIKit

final class MesssageViewController: UIViewController {

    private var collectionView: UICollectionView!
    private var data: [MessageModel] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        setupData()
        setupCollectionView()
    }

    private func setupData() {
        data = [
            MessageModel(title: "Alice", message: "Hello"),
            MessageModel(title: "Bob", message: "这是一个比较长的消息，用来测试 QuickLayout 在 UICollectionView 中的自适应高度表现。"),
            MessageModel(title: "Charlie", message: "短"),
            MessageModel(title: "David", message: String(repeating: "很长的内容 ", count: 10))
        ]
    }

    private func setupCollectionView() {
        collectionView = UICollectionView(
            frame: view.bounds,
            collectionViewLayout: makeLayout()
        )

        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = .systemGroupedBackground

        collectionView.register(
            MessageCell.self,
            forCellWithReuseIdentifier: "MessageCell"
        )

        collectionView.dataSource = self
        view.addSubview(collectionView)
    }

    private func makeLayout() -> UICollectionViewLayout {
        UICollectionViewCompositionalLayout { _, _ in

            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(80)
            )

            let item = NSCollectionLayoutItem(layoutSize: itemSize)

            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(80)
            )

            let group = NSCollectionLayoutGroup.vertical(
                layoutSize: groupSize,
                subitems: [item]
            )

            let section = NSCollectionLayoutSection(group: group)
            section.interGroupSpacing = 8
            section.contentInsets = .init(top: 8, leading: 12, bottom: 8, trailing: 12)

            return section
        }
    }
}

extension MesssageViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        data.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "MessageCell",
            for: indexPath
        ) as! MessageCell

        cell.configure(data[indexPath.item])
        cell.backgroundColor = .white
        cell.layer.cornerRadius = 8

        return cell
    }
}

