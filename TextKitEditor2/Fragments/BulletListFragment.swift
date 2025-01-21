//
//  BulletListFragment.swift
//  TextKitEditor2
//
//  Created by Sohan Maurya on 20/01/25.
//

import UIKit

class BulletListTextLayoutFragment : NSTextLayoutFragment {
     let padding: CGFloat = 5

    
    // increasing renderigSurfaceBounds bounds to draw checkbox
    override var renderingSurfaceBounds: CGRect {
        let bounds = super.renderingSurfaceBounds
        let rect = CGRect(origin: .init(x: -54, y: bounds.origin.y),
                          size: .init(width: bounds.size.width + 54, height: bounds.size.height))
        return rect
    }
    
    override func draw(at point: CGPoint, in context: CGContext) {
        
        let font = UIFont.boldSystemFont(ofSize: 21)
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: UIColor.label,
        ]
        
        let numberString = "•"
        let numberSize = numberString.size(withAttributes: attributes)
        
        let numberRect = CGRect(
            x: (renderingSurfaceBounds.origin.x) + 13.0,
            y: renderingSurfaceBounds.origin.y + padding + (font.pointSize * 0.2),
            width: 54,
            height: numberSize.height
        )
        
        // Draw the number
        context.saveGState()
        numberString.draw(
            in: numberRect,
            withAttributes: attributes
        )
        context.restoreGState()
        
        super.draw(at: point, in: context)
    }
}
