//
//  TransactionsViewController.swift
//  Bemobile
//
//  Created by Albert on 29/01/2021.
//  Copyright © 2021 Albert. All rights reserved.
//

import UIKit
class Rate: Codable
{
    var from: String
    var to: String
    var rate: String
}
typealias Rates = [Rate]

class TransactionsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var totalProductoLabel: UILabel!
    @IBOutlet var precioTotalLabel: UILabel!
    @IBOutlet var transaccionesTableView: UITableView!
    @IBOutlet var monedaLabel: UILabel!
    
    var values: [Products] = []
    var ratios: [Rates] = []
    var filteredData: [Products]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBarItems()
        filteredData = values
        cargarDatos()
        cargarLabels()
        
        searchBar.delegate = self
        transaccionesTableView.delegate = self
        transaccionesTableView.dataSource = self
    }
    
    func setupNavigationBarItems(){
        let labelTitle = UILabel()
        labelTitle.text = "Transacciones"
        labelTitle.font = UIFont(name: "HelveticaNeue", size: 30)
        labelTitle.textColor = .black
        navigationItem.titleView = labelTitle
        navigationController?.navigationBar.backgroundColor = .white
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.tintColor = .black
    }
    
    func cargarDatos(){
        
        let url="http://quiet-stone-2094.herokuapp.com/rates.json"
        let request = URL(string: url)
        guard request != nil else{
            return
        }
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request!) { (data, response, error)in
            
            if error == nil && data != nil {
                let decoder = JSONDecoder()
                
                do {
                    let json = try decoder.decode(Rates.self, from: data!)
                    
                    self.ratios = [json]
                    
                    DispatchQueue.main.async {
                        self.calculateTotalAmound()
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
    
    func cargarLabels(){
        precioTotalLabel.text = "Precio Total:"
        monedaLabel.text = "EUR"
    }
    
    // MARK: - Table view data source
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // return the number of rows
        return filteredData.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TransaccionesCell", for: indexPath) as! TransaccionesTableViewCell
        
        for valores in filteredData[indexPath.row]{
            let valor = Double(valores.amount)!
            let valueStr = formatedNumber(number: valor)
            cell.amountLabelCell.text = valueStr
            cell.currencyLabelCell.text = valores.currency
            cell.skuLabelCell.text = valores.sku
        }
        cell.backgroundColor = UIColor.clear
        
        return cell
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func calculateTotalAmound(){
        var valorTotal = Double()
        for pr in self.values{
            for producs in pr{
                if producs.currency == "AUD" {
                    let valor = convertCurrencyAUD(amount: producs.amount, currency: producs.currency)
                    valorTotal = valorTotal + valor
                }else if producs.currency == "CAD"{
                    let valor = convertCurrencyCAD(amount: producs.amount, currency: producs.currency)
                    valorTotal = valorTotal + valor
                }else if producs.currency == "USD"{
                    let valor = convertCurrencyUSD(amount: producs.amount, currency: producs.currency)
                    valorTotal = valorTotal + valor
                }else{
                    let valor = Double(producs.amount)
                    valorTotal = valorTotal + valor!
                }
            }
        }
        
        //pasamos nuestro valor al método para formatear
        let doubleStr = formatedNumber(number: valorTotal)
        //Añadimos el valor del precio al label totalProductoLabel
        totalProductoLabel.text = doubleStr
        
    }
    
    // MARK: Convert Amount
    
    func convertCurrencyAUD (amount:String, currency: String)-> Double{
        var precio = Double(amount)
        for ratioArray in self.ratios {
            for ratio in ratioArray{
                if ratio.from == currency && ratio.to == "EUR" {
                    precio = self.calculateRate(amount: amount, rate: ratio.rate)
                }else if ratio.from == currency && ratio.to == "USD"{
                    precio = self.calculateRate(amount: amount, rate: ratio.rate)
                    for ratio in ratioArray{
                        if ratio.from == "USD" && ratio.to == "EUR" {
                            precio = self.calculateRate(amount: amount, rate: ratio.rate)
                        }else if ratio.from == "USD" && ratio.to == "CAD"{
                            precio = self.calculateRate(amount: amount, rate: ratio.rate)
                            for ratio in ratioArray{
                                if ratio.from == "CAD" && ratio.to == "EUR" {
                                    precio = self.calculateRate(amount: amount, rate: ratio.rate)
                                }
                            }
                        }
                    }
                }else if ratio.from == currency && ratio.to == "CAD"{
                    precio = self.calculateRate(amount: amount, rate: ratio.rate)
                    for ratio in ratioArray{
                        if ratio.from == "CAD" && ratio.to == "EUR" {
                            precio = self.calculateRate(amount: amount, rate: ratio.rate)
                        }else if ratio.from == "CAD" && ratio.to == "USD"{
                            precio = self.calculateRate(amount: amount, rate: ratio.rate)
                            for ratio in ratioArray{
                                if ratio.from == "USD" && ratio.to == "EUR" {
                                    precio = self.calculateRate(amount: amount, rate: ratio.rate)
                                }
                            }
                        }
                    }
                }
            }
        }
        return precio!
    }
    
    func convertCurrencyCAD(amount:String, currency: String)-> Double{
        var precio = Double(amount)
        for ratioArray in self.ratios {
            for ratio in ratioArray{
                if ratio.from == currency && ratio.to == "EUR" {
                    precio = self.calculateRate(amount: amount, rate: ratio.rate)
                }else if ratio.from == currency && ratio.to == "USD"{
                    precio = self.calculateRate(amount: amount, rate: ratio.rate)
                    for ratio in ratioArray{
                        if ratio.from == "USD" && ratio.to == "EUR" {
                            precio = self.calculateRate(amount: amount, rate: ratio.rate)
                        }else if ratio.from == "USD" && ratio.to == "AUD"{
                            precio = self.calculateRate(amount: amount, rate: ratio.rate)
                            for ratio in ratioArray{
                                if ratio.from == "AUD" && ratio.to == "EUR" {
                                    precio = self.calculateRate(amount: amount, rate: ratio.rate)
                                }
                            }
                        }
                    }
                }else if ratio.from == currency && ratio.to == "AUD"{
                    precio = self.calculateRate(amount: amount, rate: ratio.rate)
                    for ratio in ratioArray{
                        if ratio.from == "AUD" && ratio.to == "EUR" {
                            precio = self.calculateRate(amount: amount, rate: ratio.rate)
                        }else if ratio.from == "AUD" && ratio.to == "USD"{
                            precio = self.calculateRate(amount: amount, rate: ratio.rate)
                            for ratio in ratioArray{
                                if ratio.from == "USD" && ratio.to == "EUR" {
                                    precio = self.calculateRate(amount: amount, rate: ratio.rate)
                                }
                            }
                        }
                    }
                }
            }
        }
        return precio!
    }
    
    func convertCurrencyUSD(amount:String, currency: String)-> Double{
        var precio = Double(amount)
        for ratioArray in self.ratios {
            for ratio in ratioArray{
                if ratio.from == currency && ratio.to == "EUR" {
                    precio = self.calculateRate(amount: amount, rate: ratio.rate)
                }else if ratio.from == currency && ratio.to == "AUD"{
                    precio = self.calculateRate(amount: amount, rate: ratio.rate)
                    for ratio in ratioArray{
                        if ratio.from == "AUD" && ratio.to == "EUR" {
                            precio = self.calculateRate(amount: amount, rate: ratio.rate)
                        }else if ratio.from == "AUD" && ratio.to == "CAD"{
                            precio = self.calculateRate(amount: amount, rate: ratio.rate)
                            for ratio in ratioArray{
                                if ratio.from == "CAD" && ratio.to == "EUR" {
                                    precio = self.calculateRate(amount: amount, rate: ratio.rate)
                                }
                            }
                        }
                    }
                }else if ratio.from == currency && ratio.to == "CAD"{
                    precio = self.calculateRate(amount: amount, rate: ratio.rate)
                    for ratio in ratioArray{
                        if ratio.from == "CAD" && ratio.to == "EUR" {
                            precio = self.calculateRate(amount: amount, rate: ratio.rate)
                        }else if ratio.from == "CAD" && ratio.to == "AUD"{
                            precio = self.calculateRate(amount: amount, rate: ratio.rate)
                            for ratio in ratioArray{
                                if ratio.from == "AUD" && ratio.to == "EUR" {
                                    precio = self.calculateRate(amount: amount, rate: ratio.rate)
                                }
                            }
                        }
                    }
                }
            }
        }
        return precio!
    }
    // Función para calcular el rate
    func calculateRate(amount:String, rate: String)-> Double{
        var precio = Double(amount)
        if rate >= "1"{
            precio = precio! * Double(rate)!
        }else{
            precio = precio! / Double(rate)!
        }
        return precio!
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
                    if productos.contains(searchText.lowercased()){
                        filteredData.append([por])
                    }
                }
            }
        }
        self.transaccionesTableView.reloadData()
    }
    
    // MARK: FormatedNumber
    
    func formatedNumber(number: Double)-> String{
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        let numberString = formatter.string(for:number)
        
        return numberString!
        
    }
    
}


