//
//  TextView_ViewPort.swift
//  TextKitEditor2
//
//  Created by Laxmi Narayana Koyyana on 22/11/25.
//

import UIKit

extension TextView : NSTextViewportLayoutControllerDelegate {
    
    func viewportBounds(for textViewportLayoutController: NSTextViewportLayoutController) -> CGRect {
        
        CGRect(origin: .init(x: 0, y: contentOffset.y), size: bounds.size)
    }
    
    func textViewportLayoutControllerWillLayout(_ controller: NSTextViewportLayoutController) {
        contentLayer.sublayers = nil
        let visiblerect : CGRect = .init(x: 0, y: contentOffset.y, width: frame.width, height: frame.height)
        overlayView.subviews.forEach {
            if let _ = $0 as? CheckBoxView {
                if !visiblerect.contains($0.frame) {
                    $0.removeFromSuperview()
                }
            }
        }
        CATransaction.begin()
    }
    
    
    func textViewportLayoutController(_ textViewportLayoutController: NSTextViewportLayoutController,
                                      configureRenderingSurfaceFor textLayoutFragment: NSTextLayoutFragment) {
        let (textLayoutFragmentLayer, didCreate) = findOrCreateLayer(textLayoutFragment)
        if !didCreate {
            let oldPosition = textLayoutFragmentLayer.position
            let oldBounds = textLayoutFragmentLayer.bounds
            textLayoutFragmentLayer.updateGeometry()
            if oldBounds != textLayoutFragmentLayer.bounds {
                textLayoutFragmentLayer.setNeedsDisplay()
            }
            if oldPosition != layer.position {
                animate(textLayoutFragmentLayer, from: oldPosition, to: textLayoutFragmentLayer.position)
            }
        }
        
        contentLayer.addSublayer(textLayoutFragmentLayer)
        
        if let textLayoutFragment = textLayoutFragment as? CheckboxTextLayoutFragment {

            let (fragmentView, _) = findOrCreateView(for: textLayoutFragment)
            
            let fragmentFrame = textLayoutFragment.layoutFragmentFrame
            
            
            let viewWidth: CGFloat = 32
            let viewX: CGFloat = fragmentFrame.minX - viewWidth
            let padding = 17.0
            let viewFrame = CGRect(
                x: viewX - padding,
                y: fragmentFrame.minY + 10,
                width: viewWidth,
                height: viewWidth
            )
            
            fragmentView.frame = viewFrame
            overlayView.addSubview(fragmentView)
            

            oldFragmentViewMap.removeValue(forKey: textLayoutFragment)
            
            newFragmentViewMap[textLayoutFragment] = fragmentView
            
        }
    }
    
    func textViewportLayoutControllerDidLayout(_ controller: NSTextViewportLayoutController) {
        
        for item in oldFragmentViewMap{
            item.value.removeFromSuperview()
        }
        
        oldFragmentViewMap = newFragmentViewMap
        newFragmentViewMap.removeAll()
        
        CATransaction.commit()
    }
    
    override func layoutSublayers(of layer: CALayer) {
        
        super.layoutSublayers(of: layer)
        
        assert(layer == self.layer)
        if let tlm = textLayoutManager{
            tlm.textViewportLayoutController.layoutViewport()
        }
        
        updateContentSizeIfNeeded()
        contentLayer.frame = CGRect(origin: .init(x: textContainerInset.left, y:  textContainerInset.top), size: contentSize)
        overlayView.frame = contentLayer.frame
        
    }
    
    
    func updateContentSizeIfNeeded() {
        
        let currentHeight = bounds.height
        var height: CGFloat = 0
        textLayoutManager!.enumerateTextLayoutFragments(from: textLayoutManager!.documentRange.endLocation,
                                                        options: [.reverse, .ensuresLayout]) { layoutFragment in
            height = layoutFragment.layoutFragmentFrame.maxY
            return false // stop
        }
        height = max(height, contentSize.height)
        if abs(currentHeight - height) > 1e-10 {
            let contentSize = CGSize(width: self.bounds.width, height: height)
            self.contentSize = contentSize
        }
    }
    
    func findOrCreateLayer(_ textLayoutFragment: NSTextLayoutFragment) -> (TextLayoutFragmentLayer, Bool) {
        if let layer = fragmentLayerMap.object(forKey: textLayoutFragment) as? TextLayoutFragmentLayer {
            return (layer, false)
        } else {
            let layer = TextLayoutFragmentLayer(layoutFragment: textLayoutFragment, padding: padding)
            fragmentLayerMap.setObject(layer, forKey: textLayoutFragment)
            return (layer, true)
        }
    }
    
    
    
    func animate(_ layer: CALayer, from source: CGPoint, to destination: CGPoint) {
        let animation = CABasicAnimation(keyPath: "position")
        animation.fromValue = source
        animation.toValue = destination
        animation.duration = 0.6
//        layer.add(animation, forKey: nil)
    }
    
    func findOrCreateView(for textLayoutFragment: NSTextLayoutFragment) -> (UIView, Bool) {
        if let view = fragmentViewMap.object(forKey: textLayoutFragment) {
            return (view, false)
        } else {
            // Customize this view however you want
            let v = CheckBoxView()
//            v.backgroundColor = .systemYellow // just to see it
            v.textLayoutFragment = textLayoutFragment
            v.textView = self
            
            if let fragment = textLayoutFragment as? CheckboxTextLayoutFragment{

                if fragment.isChecked{
                    v.check()
                }
                else{
                    v.unCheck()
                }
                
            }
            
            // You can also plug in a custom checkbox view here.
            fragmentViewMap.setObject(v, forKey: textLayoutFragment)
            return (v, true)
        }
    }
    
//    override func caretRect(for position: UITextPosition) -> CGRect {
//        let superRect = super.caretRect(for: position)
//        let rect = CGRect(origin: superRect.origin, size: .init(width: 50, height: 2))
//        
//        return isDraggingCheckbox ? rect : superRect
//    }
    
}
