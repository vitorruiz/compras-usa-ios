//
//  SettingsViewController.swift
//  ComprasUSA
//
//  Created by Vitor Ruiz on 04/09/2018.
//  Copyright © 2018 Vitor Ruiz e Ikaro Neves. All rights reserved.
//

import UIKit
import CoreData

class SettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let KEY_DOLAR = "key_dolar"
    let KEY_IOF = "key_iof"
    
    @IBOutlet weak var txtDolar: UITextField!
    @IBOutlet weak var txtIOF: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    var fetchedResultController: NSFetchedResultsController<State>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        txtDolar.addDoneCancelToolbar()
        txtIOF.addDoneCancelToolbar()
        
        loadStates()
        
        txtDolar.text = "\(UserDefaults.standard.value(forKey: KEY_DOLAR) as? Double ?? 0)"
        txtIOF.text = "\(UserDefaults.standard.value(forKey: KEY_IOF) as? Double ?? 0)"
        
        txtDolar.addTarget(self, action: #selector(updateDolarSetting(_:)), for: UIControlEvents.editingChanged)
        
        txtIOF.addTarget(self, action: #selector(updateIOFSetting(_:)), for: UIControlEvents.editingChanged)
    }

    @objc func updateDolarSetting(_ textField: UITextField) {
        if let txtDolar = textField.text, let dolar = Double(txtDolar){
            UserDefaults.standard.set(dolar, forKey: KEY_DOLAR)
        }
    }
    
    @objc func updateIOFSetting(_ textField: UITextField) {
        if let txtIOF = textField.text, let dolar = Double(txtIOF){
            UserDefaults.standard.set(dolar, forKey: KEY_IOF)
        }
    }
    
    func loadStates() {
        let fetchRequest: NSFetchRequest<State> = State.fetchRequest()
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
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        let statesCount = fetchedResultController.fetchedObjects?.count ?? 0
        
        if statesCount > 0 {
            tableView.backgroundView = nil
            tableView.separatorStyle = .singleLine;
            return 1
        }
        else {
            let emptyLabel = UILabel(frame: CGRect(origin: CGPoint(x: 0,y :0), size: CGSize(width: self.view.bounds.size.width, height: self.view.bounds.size.height)))
            emptyLabel.text = "Lista de estados vazia!"
            emptyLabel.textColor = UIColor.black
            emptyLabel.numberOfLines = 0;
            emptyLabel.textAlignment = .center;
            emptyLabel.font = UIFont(name: "TrebuchetMS", size: 18)
            emptyLabel.sizeToFit()
            
            tableView.backgroundView = emptyLabel
            tableView.separatorStyle = .none;
            return 0;
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultController.fetchedObjects?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        let state = fetchedResultController.object(at: indexPath)
        
        cell.textLabel?.text = state.name
        cell.detailTextLabel?.text = "\(state.tax) %"
            //String(format: "U$ %.2f", state.tax)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let state = fetchedResultController.object(at: indexPath)
        showAlertFor(state)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let state = fetchedResultController.object(at: indexPath)
            do {
                context.delete(state)
                try context.save()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    @IBAction func addState(_ sender: UIButton) {
        showAlertFor(nil)
    }
    
    func showAlertFor(_ state: State?) {
        let title = state == nil ? "Adicionar" : "Editar"
        let message = state == nil ? "adicionado" : "editado"
        let alert = UIAlertController(title: title, message: "Digite abaixou os dados do item a ser \(message)", preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            textField.placeholder = "Nome"
            textField.autocapitalizationType = .words
            textField.text = state?.name
        }
        alert.addTextField { (textField) in
            textField.placeholder = "Taxa"
            textField.keyboardType = .decimalPad
            textField.text = state?.tax.description
        }
        
        let okAction = UIAlertAction(title: title, style: .default) { (action) in
            guard let name = alert.textFields?.first?.text,
                let tax = alert.textFields?.last?.text,
                !name.isEmpty, !tax.isEmpty else {return}
            
            let item = state ?? State(context: self.context)
            item.name = name
            item.tax = Double(tax) ?? 0
            
            do {
                try self.context.save()
            } catch {
                print(error.localizedDescription)
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
}

extension SettingsViewController: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.reloadData()
    }
}
