//
//  WebsiteCell.swift
//  DapiTask
//
//  Created by MSZ on 17/07/2021.
//  Copyright © 2021 MSZ. All rights reserved.
//

import UIKit

struct WebsiteCellViewInfo {
    var websiteInfo: WebsiteInfo?
    var statusCode: Int?
    var websiteUrl: String

}

class WebsiteCell: UITableViewCell {

    @IBOutlet weak var faviconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var loader: UIActivityIndicatorView!

    override func awakeFromNib() {
        super.awakeFromNib()
        loader.isHidden = true
        faviconImageView.isHidden = true
        subTitleLabel.isHidden = true

    }

    override func prepareForReuse() {
        loader.isHidden = true
        faviconImageView.isHidden = true
        subTitleLabel.isHidden = true
    }

    private func set(faviconImage: UIImage?) {
        UIView.transition(with: faviconImageView,
                          duration: 0.75,
                          options: .transitionCrossDissolve,
                          animations: { [weak self] in
                            self?.faviconImageView.isHidden = faviconImage == nil
                            self?.faviconImageView.image = faviconImage

                          },
                          completion: nil)
    }

    private func set(titleLabelContent: String) {
        titleLabel.text = URL(string: titleLabelContent)?.absoluteURL.host
    }

    private func set(subTitleLabelContent: String) {
        subTitleLabel.text = subTitleLabelContent
        subTitleLabel.isHidden = false
    }

    func startLoading() {
        loader.startAnimating()
        loader.isHidden = false
        faviconImageView.isHidden = false
    }

    func stopLoading() {
        loader.stopAnimating()
    }

    func set( websiteCellViewInfo: WebsiteCellViewInfo) {
        set(titleLabelContent: websiteCellViewInfo.websiteUrl)
        guard websiteCellViewInfo.statusCode != nil || websiteCellViewInfo.websiteInfo != nil else {
            set(faviconImage: nil)
            return
        }
        if let statusCode = websiteCellViewInfo.statusCode {
            set(faviconImage: #imageLiteral(resourceName: "failureIcon"))
            set(subTitleLabelContent: "\(statusCode) \( "websitesList.statsCode".localized)")
        } else if  let websiteInfo = websiteCellViewInfo.websiteInfo {
            set(faviconImage: websiteInfo.favicon?.imageData.uiImage ?? #imageLiteral(resourceName: "failureIcon"))
            set(subTitleLabelContent: "\(websiteInfo.websiteMetaData.formatedContentSize)")
        }

    }
}
