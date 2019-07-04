//
//  Bagation
//
//  Created by vivek soni on 18/01/18.
//  Copyright © 2018 IOSAppExpertise. All rights reserved.
//

import UIKit
import MapKit
import Contacts

class CustomAnnotationView: MKMarkerAnnotationView  {
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
    }
    
//    override func draw(_ rect: CGRect) {
//        super.draw(rect)
//        if rect.size.height == 200 {
//            return
//        }
//           self.draw(CGRect(x: rect.origin.x, y: rect.origin.y, width: rect.size.width, height: 200))
//            setNeedsLayout()
//        
//    }
    
    override func didAddSubview(_ subview: UIView) {
        if isSelected {
            
            setNeedsLayout()
        }
    }
    
    override func layoutSubviews() {
        
        // MKAnnotationViews only have subviews if they've been selected.
        // short-circuit if there's nothing to loop over
        
        if !isSelected {
            return
        }
        
        loopViewHierarchy { (view: UIView) -> Bool in
            if let label = view as? UILabel {
                //label.font = UIFont.systemFont(ofSize: 12)
                label.adjustsFontSizeToFitWidth = true
                //label.minimumScaleFactor = 0.2
                //label.numberOfLines = 0
                return false
            }
            return true
        }
    }
}

typealias ViewBlock = (_ view: UIView) -> Bool

extension UIView {
    func loopViewHierarchy(block: ViewBlock?) {
        
        if block?(self) ?? true {
            for subview in subviews {
                subview.loopViewHierarchy(block: block)
            }
        }
    }
}
