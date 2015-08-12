//
//  ViewController.swift
//  C$50
//
//  Created by Edouard Jamin on 07/08/15.
//  Copyright © 2015 Gobu. All rights reserved.
//

import UIKit
import CoreData

func lookup(entry : NSString, completion: ((name :String, symbol :String, price :String) -> Void)) {
    
    /**
    *
    * WARNING
    * In this function, everything (including the price) will be returned as a string. Use func price() if needed
    * @0.1
    *
    **/
    
    // define return values
    var name = String()
    var symbol = String()
    var price = String()
    
    // define URL
    let url = NSURL(string: "http://yahoojson.gobu.fr/symbol.php?symbol=\(entry)")!
    
    let task = NSURLSession.sharedSession().dataTaskWithURL(url) { (data, response, error) in
        if let urlContent = data {
            do {
                let jsonResult = try NSJSONSerialization.JSONObjectWithData(urlContent, options: NSJSONReadingOptions.MutableContainers)
                
                name = jsonResult["name"] as! String
                symbol = jsonResult["symbol"] as! String
                price = jsonResult["price"]!!.stringValue as String
                completion(name: name, symbol: symbol, price: price)
            } catch {
                print(error)
            }
        }
    }
    
    // run the task
    task.resume()
}

func price(entry : NSString, completion: ((price :Double) -> Void)) {
    
    /**
    *
    * WARNING
    * This function needs lookup to work
    * @0.1
    *
    **/
    
    // initate return value
    var priceInt :Double = 0
    
    // run lookup
    _ = lookup(shareSelected) { name, symbol, price in
        dispatch_async(dispatch_get_main_queue()) {
            let priceString :String = price
            priceInt = NSString(string: priceString).doubleValue
            completion(price: priceInt)
        }
    }
    
}

func buy(entry :NSString, number :Int, price :Double) -> Void
{
    // get shares wanted
    let sharesNumber = number;
    
    // protype
    var ownedShares :Int = 0
    
    // declare exists
    var exist :Bool = false
    
    // connect to CoreData
    let context = connectToCoreData()
    let request = NSFetchRequest(entityName: "Shares")
    request.returnsObjectsAsFaults = false
    
    // check if shares already owned and if so, how many
    do {
        let results = try context.executeFetchRequest(request)
        
        if results.count > 0 {
            for result in results as! [NSManagedObject] {
                if result.valueForKey("symbol") as! String == entry {
                    exist = true
                    ownedShares = result.valueForKey("shares") as! Int
                }
            }
        }
    } catch {
        print(error)
    }
    
    // declare enough money
    var enoughMoney :Bool = true
    
    // connect to CoreData
    let requestCash = NSFetchRequest(entityName: "Users")
    requestCash.returnsObjectsAsFaults = false
    
    // check cash
    var currentCash = 0
    do {
        let results = try context.executeFetchRequest(requestCash)
        
        if results.count > 0 {
            for result in results as! [NSManagedObject] {
                currentCash = result.valueForKey("cash") as! Int
            }
        }
        
    } catch {
        print(error)
    }
    
    // check enough cash
    if Int(price) * sharesNumber > currentCash {
        enoughMoney = false
    }
    
    
    // if no shares owned
    if exist == false && enoughMoney == true {
        let newShare = NSEntityDescription.insertNewObjectForEntityForName("Shares", inManagedObjectContext: context)
        
        newShare.setValue(sharesNumber, forKey: "shares")
        newShare.setValue(entry, forKey: "symbol")
        
        do {
            try context.save()
        } catch {
            print("Unable to save")
        }
        
        let request = NSFetchRequest(entityName: "Shares")
        do {
            let _ = try context.executeFetchRequest(request)
        } catch {
            print("Unable to print")
        }
        spend(price * Double(sharesNumber))
    }
    
    // if shares owned
    if exist == true && enoughMoney == true {
        let fetchRequest = NSFetchRequest(entityName: "Shares")
        fetchRequest.predicate = NSPredicate(format: "symbol = %@", entry)
        
        do {
            if let fetchResults = try context.executeFetchRequest(fetchRequest) as? [NSManagedObject] {
                if fetchResults.count != 0{
                    
                    let managedObject = fetchResults[0]
                    managedObject.setValue(sharesNumber + ownedShares, forKey: "shares")
                    
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
        spend(price * Double(sharesNumber))
    }
}

func connectToCoreData() -> NSManagedObjectContext
{
    let appDel :AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    let context :NSManagedObjectContext = appDel.managedObjectContext
    
    return context
}

func earn(amount :Double) -> Void
{
    let context = connectToCoreData()
    
    let request = NSFetchRequest(entityName: "Users")
    request.returnsObjectsAsFaults = false
    
    var exist :Bool = false
    var currentCash :Double = 0.00
    
    do {
        let results = try context.executeFetchRequest(request)
        for result in results as! [NSManagedObject] {
            if result.valueForKey("cash") != nil {
                exist = true
                currentCash = result.valueForKey("cash") as! Double
            }
        }
    } catch {
        print(error)
    }
    
    if exist == false
    {
        let newShare = NSEntityDescription.insertNewObjectForEntityForName("Users", inManagedObjectContext: context)
        
        newShare.setValue(amount, forKey: "cash")
        
        do {
            try context.save()
        } catch {
            print("Unable to save")
        }
    }
    
    if exist == true
    {
        let fetchRequest = NSFetchRequest(entityName: "Users")
        
        do {
            if let fetchResults = try context.executeFetchRequest(fetchRequest) as? [NSManagedObject] {
                if fetchResults.count != 0 {
                    
                    let managedObject = fetchResults[0]
                    let newCash = currentCash + amount
                    managedObject.setValue(newCash, forKey: "cash")
                    
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
    }
}

func spend(amount :Double) -> Void
{
    let context = connectToCoreData()
    
    let request = NSFetchRequest(entityName: "Users")
    request.returnsObjectsAsFaults = false
    
    var currentCash :Double = 0.00
    
    do {
        let results = try context.executeFetchRequest(request)
        for result in results as! [NSManagedObject] {
            if result.valueForKey("cash") != nil {
                currentCash = result.valueForKey("cash") as! Double
            }
        }
    } catch {
        print(error)
    }
    
        let fetchRequest = NSFetchRequest(entityName: "Users")
        
        do {
            if let fetchResults = try context.executeFetchRequest(fetchRequest) as? [NSManagedObject] {
                if fetchResults.count != 0 {
                    
                    let managedObject = fetchResults[0]
                    let newCash = currentCash - amount
                    managedObject.setValue(newCash, forKey: "cash")
                    
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
}


class ViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var symbolField: UITextField!
    
    @IBOutlet weak var quoteLabel: UILabel!
    @IBOutlet weak var symbolLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var cashLabel: UILabel!
    
    @IBAction func addCash(sender: AnyObject) {
        
        earn(1000)
        
        let context = connectToCoreData()
        let request = NSFetchRequest(entityName: "Users")
        request.returnsObjectsAsFaults = false
        
        do {
            let results = try context.executeFetchRequest(request)
            for result in results as! [NSManagedObject] {
                    cashLabel.text = String(result.valueForKey("cash")!)
            }
        } catch {
            print(error)
        }
    }
    
    @IBAction func printCash(sender: AnyObject) {
        
        let context = connectToCoreData()
        
        let fetchRequest = NSFetchRequest(entityName: "Users")
        fetchRequest.returnsObjectsAsFaults = false
        
        do {
            let results = try context.executeFetchRequest(fetchRequest)
            for result in results as! [NSManagedObject] {
                print(result.valueForKey("cash")!)
            }
        } catch {
            print(error)
        }
    }
    

    @IBAction func removeCash(sender: AnyObject) {
        spend(1000)
        
        let context = connectToCoreData()
        let request = NSFetchRequest(entityName: "Users")
        request.returnsObjectsAsFaults = false
        
        do {
            let results = try context.executeFetchRequest(request)
            for result in results as! [NSManagedObject] {
                cashLabel.text = String(result.valueForKey("cash")!)
            }
        } catch {
            print(error)
        }
    }
    

    // get quote button
    @IBAction func getQuote(sender: AnyObject) {
        
        // get symbol asked
        let symbol = symbolField.text!
        
        // run the function
        _ = lookup(symbol) { name, symbol, price in
            dispatch_async(dispatch_get_main_queue()) {
                self.quoteLabel.text = name
                self.symbolLabel.text = symbol
                self.priceLabel.text = price
            }
        }
    }
    
    // buy 1 button
    @IBAction func buyButton(sender: AnyObject) {
        
        // get wanted symbol
        let symbol = symbolField.text!
        
        // get price of share
        var priceShare :Double = 0
        _ = lookup(symbol) { name, symbol, price in
            dispatch_async(dispatch_get_main_queue()) {
                priceShare = Double(price)!
                buy(symbol, number: 1, price: priceShare)
            }
        }
        
        
            }
    
    @IBAction func printButton(sender: AnyObject) {
        let appDel :AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        let context :NSManagedObjectContext = appDel.managedObjectContext
        
        let request = NSFetchRequest(entityName: "Shares")
        request.returnsObjectsAsFaults = false
        do {
            let results = try context.executeFetchRequest(request)
            
            if results.count > 0 {
                
                for result in results as! [NSManagedObject] {
                    print(result.valueForKey("shares")!)
                    print(result.valueForKey("symbol")!)
                }
            }
        } catch {
            print("Unable to print")
        }
    }
    
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(textField :UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.symbolField.delegate = self
        
        // update cashLabel as soon as loaded
        let context = connectToCoreData()
        let fetchRequest = NSFetchRequest(entityName: "Users")
        fetchRequest.returnsObjectsAsFaults = false
        
        do {
            let results = try context.executeFetchRequest(fetchRequest)
            for result in results as! [NSManagedObject] {
                cashLabel.text = String(result.valueForKey("cash")!)
            }
        } catch {
            print(error)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}