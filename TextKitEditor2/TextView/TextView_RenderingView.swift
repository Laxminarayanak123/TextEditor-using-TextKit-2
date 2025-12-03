//
//  TextView_Layers.swift
//  TextKitEditor2
//
//  Created by Laxmi Narayana Koyyana on 22/11/25.
//

import UIKit
typealias Color = UIColor

import CoreGraphics

class TextRenderingView: UIView {
    var layoutFragment: NSTextLayoutFragment
    var padding: CGFloat
    var showLayerFrames: Bool
    
    let strokeWidth: CGFloat = 2
    
    init(layoutFragment: NSTextLayoutFragment, padding: CGFloat) {
        self.layoutFragment = layoutFragment
        self.padding = padding
        showLayerFrames = false
        super.init(frame: .zero)
        contentScaleFactor = UIScreen.main.scale
        isOpaque = false
        updateGeometry()
        setNeedsDisplay()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateGeometry() {
        let renderingBounds = layoutFragment.renderingSurfaceBounds
        var boundsRect = renderingBounds
        if showLayerFrames {
            var typographicBounds = layoutFragment.layoutFragmentFrame
            typographicBounds.origin = .zero
            boundsRect = boundsRect.union(typographicBounds)
        }
        
        bounds = CGRect(origin: .zero, size: boundsRect.size)
        frame = CGRect(
            origin: CGPoint(
                x: layoutFragment.layoutFragmentFrame.origin.x + boundsRect.origin.x,
                y: layoutFragment.layoutFragmentFrame.origin.y + boundsRect.origin.y
            ),
            size: boundsRect.size
        )
    }
    
    override func draw(_ rect: CGRect) {
        guard let ctx = UIGraphicsGetCurrentContext() else { return }
        let renderingBounds = layoutFragment.renderingSurfaceBounds
        var boundsRect = renderingBounds
        if showLayerFrames {
            var typographicBounds = layoutFragment.layoutFragmentFrame
            typographicBounds.origin = .zero
            boundsRect = boundsRect.union(typographicBounds)
        }
        ctx.saveGState()
        ctx.translateBy(x: -boundsRect.origin.x, y: -boundsRect.origin.y)
        layoutFragment.draw(at: .zero, in: ctx)
        
        if showLayerFrames {
            let inset = 0.5 * strokeWidth
            ctx.setLineWidth(strokeWidth)
            ctx.setStrokeColor(renderingSurfaceBoundsStrokeColor.cgColor)
            ctx.setLineDash(phase: 0, lengths: [])
            ctx.stroke(layoutFragment.renderingSurfaceBounds.insetBy(dx: inset, dy: inset))
            
            ctx.setStrokeColor(typographicBoundsStrokeColor.cgColor)
            ctx.setLineDash(phase: 0, lengths: [strokeWidth, strokeWidth])
            var typographicBounds = layoutFragment.layoutFragmentFrame
            typographicBounds.origin = .zero
            ctx.stroke(typographicBounds.insetBy(dx: inset, dy: inset))
        }
        ctx.restoreGState()
    }
    
    var renderingSurfaceBoundsStrokeColor: Color { return .systemOrange }
    var typographicBoundsStrokeColor: Color { return .systemPurple }
    
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        
        let view = super.hitTest(point, with: event)
        
        return view == self ? nil : view
        
    }
    
}
