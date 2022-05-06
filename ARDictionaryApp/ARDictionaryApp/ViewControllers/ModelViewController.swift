//
//  ModelViewController.swift
//  ARDictionaryApp
//
//  Created by Tom on 2019/12/16.
//  Copyright © 2019 Dgene. All rights reserved.
//

import UIKit

class ModelViewController: UITableViewController {

    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Uncomment the following line to preserve selection between presentations
//         self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return Shared.data.modelList.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let originalCell = tableView.dequeueReusableCell(withIdentifier: "newCell", for: indexPath)
        
        guard let newCell = originalCell as? ModelViewCell else {return originalCell}
        // Configure the cell...
        newCell.lblName.text = Shared.data.modelList[indexPath.row].name
        
//        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
//         let docURL = paths.last!;
        let docURL = Bundle.main.bundleURL.appendingPathComponent("/Bundle")

        if let imgData = try? Data(contentsOf: docURL.appendingPathComponent(Shared.data.modelList[indexPath.row].imgPath)){
            if let img = UIImage(data: imgData) {
                newCell.imageView?.contentMode = .scaleAspectFit
                newCell.imageView?.image = img
//                newCell.imageView?.sizeToFit()
            }
        }
        return newCell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("section: \(indexPath.section)")
        print("row: \(indexPath.row)")
        self.dismiss(animated: true, completion: nil)
        Shared.data.viewControllerDelegate?.popOverDidDismissed(index:indexPath.row)
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    

}
