//
//  RootPageViewController.swift
//  CaliFire
//
//  Created by Guest account on 9/10/18.
//  Copyright © 2018 parraindustries. All rights reserved.
//

import UIKit
import SafariServices
import WebKit

class RootPageViewController: UIPageViewController, UIPageViewControllerDataSource {
    
    let webView = WKWebView()
    
    lazy var viewControllerList:[UIViewController] = {
        
        let sb = UIStoryboard(name: "Main", bundle: nil)
        
        let vc1 = sb.instantiateViewController(withIdentifier: "PracticesVC")
        
        let vc2 = sb.instantiateViewController(withIdentifier: "UpdatesVC")
        
        let vc3 = sb.instantiateViewController(withIdentifier: "DonateVC")
        
        return[vc1, vc2, vc3]
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //websiteButton.addTarget(self, action: "didTapGoogle", forControlEvents: .TouchUpInside)
        
        self.dataSource = self
        
        if let firstViewController = viewControllerList.first{
            
            self.setViewControllers([firstViewController], direction: .forward, animated: true, completion: nil)
            
        }
        
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        guard let vcIndex =  viewControllerList.index(of: viewController) else {return nil}
        
        let previousIndex = vcIndex - 1
        
        guard previousIndex >= 0 else {return nil}
        
        guard viewControllerList.count > previousIndex else {return nil}
        
        return viewControllerList[previousIndex]
        
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        guard let vcIndex = viewControllerList.index(of: viewController) else {return nil}
        
        let nextIndex = vcIndex + 1
        
        guard viewControllerList.count != nextIndex else {return nil}
        
        guard viewControllerList.count > nextIndex else {return nil}
        
        return viewControllerList[nextIndex]
        
    }
    
    
    
    
    
    
}
