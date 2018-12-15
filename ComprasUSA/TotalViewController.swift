//
//  TotalViewController.swift
//  ComprasUSA
//
//  Created by Vitor Ruiz on 06/09/2018.
//  Copyright © 2018 Vitor Ruiz e Ikaro Neves. All rights reserved.
//

import UIKit
import CoreData

class TotalViewController: UIViewController {
    @IBOutlet weak var lblTotalDolar: UILabel!
    @IBOutlet weak var lblTotalReal: UILabel!
    
    var fetchedResultController: NSFetchedResultsController<Product>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadProducts()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateValues()
    }
    
    func loadProducts() {
        let fetchRequest: NSFetchRequest<Product> = Product.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchedResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultController.delegate = self
        
        do {
            try fetchedResultController.performFetch()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func updateValues() {
        guard let products = fetchedResultController.fetchedObjects, let dolarQuotation = UserDefaults.standard.value(forKey: "key_dolar") as? Double, let iof = UserDefaults.standard.value(forKey: "key_iof") as? Double else {return}
        
        var totalDolar = 0.0
        var totalReal = 0.0
        
        for product in products {
            totalDolar += (product.price + (product.price * (product.state!.tax/100)))
            
            if product.card {
                totalReal += ((product.price + (product.price * (product.state!.tax/100))) * dolarQuotation) * ((iof / 100) + 1)
            }
            else {
                totalReal += ((product.price + (product.price * (product.state!.tax/100))) * dolarQuotation)
            }
        }
        
        lblTotalReal.text = "R$ \(totalReal)"
        //String(format: "R$ %.2f", totalReal)
        lblTotalDolar.text = "U$ \(totalDolar)"
        //String(format: "U$ %.2f", totalDolar)
    }
}

extension TotalViewController: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        updateValues()
    }
}
