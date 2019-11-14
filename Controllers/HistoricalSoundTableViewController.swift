//
//  HistoricalSoundTableViewController.swift
//  5140AssignmentStarter
//
//  Created by haofang Liu on 3/11/19.
//  Copyright © 2019 XinzhuoYu. All rights reserved.
//

import UIKit
import Firebase

class HistoricalSoundTableViewController: UITableViewController, UISearchResultsUpdating, DatabaseListener {

    let SECTION_RECORD = 0;
    
    var allRecords: [SoundRecord] = []
    var filteredRecords: [SoundRecord] = []
    weak var databaseController: DatabaseProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        definesPresentationContext = true
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.databaseController
        
        let searchController = UISearchController(searchResultsController: nil);
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search record"
        navigationItem.searchController = searchController

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        databaseController?.addListener(listener: self)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        databaseController?.removeListener(listener: self)
    }
    //update search function
    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text?.lowercased(), searchText.count > 0 {
            filteredRecords = allRecords.filter({(soundRecord: SoundRecord) -> Bool in
                return soundRecord.soundLevel.lowercased().contains(searchText)
            })
        }
        else {
            filteredRecords = allRecords;
        }
        
        tableView.reloadData();
    }
    
    // MARK: - Database Listener
    
    var listenerType = ListenerType.soundRecord
    
    func onSoundRecordListChange(change: DatabaseChange, soundRecords: [SoundRecord]) {
        allRecords = soundRecords
        updateSearchResults(for: navigationItem.searchController!)
        
    }
    
    
    
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == SECTION_RECORD {
            return filteredRecords.count
        } else {
            return 1
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let soundCell = tableView.dequeueReusableCell(withIdentifier: "soundCell", for: indexPath) as! SoundCellTableViewCell
            let soundCellSelected = filteredRecords[indexPath.row]
            
            soundCell.DateLabel.text = soundCellSelected.soundDate
            soundCell.DBAndSoundLevelLabe.text = "\(soundCellSelected.soundDB) - \(soundCellSelected.soundLevel)"
            return soundCell
            
        
    }
    
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            let recordDelete = filteredRecords[indexPath.row]
            databaseController?.deleteSoundRecord(soundRecord: recordDelete)
        }
        
    }
    
    //transfer RGB color to UI color
    func colorForIndex(index: Int) -> UIColor {
        var color: UIColor!
        let record = filteredRecords[index]
            if record.soundLevel == "High Level" {
                color = UIColor(hexString: "#ff9999")
            }
            else if record.soundLevel == "Medium Level"{
                color = UIColor(hexString: "#ffbf80")
            }
            else{
                color = UIColor(hexString: "#a9d279")
            }
        
    //return UIColor(red: 1.0, green: color, blue: 0.0, alpha: 1.0)
        return color
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath)
    {
        cell.backgroundColor = colorForIndex(index: indexPath.row)
    }
    
    
    func onLightStateChange(change: DatabaseChange, light: Light) {
        //
    }

    
}
