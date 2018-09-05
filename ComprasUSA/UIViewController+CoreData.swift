//
//  UIViewController+CoreData.swift
//  ComprasUSA
//
//  Created by Vitor Ruiz on 04/09/2018.
//  Copyright © 2018 Vitor Ruiz e Ikaro Neves. All rights reserved.
//

import UIKit
import CoreData

extension UIViewController {
    var context: NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }
}
