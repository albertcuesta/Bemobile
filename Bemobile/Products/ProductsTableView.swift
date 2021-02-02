//
//  ProductsTableView.swift
//  Bemobile
//
//  Created by Albert on 28/01/2021.
//  Copyright © 2021 Albert. All rights reserved.
//

import UIKit


// MARK: - Product
class Product: Codable {
    let sku: String
    let amount: String
    let currency: String
    
    init(_ dictionary: [String: Any]) {
        self.sku = dictionary["sku"] as? String ?? ""
        self.amount = dictionary["amount"] as? String ?? ""
        self.currency = dictionary["currency"] as? String ?? ""
        
    }
}

enum Currency: String, Codable {
    case aud = "AUD"
    case cad = "CAD"
    case eur = "EUR"
    case usd = "USD"
}



typealias Products = [Product]

class ProductsTableView:UITableViewController, UISearchBarDelegate
{
    var values: [Products] = []
    var array: NSMutableArray = NSMutableArray()
    var filteredData: [Products] = []
    var productosTotal : [Products] = []
    @IBOutlet var searchBar: UISearchBar!
    
    var dictionary:NSMutableDictionary = NSMutableDictionary()
    @IBOutlet var ProductsTableView: UITableView!
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        ProductsTableView.delegate = self
        ProductsTableView.dataSource = self
        searchBar.delegate = self
        setupNavigationBarItems()
        cargarDatos()
    }
    
    func setupNavigationBarItems(){
        let labelTitle = UILabel()
        labelTitle.text = "Productos"
        labelTitle.font = UIFont(name: "HelveticaNeue", size: 30)
        labelTitle.textColor = .black
        navigationItem.titleView = labelTitle
        navigationItem.setHidesBackButton(true, animated: true)
        navigationController?.navigationBar.backgroundColor = .white
        navigationController?.navigationBar.isTranslucent = false
    }
    //Descargamos los datos de la url
    func cargarDatos(){
        let url = "http://quiet-stone-2094.herokuapp.com/transactions.json"
        let request = URL(string: url)
        guard request != nil else{
            return
        }
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request!) { (data, response, error)in
            if error == nil && data != nil {
                let decoder = JSONDecoder()
                
                do {//creamos nuestro objeto json
                    let json = try decoder.decode(Products.self, from: data!)
                    
                    for pro in json{
                        
                        self.values.append([pro])
                    }
                    DispatchQueue.main.async {
                        self.filteredData = self.values
                        self.ProductsTableView.reloadData()
                    }
                    
                } catch let parseError {//manejamos el error
                    print("Error al parsear: \(parseError)")
                    let responseString = String(data: data!, encoding: .utf8)
                    print("respuesta : \(String(describing: responseString))")
                }
                
            }else{
                DispatchQueue.main.async {
                    //Crear nueva alerta
                    let dialogMessage = UIAlertController(title: "Atención!!", message: error?.localizedDescription, preferredStyle: .alert)
                    //Creamos botón Aceptar con contralador de acción
                    let ok = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
                        print("Ok button tapped")
                    })
                    //Agregamos botón "OK" con un mensaje
                    dialogMessage.addAction(ok)
                    // Present alert to user
                    self.present(dialogMessage, animated: true, completion: nil)
                }
            }
        }
        dataTask.resume()
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // return the number of rows
        return self.filteredData.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        for va in filteredData[indexPath.row]{
            //Añadimos el campo Sku a la label de la celda de la tabla
            cell.textLabel?.text = va.sku
        }
        cell.backgroundColor = UIColor.clear
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let Storyboard = UIStoryboard(name: "MainStoryboard", bundle: nil)
        let TvC = Storyboard.instantiateViewController(withIdentifier: "TransactionsViewController") as! TransactionsViewController
        for product in self.filteredData[indexPath.row]
        {
            let sku = product.sku
            for producs in self.values {
                for pr in producs{
                    if pr.sku == sku {
                        TvC.values.append([pr])
                    }
                }
            }
        }
        self.navigationController?.pushViewController(TvC, animated: true)
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
    }
    
    
    // MARK: Search Bar Config
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        filteredData = []
        if searchText == "" {
            filteredData = values
        }
        else{
            for prod in values{
                for por in prod {
                    let productos: NSMutableArray = NSMutableArray()
                    productos.add(por.sku)
                    
                    if productos.contains(searchText.uppercased()){
                        filteredData.append([por])
                    }
                }
            }
        }
        self.ProductsTableView.reloadData()
    }
}



