//
//  MessageCell.swift
//  MessageCell
//
//  Created by Sondra on 2025/12/17.
//

import UIKit
import QuickLayout

@QuickLayout
final class MessageCell: UICollectionViewCell {

    let avatarView = UIImageView()
    let titleLabel = UILabel()
    let messageLabel = UILabel()

    var body: Layout {
        HStack(alignment: .top, spacing: 8) {

            avatarView
                .resizable()
                .frame(width: 40, height: 40)

            VStack(alignment: .leading, spacing: 4) {
                titleLabel
                messageLabel
            }
            Spacer()

        }
        .padding(12)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        avatarView.backgroundColor = .systemBlue
        avatarView.layer.cornerRadius = 20
        avatarView.clipsToBounds = true

        titleLabel.font = .boldSystemFont(ofSize: 14)
        messageLabel.font = .systemFont(ofSize: 14)
        messageLabel.numberOfLines = 0
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    func configure(_ model: MessageModel) {
        titleLabel.text = model.title
        messageLabel.text = model.message
        setNeedsLayout()
    }

    // ⭐让 CompositionalLayout 识别高度
    override func preferredLayoutAttributesFitting(
        _ layoutAttributes: UICollectionViewLayoutAttributes
    ) -> UICollectionViewLayoutAttributes {

        let targetSize = CGSize(
            width: layoutAttributes.size.width,
            height: .infinity
        )
        let size = systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel)
        layoutAttributes.size = size
        return layoutAttributes
    }
    
}


#Preview {
    MesssageViewController()
}
