//
//  NASATabBarViewController.swift
//  NASAPictureOfTheDay
//
//  Created by Leelajyothi Ramala on 27/02/22.
//

import UIKit
import SwiftUI

class NASATabBarViewController: UITabBarController {
    lazy var viewModel = NASAPictureDetailsViewModel(withAPIProvider: NASAFeaturePictureDetailsAPIManager())

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let firstViewController = self.viewControllers?.first as? NASAPictureOfTheDayViewController {
            firstViewController.viewModel = self.viewModel
        }
            
        let favouriteViewController = UIHostingController(rootView: FavourtieNASAPicturesView().environmentObject(viewModel))
        let tabItem = UITabBarItem(tabBarSystemItem: .favorites, tag: 35)
        favouriteViewController.tabBarItem = tabItem
        self.viewControllers?.append(favouriteViewController)
    }
}
