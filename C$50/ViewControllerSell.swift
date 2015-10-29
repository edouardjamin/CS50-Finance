//
//  ViewControllerSell.swift
//  C$50
//
//  Created by Edouard Jamin on 11/08/15.
//  Copyright © 2015 Gobu. All rights reserved.
//

import UIKit
import CoreData

class ViewControllerSell: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    @IBOutlet weak var shareSymbol: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var sharesLabel: UILabel!
    
    
    @IBOutlet weak var sharePicker: UIPickerView!

    @IBAction func backButton(sender: AnyObject) {
    }
    
    
    //MARK  -Outlets and properties
    var pickerData = [String]()
    
    enum PickerComponent :Int{
        case size = 0
    }
    
    // prototype
    var sharePrice :Double = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var number :Double = 0.00
        
        _ = lookup(shareSelected) { name, symbol, price in
            dispatch_async(dispatch_get_main_queue()) {
                self.shareSymbol.text = symbol
                self.priceLabel.text = price
            }
        }
        
        let appDel :AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let context :NSManagedObjectContext = appDel.managedObjectContext
        
        let request = NSFetchRequest(entityName: "Shares")
        request.returnsObjectsAsFaults = false
        
        
        do {
            let results = try context.executeFetchRequest(request)
            
            if results.count > 0 {
                for result in results as! [NSManagedObject] {
                    if result.valueForKey("symbol") as! String == shareSelected {
                        number = result.valueForKey("shares")! as! Double
                        self.numberLabel.text = String(Int(number))
                    }
                }
            }
        } catch {
            print(error)
        }
        
        _ = price(shareSelected) { price in
            dispatch_async(dispatch_get_main_queue()) {
                self.sharePrice = price
                let worthInt = price * number
                let worth = String(worthInt)
                self.sharesLabel.text = "$\(worth)"
            }
        }
        
        for var i :Int = 1; i <= Int(number); i++ {
            self.pickerData.append("\(i)")
        }
        
        sharePicker.delegate = self
        sharePicker.dataSource = self
        sharePicker.selectRow(0, inComponent: PickerComponent.size.rawValue, animated: false)
        
    }
    //MARK -Delgates and DataSource
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
    
    @IBAction func sellBouton(sender: AnyObject) {
        let sharesSell = pickerData[sharePicker.selectedRowInComponent(0)]
        var ownedShares :Int = 0
        
        let appDel :AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let context :NSManagedObjectContext = appDel.managedObjectContext
        
        let request = NSFetchRequest(entityName: "Shares")
        request.returnsObjectsAsFaults = false
        
        do {
            
            let results = try context.executeFetchRequest(request)
            
            if results.count > 0 {
                for result in results as! [NSManagedObject] {
                    if result.valueForKey("symbol") as! String == shareSelected {
                        ownedShares = result.valueForKey("shares") as! Int
                    }
                }
            }
        } catch {
            print(error)
        }
        
            // retreive value
            let fetchRequest = NSFetchRequest(entityName: "Shares")
            fetchRequest.predicate = NSPredicate(format: "symbol = %@", shareSelected)
            
            do {
                if let fetchResults = try appDel.managedObjectContext.executeFetchRequest(fetchRequest) as? [NSManagedObject] {
                    if fetchResults.count != 0{
                        
                        let managedObject = fetchResults[0]
                        managedObject.setValue(ownedShares - Int(sharesSell)!, forKey: "shares")
                        
                        // update cash
                        let earned = Double(Int(sharesSell)!) * sharePrice
                        earn(earned)
                        
                        // update history
                        insert("SELL", symbol: shareSelected, price: sharePrice, shares: Int(sharesSell)!)
                        
                        do {
                            try context.save()
                        } catch {
                            print(error)
                        }
                    }
                }
            } catch {
                print(error)
            }
        
            // check if ownedShares = 0, and delete if so
            do {
            
            let results = try context.executeFetchRequest(request)
            
            if results.count > 0 {
                for result in results as! [NSManagedObject] {
                    if result.valueForKey("shares") as! Int == 0 {
                        context.deleteObject(result)
                        do {
                            try context.save()
                        } catch {
                            print(error)
                        }
                    }
                }
            }
        } catch {
            print(error)
        }
        
        // back to previous
        navigationController?.popViewControllerAnimated(true)

    
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */


}