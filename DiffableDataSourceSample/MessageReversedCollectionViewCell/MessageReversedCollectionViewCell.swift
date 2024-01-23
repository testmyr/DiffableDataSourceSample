//
//  MessageReversedCollectionViewCell.swift
//  DiffableDataSourceSample
//
//  Created by sdk on 23.01.2024.
//

import UIKit


class MessageReversedCollectionViewCell: UICollectionViewCell, Rounded {
    @IBOutlet private weak var vwBack: UIView!
    @IBOutlet private weak var lblText: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.transform = CGAffineTransform(scaleX: 1, y: -1)
    }
    
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//    }
//    
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setRounded()
        
    }
    func setText(_ text: String) {
        lblText?.text = text
    }
    
    func setRounded() {
        vwBack.backgroundColor=UIColor.white
        let path = UIBezierPath(roundedRect:vwBack.bounds, byRoundingCorners:[.topLeft, .topRight, .bottomRight], cornerRadii: CGSizeMake(16, 16))
        let maskLayer = CAShapeLayer()
        maskLayer.frame = vwBack.bounds;
        maskLayer.path = path.cgPath
        vwBack.layer.mask = maskLayer;
    }
}
