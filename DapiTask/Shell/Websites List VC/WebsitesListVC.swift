//
//  WebsitesListVC.swift
//  DapiTask
//
//  Created by MSZ on 17/07/2021.
//  Copyright © 2021 MSZ. All rights reserved.
//

import UIKit

class WebsitesListVC: UIViewController {

    @IBOutlet weak var websitesTableView: UITableView!

    var fetchWebsitesInfoUseCase: FetchWebsitesInfoUseCaseProtocol!
    private var urls = [
        "https://apple.com",
        "https://spacex.com",
        "https://dapi.co",
        "https://facebook.com",
        "https://microsoft.com",
        "https://amazon.com",
        "https://boomsupersonic.com",
        "https://twitter.com"
    ]

    private var websitesCellViewInfo = [WebsiteCellViewInfo]()

    fileprivate func setupUI() {
        startButtonItem()
        navigationItem.title = "websitesList.sitesTitle".localized
        websitesTableView.register(cellType: WebsiteCell.self)

    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        websitesCellViewInfo = urls.map({WebsiteCellViewInfo(websiteUrl: $0)})
    }

    @objc private func startButtonItemTapped() {
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        fetchWebsitesInfoUseCase.fetchWebsitesInfo(websiteStringURLs: urls)
        fetchWebsitesInfoUseCase.fetchedWebsiteInfoCallback = { [weak self] result, url in
            DispatchQueue.main.async {
                self?.fetchedWebsiteInfoCallback(result: result, for: url)
            }
        }
        fetchWebsitesInfoUseCase.startFetchingWebsiteInfoCallback = { [weak self] url in
            DispatchQueue.main.async {
                self?.startFetchingWebsiteInfoCallback(url: url)
            }
        }
        fetchWebsitesInfoUseCase.finishFetchingAllWebsitesCallback = { [weak self]  in
            DispatchQueue.main.async {
                self?.navigationItem.rightBarButtonItem?.isEnabled = true
            }
        }
    }

    private func fetchedWebsiteInfoCallback( result: Result<WebsiteInfo, FetchWebsiteInfoOperationError>,
                                             for urlString: String) {
        guard let index =  urls.firstIndex(of: urlString),
              let cell  = websitesTableView.cellForRow(at: IndexPath(row: index, section: 0)) as? WebsiteCell else {
            return
        }
        cell.stopLoading()
        switch result {
        case .success(let websiteInfo):
            websitesCellViewInfo[index].websiteInfo = websiteInfo
        case .failure(let error):
            switch error {
            case .requestFailed(let statusCode):
                websitesCellViewInfo[index].statusCode = statusCode
            default:
                print(error.message)
            }
        }
        cell.set(websiteCellViewInfo: websitesCellViewInfo[index])
    }

    private func startFetchingWebsiteInfoCallback( url: String) {
        if let index =  urls.firstIndex(of: url),
           let cell  = websitesTableView.cellForRow(at: IndexPath(row: index, section: 0)) as? WebsiteCell {
            cell.startLoading()
        }
    }

    private func startButtonItem() {
        let startButtonText = "websitesList.startButton.title".localized
        let startButtonItem = UIBarButtonItem(title: startButtonText,
                                              style: .plain,
                                              target: self,
                                              action: #selector(startButtonItemTapped))
        self.navigationItem.rightBarButtonItem = startButtonItem
    }
}

extension WebsitesListVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        websitesCellViewInfo.count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        "websitesList.contentHeader".localized
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: WebsiteCell =  tableView.dequeueReusableCell(for: indexPath)
        cell.set(websiteCellViewInfo: websitesCellViewInfo[indexPath.row])
        return cell
    }
}
