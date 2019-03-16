//
//  TabBarViewController.swift
//  kush
//
//  Created by Daniel on 3/15/19.
//  Copyright © 2019 admin2. All rights reserved.
//

import UIKit

class TabBarViewController: UITabBarController {
    
    @IBOutlet weak var myTabBar: UITabBar?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        myTabBar?.tintColor = UIColor.white
        tabBarItem.title = ""
        
        setTabBarItems()
        
    }
    
    func setTabBarItems(){
        
        let myTabBarItem1 = (self.tabBar.items?[0])! as UITabBarItem
        myTabBarItem1.image = UIImage(named: "imgs/placeholder.png")?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        myTabBarItem1.selectedImage = UIImage(named: "imgs/placeholder.png")?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        myTabBarItem1.title = "Locations"
        myTabBarItem1.imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        let myTabBarItem2 = (self.tabBar.items?[1])! as UITabBarItem
        myTabBarItem2.image = UIImage(named: "imgs/moon.png")?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        myTabBarItem2.selectedImage = UIImage(named: "imgs/moon.png")?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        myTabBarItem2.title = "Sleep"
        myTabBarItem2.imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        
        let myTabBarItem3 = (self.tabBar.items?[2])! as UITabBarItem
        myTabBarItem3.image = UIImage(named: "imgs/footstep.png")?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        myTabBarItem3.selectedImage = UIImage(named: "imgs/footstep.png")?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        myTabBarItem3.title = "Steps"
        myTabBarItem3.imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        

        
    }
}
