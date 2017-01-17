//
//  CommentsCell.swift
//  hacker
//
//  Created by yesway on 2017/1/13.
//  Copyright © 2017年 joker. All rights reserved.
//

import UIKit

let CommentsCellId = "commentCellId"
let CommentCellMarginConstant: CGFloat = 16.0
let CommentCellTopMargin: CGFloat = 5.0
let CommentCellFontSize: CGFloat = 13.0
let CommentCellUsernameHeight: CGFloat = 25.0
let CommentCellBottomMargin: CGFloat = 16.0

class CommentsCell: UITableViewCell {

    var comment: Comment! {
        didSet {
            let username = comment.username
            let date = " - " + comment.prettyTime!
            
            let usernameAttributed = NSAttributedString(string: username!,
                                                        attributes: [NSFontAttributeName : UIFont.boldSystemFont(ofSize: CommentCellFontSize),
                                                                     NSForegroundColorAttributeName: UIColor.HNColor()])
            let dateAttribute = NSAttributedString(string: date,
                                                   attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: CommentCellFontSize),
                                                                NSForegroundColorAttributeName: UIColor.DateLighGrayColor()])
            let fullAttributed = NSMutableAttributedString(attributedString: usernameAttributed)
            fullAttributed.append(dateAttribute)
            
            self.commentLabel.font = UIFont.systemFont(ofSize: CommentCellFontSize)
            
            self.usernameLabel.attributedText = fullAttributed
            self.commentLabel.text = comment.text
        }
    }
    
    var indentation: CGFloat = 0.0 {
        didSet {
            self.commentLeftMarginConstraint.constant = indentation
            self.usernameLeftMarginConstrain.constant = indentation
            self.commentHeightConstrain.constant =
                self.contentView.frame.size.height - CommentCellUsernameHeight - CommentCellTopMargin - CommentCellMarginConstant + 5.0
            self.contentView.setNeedsUpdateConstraints()
        }
    }
    
    
    @IBOutlet var usernameLabel: UILabel! = nil
    @IBOutlet var commentLabel: UITextView! = nil
    @IBOutlet var commentLeftMarginConstraint: NSLayoutConstraint! = nil
    @IBOutlet var commentHeightConstrain: NSLayoutConstraint! = nil
    @IBOutlet var usernameLeftMarginConstrain: NSLayoutConstraint! = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.commentLabel.font = UIFont.systemFont(ofSize: CommentCellFontSize)
        self.commentLabel.textColor = UIColor.CommentLightGrayColor()
        self.commentLabel.linkTextAttributes = [NSFontAttributeName: UIFont.systemFont(ofSize: CommentCellFontSize),
                                                NSForegroundColorAttributeName: UIColor.ReadingListColor()]
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.commentLabel.text = comment.text
        
        self.commentLabel.textContainer.lineFragmentPadding = 0
        self.commentLabel.textContainerInset = UIEdgeInsets.zero
        self.commentLabel.contentInset = UIEdgeInsets.zero
        
        self.commentLabel.frame.size.width = self.contentView.bounds.width - (self.commentLeftMarginConstraint.constant * 2) - (CommentCellMarginConstant * CGFloat(self.comment.depth))
        self.indentation = CommentCellMarginConstant + (CommentCellMarginConstant * CGFloat(self.comment.depth))
    }
    
    class func heightForText(_ text: String, bounds: CGRect, level: Int) -> CGFloat {
        let size = text.boundingRect(with: CGSize(width: bounds.width - (CommentCellMarginConstant * 2) -
            (CommentCellMarginConstant * CGFloat(level)), height: CGFloat.greatestFiniteMagnitude),
                                     options: NSStringDrawingOptions.usesLineFragmentOrigin,
                                     attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: CommentCellFontSize)],
                                     context: nil)
        return CommentCellMarginConstant + CommentCellUsernameHeight + CommentCellTopMargin + size.height + CommentCellBottomMargin
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
