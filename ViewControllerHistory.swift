//
//  ViewControllerHistory.swift
//  C$50
//
//  Created by Edouard Jamin on 10/08/15.
//  Copyright © 2015 Gobu. All rights reserved.
//

import UIKit
import CoreData

class ViewControllerHistory: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // prototypes
    var numberArray = [String]()
    var nameArray = [String]()
    var typeArray = [String]()
    
    @IBOutlet weak var historyTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return numberArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = self.historyTable.dequeueReusableCellWithIdentifier("history", forIndexPath: indexPath) as! HistoryCell
        cell.numberLabel.text = self.numberArray[indexPath.row]
        cell.nameLabel.text = self.nameArray[indexPath.row]
        cell.typeLabel.text = self.typeArray[indexPath.row]
    
        return cell
    }
    
    override func viewDidAppear(animated: Bool) {
        
        // reset data
        numberArray = [String]()
        nameArray = [String]()
        typeArray = [String]()
        
        // connect to Core Data
        let context = connectToCoreData()
        let request = NSFetchRequest(entityName: "History")
        request.returnsDistinctResults = false
        
        // append to arrays
        do {
            let results = try context.executeFetchRequest(request)
            
            for result in results as! [NSManagedObject] {
                self.numberArray.append(String(result.valueForKey("shares")!))
                self.nameArray.append(result.valueForKey("symbol") as! String)
                self.typeArray.append(result.valueForKey("type") as! String)
            }
        } catch {
            print(error)
        }
        
        // reload data
        self.historyTable.reloadData()
        print("reload!")
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
