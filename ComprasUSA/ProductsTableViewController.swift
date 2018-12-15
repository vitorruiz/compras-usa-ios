//
//  ProductsTableViewController.swift
//  ComprasUSA
//
//  Created by Vitor Ruiz on 04/09/2018.
//  Copyright © 2018 Vitor Ruiz e Ikaro Neves. All rights reserved.
//

import UIKit
import CoreData

class ProductsTableViewController: UITableViewController {

    var fetchedResultController: NSFetchedResultsController<Product>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let fetchRequest: NSFetchRequest<Product> = Product.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchedResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultController.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadProducts()
    }
    
    func loadProducts() {
        do {
            try fetchedResultController.performFetch()
        } catch {
            print(error.localizedDescription)
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        
        let productsCount = fetchedResultController.fetchedObjects?.count ?? 0
        
        if productsCount > 0 {
            tableView.backgroundView = nil
            tableView.separatorStyle = .singleLine;
            return 1
        }
        else {
            let emptyLabel = UILabel(frame: CGRect(origin: CGPoint(x: 0,y :0), size: CGSize(width: self.view.bounds.size.width, height: self.view.bounds.size.height)))
            emptyLabel.text = "Sua lista está vazia!"
            emptyLabel.textColor = UIColor.black
            emptyLabel.numberOfLines = 0;
            emptyLabel.textAlignment = .center;
            emptyLabel.font = UIFont(name: "TrebuchetMS", size: 24)
            emptyLabel.sizeToFit()
            
            tableView.backgroundView = emptyLabel
            tableView.separatorStyle = .none;
            return 0;
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultController.fetchedObjects?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ProductTableViewCell
        
        let product = fetchedResultController.object(at: indexPath)
        
        cell.lblName.text = product.name
        cell.lblPrice.text = "U$ \(product.price)"
            //String(format: "U$ %.2f", product.price)
        cell.ivProduct.image = product.image as? UIImage

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ProductRegisterViewController") as! ProductRegisterViewController
        vc.product = fetchedResultController.object(at: indexPath)
        
        navigationController?.pushViewController(vc, animated: true)
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let product = fetchedResultController.object(at: indexPath)
            do {
                context.delete(product)
                try context.save()
            } catch {
                print(error.localizedDescription)
            }
        }  
    }
}

extension ProductsTableViewController: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.reloadData()
    }
}
