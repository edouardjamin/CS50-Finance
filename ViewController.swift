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

func insert(type :String, symbol :String, price :Double, shares :Int) -> Void
{
    // define current date
    let date = NSDate()
    print(date)
    
    // connect to database
    let context = connectToCoreData()
    
    let newItem = NSEntityDescription.insertNewObjectForEntityForName("History", inManagedObjectContext: context)
    
    newItem.setValue(symbol, forKey: "symbol")
    newItem.setValue(price, forKey: "price")
    newItem.setValue(type, forKey: "type")
    newItem.setValue(shares, forKey: "shares")
    newItem.setValue(date, forKey: "date")
    
    do {
        try context.save()
    } catch {
        print("Unable to save")
    }
    
    let request = NSFetchRequest(entityName: "History")
    request.returnsDistinctResults = false
    do {
        let results = try context.executeFetchRequest(request)
        for result in results as! [NSManagedObject] {
            print(result.valueForKey("date"))
        }
    } catch {
        print("Unable to print")
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
        insert("BUY", symbol: entry as String, price: price, shares: sharesNumber)
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
        insert("BUY", symbol: entry as String, price: price, shares: sharesNumber)
    }
    
    // alert if not enough money
    if enoughMoney == false {
        alert("Bankrupt", message: "You need more money to buy more \(entry) share(s)")
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

func alert(title :String, message :String) -> Void
{
    let alert = UIAlertView()
    alert.title = title
    alert.message = message
    alert.addButtonWithTitle("Understod")
    alert.show()
}


class ViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var symbolField: UITextField!
    
    @IBOutlet weak var quoteLabel: UILabel!
    @IBOutlet weak var symbolLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var cashLabel: UILabel!
    
    @IBOutlet weak var walletLabel: UILabel!
    
    
    /**
    * Configure Get Quote and Buy Share button
    **/
    
    @IBOutlet weak var tableUp: UITableView!
    @IBOutlet weak var menuDown: UITableView!
    
    var menuUpImages :[String] = ["ask", "buy"]
    var menuUpText :[String] = ["Get a quote", "Buy share(s)"]
    
    var menuDownImages :[String] = ["settings"]
    var menuDownText :[String] = ["Settings"]
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if (tableView == self.tableUp) {
            return menuUpImages.count
        }
        
        if (tableView == self.menuDown) {
            return menuDownImages.count
        }
        
        return 0
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        
        var cell:UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "nil")
        
        if (tableView == self.tableUp) {
            cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "menuUpCell")
            
            cell.textLabel!.text = menuUpText[indexPath.row]
            let image : UIImage = UIImage(named: menuUpImages[indexPath.row])!
            cell.imageView!.image = image
            
            return cell
        }
        
        if (tableView == self.menuDown) {
            cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "settingsCell")
            
            cell.textLabel!.text = menuDownText[indexPath.row]
            let image : UIImage = UIImage(named: menuDownImages[indexPath.row])!
            cell.imageView!.image = image
            
            return cell
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        if (tableView == self.tableUp) {
            
            if (indexPath.row == 0)
            {
            self.performSegueWithIdentifier("getQuote", sender: self)
            self.tableUp.deselectRowAtIndexPath(indexPath, animated: true)
            }
            
            if (indexPath.row == 1)
            {
                self.performSegueWithIdentifier("buyShares", sender: self)
                self.tableUp.deselectRowAtIndexPath(indexPath, animated: true)
            }
        }
    }
    
    
    
    @IBOutlet weak var totalLabel: UILabel!
    @IBAction func alertButton(sender: AnyObject) {
        alert("Alert", message: "This is an alert")
    }
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
        /**
        * Start of viewDidLoad
        **/
        
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
        
        
        /**
        * End of viewDidLoad
        **/
    }
    
    override func viewWillAppear(animated: Bool) {
        navigationItem.title = "One"
    }
    
    override func viewDidAppear(animated: Bool) {
        
        navigationItem.title = "One"
        // protype
        var currentCash :Int = 0
        var currentCashString :String = ""
        
        // update cashLabel as soon as loaded
        let context = connectToCoreData()
        let fetchRequest = NSFetchRequest(entityName: "Users")
        fetchRequest.returnsObjectsAsFaults = false
        
        do {
            let results = try context.executeFetchRequest(fetchRequest)
            for result in results as! [NSManagedObject] {
                currentCash = result.valueForKey("cash") as! Int
                currentCashString = String(currentCash)
                cashLabel.text = "$\(currentCashString)"
            }
        } catch {
            print(error)
        }
        
        // update walletLabel as soon as loaded
        // access to Shares CoreData
        let requestShares = NSFetchRequest(entityName: "Shares")
        
        // prototype
        var ownedShares = [String]()
        var manyShares = [Int]()
        var worth = [Double]()
        var worthAdd :Double = 0
        
        
        // create to sample array with symbol and number of shares
        do {
            let results = try context.executeFetchRequest(requestShares)
            for result in results as! [NSManagedObject] {
                ownedShares.append(result.valueForKey("symbol") as! String)
                manyShares.append(result.valueForKey("shares") as! Int)
            }
        } catch {
            print(error)
        }
        
        // check if an array is empty
        if ownedShares.count == 0 {
            self.totalLabel.text = "$\(currentCashString)"
        }
        
        for var i :Int = 0; i < ownedShares.count; i++ {
            let looked = ownedShares[i]
            let numbered = Double(manyShares[i])
            
            _ = lookup(looked) { name, symbol, price in
                dispatch_async(dispatch_get_main_queue()) {
                    worth.append(Double(price)! * numbered)
                    for var j :Int = 0; j < worth.count; j++ {
                        worthAdd += worth[j]
                    }
                    let worthAddString = String(worthAdd)
                    self.walletLabel.text = "$\(worthAddString)"
                    let total = Int(worthAdd) + currentCash
                    let totalString = String(total)
                    self.totalLabel.text = "$\(totalString)"
                }
            }
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}