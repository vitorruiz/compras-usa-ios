//
//  ProductRegisterViewController.swift
//  ComprasUSA
//
//  Created by Vitor Ruiz on 04/09/2018.
//  Copyright © 2018 Vitor Ruiz e Ikaro Neves. All rights reserved.
//

import UIKit
import CoreData

class ProductRegisterViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    @IBOutlet weak var txtName: UITextField!
    @IBOutlet weak var ivImage: UIImageView!
    @IBOutlet weak var txtState: UITextField!
    @IBOutlet weak var txtPrice: UITextField!
    @IBOutlet weak var swtCard: UISwitch!
    @IBOutlet weak var btnSave: UIButton!
    
    var fetchedResultController: NSFetchedResultsController<State>!
    
    var product: Product!
    var selectedState: State?
    
    let pickerView = UIPickerView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        pickerView.showsSelectionIndicator = true
        txtState.inputView = pickerView
        txtState.addDoneCancelToolbar(onDone: (target: self, action: #selector(donePicker)))
        txtName.addDoneCancelToolbar()
        txtPrice.addDoneCancelToolbar()
        
        pickerView.delegate = self
        
        if product != nil {
            btnSave.setTitle("Editar", for: .normal)
            
            selectedState = product.state
            
            txtName.text = product.name
            txtState.text = product.state?.name
            txtPrice.text = "\(product.price)"
            swtCard.isOn = product.card
            ivImage.image = product.image as? UIImage
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        loadStates()
    }

    func loadStates() {
        let fetchRequest: NSFetchRequest<State> = State.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchedResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        //fetchedResultController.delegate = self
        
        do {
            try fetchedResultController.performFetch()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    @objc func donePicker() {
        if let states = fetchedResultController.fetchedObjects, !states.isEmpty {
            selectedState = states[pickerView.selectedRow(inComponent: 0)]
            txtState.text = selectedState?.name
        }
        self.view.endEditing(false)
    }
    
    @objc func dismissPicker() {
        self.view.endEditing(false)
    }
    
    @IBAction func saveProduct(_ sender: UIButton) {
        
        guard let name = txtName.text, let txtPrice = txtPrice.text, let price = Double(txtPrice),let image = ivImage.image, selectedState != nil, !name.isEmpty, !txtPrice.isEmpty
            else {showMandatoryWarning(); return}
        
        if product == nil {
            product = Product(context: context)
        }
        
        product.name = name
        product.price = price
        product.card = swtCard.isOn
        product.image = image
        selectedState!.addToProducts(product)
        
        do {
            try context.save()
            navigationController?.popViewController(animated: true)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func showMandatoryWarning() {
        let alert = UIAlertController(title: "Aviso!", message: "Todos os campos são obrigatórios", preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(okAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func addImage(_ sender: UIButton) {
        let alert = UIAlertController(title: "Selecionar imagem", message: "De onde você quer escolher a imagem?", preferredStyle: .actionSheet)
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let cameraAction = UIAlertAction(title: "Câmera", style: .default) { (action) in
                self.selectPicture(sourceType: .camera)
            }
            alert.addAction(cameraAction)
        }
        
        let libraryAction = UIAlertAction(title: "Biblioteca de fotos", style: .default) { (action) in
            self.selectPicture(sourceType: .photoLibrary)
        }
        alert.addAction(libraryAction)
        
        let photosAction = UIAlertAction(title: "Álbum de fotos", style: .default) { (action) in
            self.selectPicture(sourceType: .savedPhotosAlbum)
        }
        alert.addAction(photosAction)
        
        let cancelAction = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        
        
        present(alert, animated: true, completion: nil)
    }
    
    func selectPicture(sourceType: UIImagePickerControllerSourceType) {
        let imagePicker = UIImagePickerController()
        
        imagePicker.sourceType = sourceType
        imagePicker.delegate = self
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return fetchedResultController.fetchedObjects?.count ?? 0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return fetchedResultController.fetchedObjects?[row].name
    }
}

extension ProductRegisterViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            
            let aspectRatio = image.size.width / image.size.height
            let maxSize: CGFloat = 500
            var smallSize: CGSize
            if aspectRatio > 1 {
                smallSize = CGSize(width: maxSize, height: maxSize/aspectRatio)
            } else {
                smallSize = CGSize(width: maxSize*aspectRatio, height: maxSize)
            }
            
            UIGraphicsBeginImageContext(smallSize)
            image.draw(in: CGRect(x: 0, y: 0, width: smallSize.width, height: smallSize.height))
            ivImage.image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        }
        
        dismiss(animated: true, completion: nil)
        
    }
    
}
