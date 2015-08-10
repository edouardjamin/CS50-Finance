//
//  ViewController.swift
//  C$50
//
//  Created by Edouard Jamin on 07/08/15.
//  Copyright © 2015 Gobu. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {

    @IBOutlet weak var symbolField: UITextField!
    
    @IBOutlet weak var quoteLabel: UILabel!
    @IBOutlet weak var symbolLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
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
        
        // get shares wanted
        let sharesNumber = 1;
        
        // declare exists
        var exist :Bool = false
        
        let appDel :AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        let context :NSManagedObjectContext = appDel.managedObjectContext
        
        let request = NSFetchRequest(entityName: "Shares")
        request.returnsObjectsAsFaults = false
        
        do {
        
        let results = try context.executeFetchRequest(request)
        
        if results.count > 0 {
            for result in results as! [NSManagedObject] {
                if result.valueForKey("symbol") as! String == symbol {
                    exist = true
                    print(exist)
                }
            }
            }
            } catch {
                print(error)
            }
        
        if exist == false {
            let newShare = NSEntityDescription.insertNewObjectForEntityForName("Shares", inManagedObjectContext: context)
            
            newShare.setValue(sharesNumber, forKey: "shares")
            newShare.setValue(symbol, forKey: "symbol")
            
            do {
                try context.save()
            } catch {
                print("Unable to save")
            }
            
            let request = NSFetchRequest(entityName: "Shares")
            do {
                let result = try context.executeFetchRequest(request)
                print(result)
            } catch {
                print("Unable to print")
            }
        }
        
        if exist == true {
            let updateShare = NSEntityDescription.
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
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}
