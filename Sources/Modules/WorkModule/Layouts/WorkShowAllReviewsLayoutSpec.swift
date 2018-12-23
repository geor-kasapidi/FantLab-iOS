import Foundation
import UIKit
import ALLKit
import FantLabStyle

final class WorkShowAllReviewsLayoutSpec: LayoutSpec {
    override func makeNodeWith(sizeConstraints: SizeConstraints) -> LayoutNode {
        let titleString = "Все отзывы".attributed()
            .font(Fonts.system.medium(size: 17))
            .foregroundColor(UIColor(rgb: 0x007AFF))
            .make()

        let textNode = LayoutNode(sizeProvider: titleString, config: nil) { (label: UILabel) in
            label.numberOfLines = 0
            label.attributedText = titleString
        }

        return LayoutNode(children: [textNode], config: { node in
            node.alignItems = .center
            node.justifyContent = .center
            node.padding(all: 24)
        })
    }
}