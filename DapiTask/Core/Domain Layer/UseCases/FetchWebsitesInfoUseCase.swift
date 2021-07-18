//
//  GetWebsiteDetailsUseCase.swift
//  DapiTask
//
//  Created by MSZ on 14/07/2021.
//  Copyright © 2021 MSZ. All rights reserved.
//

import Foundation

protocol FetchWebsitesInfoUseCaseProtocol: AnyObject {
    var fetchedWebsiteInfoCallback: ((Result<WebsiteInfo, FetchWebsiteInfoOperationError>, _ url: String) -> Void)? {get set}
    var startFetchingWebsiteInfoCallback: ((_ websiteStringURL: String) -> Void)? {get set}
    var finishFetchingAllWebsitesCallback: (() -> Void)? {get set}
    func fetchWebsitesInfo(websiteStringURLs: [String])

}

class FetchWebsitesInfoUseCase: FetchWebsitesInfoUseCaseProtocol {

    private var faviconDownloader: FaviconDownloaderProtocol
    private var urlSession: URLSession

    var fetchedWebsiteInfoCallback: ((Result<WebsiteInfo, FetchWebsiteInfoOperationError>, _ url: String) -> Void)?
    var startFetchingWebsiteInfoCallback: ((_ websiteStringURL: String) -> Void)?
    var finishFetchingAllWebsitesCallback: (() -> Void)?

    private var fetchWebsiteDetailsOperations = [BlockOperation]()
    private let websitesDetailsQueue = OperationQueue()

    init(faviconDownloader: FaviconDownloaderProtocol,
         urlSession: URLSession) {
        self.faviconDownloader = faviconDownloader
        self.urlSession = urlSession
        websitesDetailsQueue.maxConcurrentOperationCount = 1
    }

    func fetchWebsitesInfo(websiteStringURLs: [String]) {
        fetchWebsiteDetailsOperations = websiteStringURLs.map({createWebsiteDetailsOperation(websiteStringURL: $0)})
        websitesDetailsQueue.addOperations(fetchWebsiteDetailsOperations, waitUntilFinished: false)
        DispatchQueue(label: "FetchWebsitesInfoUseCase.fetchWebsiteDetails").async { [weak self] in
            for (index, operation) in (self?.fetchWebsiteDetailsOperations ?? []).enumerated() {
                self?.startFetchingWebsiteInfoCallback?(websiteStringURLs[index])
                OperationQueue().addOperations(operation.dependencies,
                                               waitUntilFinished: true)
            }
            self?.finishFetchingAllWebsitesCallback?()
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
                self.fetchedWebsiteInfoCallback?(.success(websiteInfo), fetchWebsiteMetaDataOperation.websiteStringURL)
            case .failure( let error):
                self.fetchedWebsiteInfoCallback?(.failure(error), fetchWebsiteMetaDataOperation.websiteStringURL)
            }
        }
        websiteDetailsOperation.addDependency(fetchWebsiteMetaDataOperation)
        websiteDetailsOperation.addDependency(fetchFaviconOperation)
        return websiteDetailsOperation
    }

}
