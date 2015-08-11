//
//  ViewControllerWallet.swift
//  C$50
//
//  Created by Edouard Jamin on 10/08/15.
//  Copyright © 2015 Gobu. All rights reserved.
//

import UIKit
import Foundation
import CoreData

var shareSelected = ""

class ViewControllerWallet: UIViewController {
    
    @IBOutlet weak var sharesList: UITableView!
    
    var sharesArray :NSMutableArray! = NSMutableArray()
    var numberArray = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.sharesArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = self.sharesList.dequeueReusableCellWithIdentifier("share", forIndexPath: indexPath) as! WalletCell
        cell.nameShares.text = self.sharesArray.objectAtIndex(indexPath.row) as? String
        cell.numberShares.text = self.numberArray[indexPath.row]
        
        cell.minusButton.tag = indexPath.row
        cell.minusButton.addTarget(self, action: "sellAction:", forControlEvents: .TouchUpInside)
        cell.plusButton.tag = indexPath.row
        cell.plusButton.addTarget(self, action: "buyAction:", forControlEvents: .TouchUpInside)
        return cell
    }
    
    override func viewDidAppear(animated: Bool) {
        
        func tabBarIsVisible() ->Bool {
            return self.tabBarController?.tabBar.frame.origin.y < CGRectGetMaxY(self.view.frame)
        }
        
        print(tabBarIsVisible())
        
        
        sharesArray = NSMutableArray()
        numberArray = [String]()
        
        let appDel :AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let context :NSManagedObjectContext = appDel.managedObjectContext
        
        let request = NSFetchRequest(entityName: "Shares")
        request.returnsObjectsAsFaults = false
        
        do {
            let results = try context.executeFetchRequest(request)
            
            if results.count > 0 {
                for result in results as! [NSManagedObject] {
                    self.sharesArray.addObject(result.valueForKey("symbol") as! String)
                    let numberNumber = result.valueForKey("shares")! as! NSNumber
                    self.numberArray.append(String(numberNumber))
                }
            }
            
        } catch {
            print(error)
        }
        
        self.sharesList.reloadData()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func sellAction(sender: UIButton) {
        
        shareSelected = self.sharesArray[sender.tag] as! String
        self.performSegueWithIdentifier("sellView", sender: self)
        
    }
    
    @IBAction func buyAction(sender: UIButton) {
        
        shareSelected = self.sharesArray[sender.tag] as! String
        self.performSegueWithIdentifier("buyView", sender: self)
        
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
