//
//  AppDelegate.swift
//  DapiTask
//
//  Created by MSZ on 08/07/2021.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
 var window: UIWindow?
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let fetchWebsitesInfoUseCase = FetchWebsitesInfoUseCase(faviconDownloader: FaviconDownloader(),
                                                                urlSession: URLSession.shared)
        let websitesListVC = WebsitesListVC()
        websitesListVC.fetchWebsitesInfoUseCase = fetchWebsitesInfoUseCase
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let nav = storyboard.instantiateInitialViewController() as? UINavigationController
        nav?.viewControllers = [websitesListVC]
        window?.rootViewController = nav

        return true
    }

}
