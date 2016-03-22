//
//  LaunchRouter.swift
//  P-effect
//
//  Created by AndrewPetrov on 3/3/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import Foundation

class LaunchRouter: AlertManagerDelegate, FeedPresenter {
    
    private(set) var locator: ServiceLocator!
    private(set) weak var currentViewController: UIViewController!
    
    init() {
        locator = ServiceLocator()
        locator.registerService(PostService())
        locator.registerService(EffectsLoaderService())
        locator.registerService(UserService())
        locator.registerService(ValidationService())
        locator.registerService(AuthService())
        locator.registerService(ImageLoaderService())
        locator.registerService(ReachabilityService())
        locator.registerService(ComplaintService())
        locator.registerService(ActivityService())
    }
}

extension LaunchRouter: Router {
    
    typealias Context = UIWindow
    
    func execute(context: UIWindow) {
        let launchViewController = LaunchViewController.create()
        launchViewController.setRouter(self)
        currentViewController = launchViewController
        let navigationController = AppearanceNavigationController(rootViewController: launchViewController)
        context.rootViewController = navigationController
        
        if User.isAbsent {
            let authService: AuthService = locator.getService()
            authService.anonymousLogIn(
                completion: { [weak self] _ in
                    self?.presentFeed(context)
                },
                failure: { error in
                    if let error = error {
                        handleError(error)
                    }
            })
        } else {
            presentFeed(context)
        }
    }
    
    private func presentFeed(context: UIWindow) {
        let feedRouter = FeedRouter(locator: locator)
        feedRouter.execute(context)
    }
    
}
