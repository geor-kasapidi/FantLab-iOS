import Foundation
import UIKit
import ALLKit
import yoga

public final class FLTextImageLayoutSpec: ModelLayoutSpec<UIImage> {
    public override func makeNodeFrom(model: UIImage, sizeConstraints: SizeConstraints) -> LayoutNode {
        let imageNode = LayoutNode(children: [], config: { node in
            node.width = 50%
            node.aspectRatio = Float(model.size.width / model.size.height)
        }) { (imageView: UIImageView, _) in
            imageView.clipsToBounds = true
            imageView.image = model
        }

        return LayoutNode(children: [imageNode], config: { node in
            node.flexDirection = .column
            node.alignItems = .center
        })
    }
}
