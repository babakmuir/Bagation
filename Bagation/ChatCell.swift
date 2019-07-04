//
//  ChatCell.swift
//  
//
//  Created by Pushpendra on 13/12/18.
//

import Foundation
import UIKit

class ChatCell: UICollectionViewCell {
    
    var bubbleHeightAnchor      : NSLayoutConstraint?
    var bubbleWidthAnchor       : NSLayoutConstraint?
    var bubbleViewRightAnchor   : NSLayoutConstraint?
    var bubbleViewLeftAnchor    : NSLayoutConstraint?
    
    let bubbleView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addShadow()
        return view
    }()
    
    let deliverImg: UIImageView = {
        let imageView   = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .center
        imageView.layer.masksToBounds = true
        imageView.image = #imageLiteral(resourceName: "right_active")
        return imageView
    }()
    
    let textView: UITextView = {
        let tv = UITextView()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.layer.masksToBounds = true
        tv.isEditable       = false
        tv.backgroundColor  = UIColor.clear
        tv.textColor        =  .white
        tv.font = UIFont.systemFont(ofSize: 12.5)
        return tv
    }()
    
    let textViewOther: UITextView = {
        let tv = UITextView()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.layer.masksToBounds = true
        tv.isEditable       = false
        tv.backgroundColor  = UIColor.clear
        tv.textColor        =  .white
        tv.font = UIFont.systemFont(ofSize: 12.5)
        return tv
    }()
    
    let lblTimeStampRight: UILabel = {
        let label = UILabel()
        label.text = "11:21 PM"
        label.font = UIFont.systemFont(ofSize: 10)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .red//UIColor.darkGray
        return label
    }()
    
    let lblTimeStampLeft: UILabel = {
        let label = UILabel()
        label.text = "11:22 PM"
        label.font = UIFont.systemFont(ofSize: 10)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .red//UIColor.darkGray
        return label
    }()
    
    func addShadow() {
        layer.shadowColor   = UIColor.black.cgColor
        layer.shadowOffset  = CGSize(width: 0.0, height: 0.8)
        layer.shadowOpacity = 0.4
        layer.shadowRadius  = 1.0
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layoutIfNeeded()
        textView.roundCorners(corners: [.topLeft,.topRight,.bottomLeft], radius: 10)
        textView.backgroundColor =  #colorLiteral(red: 0.3156782985, green: 0.7703064084, blue: 0.9062749743, alpha: 1) //UIColor(hex: "3BC3D6")
        
        textViewOther.roundCorners(corners: [.topLeft,.topRight,.bottomRight], radius: 10)
        textViewOther.backgroundColor = Constants.eventColor2
    }
    
    //MARK: Setup all UI.
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(lblTimeStampRight)
        addSubview(bubbleView)
        addSubview(deliverImg)
        addSubview(lblTimeStampLeft)
        bubbleView.addSubview(textView)
        bubbleView.addSubview(textViewOther)

        // Chat Bubble View
        bubbleViewRightAnchor = bubbleView.rightAnchor.constraint(equalTo: self.rightAnchor,constant: -10)
        bubbleViewLeftAnchor  = bubbleView.leftAnchor.constraint(equalTo: self.leftAnchor,constant: 10)
        bubbleViewRightAnchor?.isActive = true
        
        bubbleView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive                     = true
        bubbleView.topAnchor.constraint(equalTo: self.topAnchor).isActive                           = true
        bubbleWidthAnchor = bubbleView.widthAnchor.constraint(equalToConstant: 180)
        bubbleWidthAnchor?.isActive = true
        
        // Right Chat View
        textView.topAnchor.constraint(equalTo: bubbleView.topAnchor).isActive                       = true
        textView.leftAnchor.constraint(equalTo: bubbleView.leftAnchor).isActive                     = true
        textView.rightAnchor.constraint(equalTo: bubbleView.rightAnchor).isActive                   = true
        textView.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor).isActive                 = true
        
        // Left Chat View
        textViewOther.topAnchor.constraint(equalTo: bubbleView.topAnchor).isActive                  = true
        textViewOther.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor).isActive            = true
        textViewOther.leftAnchor.constraint(equalTo: bubbleView.leftAnchor).isActive                = true
        textViewOther.rightAnchor.constraint(equalTo: bubbleView.rightAnchor).isActive              = true
        
        // Double Tic Image
        deliverImg.rightAnchor.constraint(equalTo:self.rightAnchor, constant: -10).isActive         = true
        deliverImg.bottomAnchor.constraint(equalTo:self.bottomAnchor, constant: 25).isActive        = true
        deliverImg.widthAnchor.constraint(equalToConstant: 25).isActive                             = true
        deliverImg.heightAnchor.constraint(equalToConstant: 12).isActive                            = true
        
        // Right TimeStamp Label
        lblTimeStampRight.rightAnchor.constraint(equalTo:deliverImg.leftAnchor).isActive                    = true
        lblTimeStampRight.bottomAnchor.constraint(equalTo:bubbleView.bottomAnchor,constant:25).isActive     = true
        
        // Left TimeStamp Label
        lblTimeStampLeft.leftAnchor.constraint(equalTo: bubbleView.leftAnchor, constant: 8).isActive        = true
        lblTimeStampLeft.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor,constant: 25).isActive    = true
        deliverImg.isHidden = true
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
