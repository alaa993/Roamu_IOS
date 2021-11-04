//
//  SearchViewController.swift
//  Taxi
//
//  Created by Syria.Apple on 4/19/20.
//  Copyright © 2020 icanStudioz. All rights reserved.
//

import UIKit
import MapKit

class SearchViewController: UIViewController {
    
    @IBOutlet var CancelButton: UIButton!
    var searchCompleter = MKLocalSearchCompleter()
    var searchResults = [MKLocalSearchCompletion]()
    var MKLocalSearchDictionary = [String:Any]()
    
    var PassData = true
    
    var delegate: isAbleToReceiveData?
    
    
    @IBOutlet weak var searchResultsTableView: UITableView!
    
    override func viewDidLoad() {
        
        CancelButton.setTitle(LocalizationSystem.sharedInstance.localizedStringForKey(key: "SearchVCancelButton", comment: ""), for: .normal)
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        searchCompleter.delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if PassData
        {
            delegate!.pass(ResultSearchDictionary: MKLocalSearchDictionary)
        }
    }
    
    
    @IBAction func CancelButtonClicked(_ sender: Any) {
        PassData = false
        self.dismiss(animated: true, completion: nil)
    }
    
}
extension SearchViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        searchCompleter.queryFragment = searchText
    }
}

extension SearchViewController: MKLocalSearchCompleterDelegate {
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        searchResults = completer.results
        searchResultsTableView.reloadData()
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        // handle error
    }
}

extension SearchViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let searchResult = searchResults[indexPath.row]
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        cell.textLabel?.text = searchResult.title
        cell.detailTextLabel?.text = searchResult.subtitle
        return cell
    }
}

extension SearchViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let completion = searchResults[indexPath.row]
        
        let searchRequest = MKLocalSearch.Request(completion: completion)
        let search = MKLocalSearch(request: searchRequest)
        search.start { (response, error) in
            
            //let MKLocalSearchCoordinate = response?.mapItems[0].placemark.coordinate
            self.MKLocalSearchDictionary = ["title": response?.mapItems[0].placemark.title ?? "",
                                            //"coordinate": MKLocalSearchCoordinate,
                "latitude": response?.mapItems[0].placemark.coordinate.latitude ?? "",
                "longitude": response?.mapItems[0].placemark.coordinate.longitude ?? ""]
            
            //print(MKLocalSearchCoordinate!)
            self.dismiss(animated: true, completion: nil)
        }
    }
}
