//
//  ProductRegisterViewController.swift
//  ComprasUSA
//
//  Created by Vitor Ruiz on 04/09/2018.
//  Copyright © 2018 Vitor Ruiz e Ikaro Neves. All rights reserved.
//

import UIKit

class ProductRegisterViewController: UIViewController {
    @IBOutlet weak var txtName: UITextField!
    @IBOutlet weak var ivImage: UIImageView!
    @IBOutlet weak var txtState: UITextField!
    @IBOutlet weak var txtPrice: UITextField!
    @IBOutlet weak var swtCard: UISwitch!
    @IBOutlet weak var btnSave: UIButton!
    
    var product: Product!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if product != nil {
            btnSave.setTitle("Editar", for: .normal)
            
            txtName.text = product.name
            txtState.text = product.state?.name
            txtPrice.text = "\(product.price)"
            swtCard.isOn = product.card
        }
    }

    @IBAction func saveProduct(_ sender: UIButton) {
        
        //TODO: validação de campos nulos
        
        if product == nil {
            product = Product(context: context)
        }
        
        product.name = txtName.text!
        product.price = Double(txtPrice.text!) ?? 0
        product.card = swtCard.isOn
        
        do {
            try context.save()
            navigationController?.popViewController(animated: true)
        } catch {
            print(error.localizedDescription)
        }
    }
}
