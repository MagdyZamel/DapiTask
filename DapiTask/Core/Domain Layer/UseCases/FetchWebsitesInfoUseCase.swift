//
//  GetWebsiteDetailsUseCase.swift
//  DapiTask
//
//  Created by MSZ on 14/07/2021.
//  Copyright © 2021 MSZ. All rights reserved.
//

import Foundation

protocol FetchWebsitesInfoUseCaseProtocol: AnyObject {
    var fetchedWebsiteInfoCallback: ((Result<WebsiteInfo, Error>) -> Void)? {get set}
    func fetchWebsitesInfo()
}

class FetchWebsitesInfoUseCase: FetchWebsitesInfoUseCaseProtocol {

    private var faviconDownloader: FaviconDownloaderProtocol
    private var urlSession: URLSession
    private var websiteStringURLs: [String]

    var fetchedWebsiteInfoCallback: ((Result<WebsiteInfo, Error>) -> Void)?

    private var fetchWebsiteDetailsOperations = [BlockOperation]()
    private let websitesDetailsQueue = OperationQueue()

    init(websiteStringURLs: [String],
         faviconDownloader: FaviconDownloaderProtocol,
         urlSession: URLSession) {
        self.websiteStringURLs = websiteStringURLs
        self.faviconDownloader = faviconDownloader
        self.urlSession = urlSession
        websitesDetailsQueue.maxConcurrentOperationCount = 1
    }

    func fetchWebsitesInfo() {
        fetchWebsiteDetailsOperations = websiteStringURLs.map({createWebsiteDetailsOperation(websiteStringURL: $0)})
        websitesDetailsQueue.addOperations(fetchWebsiteDetailsOperations, waitUntilFinished: false)
        DispatchQueue(label: "FetchWebsitesInfoUseCase.fetchWebsiteDetails").async { [weak self] in
            self?.fetchWebsiteDetailsOperations.forEach { ii in
                OperationQueue().addOperations(ii.dependencies,
                                               waitUntilFinished: true)
            }
        }
    }

    private func createWebsiteDetailsOperation(websiteStringURL: String) -> BlockOperation {

        let fetchFaviconOperation = FetchWebsiteFaviconOperation(faviconDownloader: faviconDownloader,
                                                                 websiteStringURL: websiteStringURL)
        let fetchWebsiteMetaDataOperation = FetchWebsiteMetaDataOperation(urlSession: urlSession,
                                                                          websiteStringURL: websiteStringURL)
        let websiteDetailsOperation: BlockOperation = BlockOperation {  [weak self] in
            guard let self = self else { return }
            switch fetchWebsiteMetaDataOperation.result! {
            case .success(let websiteMetaData):
                let favicon = fetchFaviconOperation.result?.value
                let websiteInfo = WebsiteInfo(urlString: websiteStringURL,
                                              favicon: favicon,
                                              websiteMetaData: websiteMetaData)
                self.fetchedWebsiteInfoCallback?(.success(websiteInfo))
            case .failure( let error):
                self.fetchedWebsiteInfoCallback?(.failure(error))
            }
        }
        websiteDetailsOperation.addDependency(fetchWebsiteMetaDataOperation)
        websiteDetailsOperation.addDependency(fetchFaviconOperation)
        return websiteDetailsOperation
    }

}
