//
//  BikeTableViewController.swift
//  CityBike
//
//  Created by Maharani on 15/12/17.
//   Copyright © 2017 Maharani SVS. All rights reserved.
//

import UIKit

let lightGreySet  = UIColor(red: 230/255, green: 230/255, blue: 232/255,alpha : 1.0)
let noInternetConnection  = " No Internet Connection, Please try again. "


class BikeTableViewController: UITableViewController, UISearchBarDelegate {
    var bikeList : Array<BikeDetail> =  Array<BikeDetail>(),searchActive : Bool = false,filtered:[BikeDetail] = []
    @IBOutlet weak var searchBar: UISearchBar!
    weak var activityIndicatorView: UIActivityIndicatorView!
    
    // MARK: - ViewDidLoad Method
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        let activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
        self.tableView.backgroundView = activityIndicatorView
        self.activityIndicatorView = activityIndicatorView
        self.activityIndicatorView.startAnimating()
        self.tableView.register(UINib(nibName: bikeListViewCell, bundle: Bundle(for: type(of: self))), forCellReuseIdentifier: bikeListViewCell)
        self.tableView.separatorColor = lightGreySet
        urlRequest()
    }
    
    // MARK: - SearchBar Delegates
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchActive = true;
    }
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchActive = false;
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false;
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false;
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filtered = bikeList.filter({( bike : BikeDetail) -> Bool in
            return bike.bikeName!.lowercased().contains(searchText.lowercased())
        })
        searchActive =  filtered.count == 0 ? false : true
        self.tableView.reloadData()
    }
    // MARK: - API Call
    func urlRequest() {
        let url = "https://api.citybik.es/v2/networks"
        //Method to check Wifi Network /Cellular Connection
        if Network.isConnectedWifiCellular(){
            var  request =  URLRequest(url: URL(string: url)!)
            request.httpMethod = "GET"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            let config =  URLSessionConfiguration.default
            let session = URLSession(configuration: config)
            let task = session.dataTask(with: request) { (data, response, error) in
                guard let getData = data else {
                    return
                }
                do {
                    let dict = try JSONSerialization.jsonObject(with: getData, options: JSONSerialization.ReadingOptions.allowFragments)
                    let output = dict as! jsonDict
                    guard output.isEmpty == false else {
                        return
                    }
                    let response = output[APIKeys.response.rawValue] as! jsonArray
                    
                    for bikeObject in response {
                        let bike =  BikeDetail(bikeObject: bikeObject)
                        self.bikeList.append(bike)
                    }
                    DispatchQueue.main.async {
                        self.activityIndicatorView.stopAnimating()
                        self.tableView.reloadData()
                    }
                }
                catch  {
                    print("error")
                }
            }
            task.resume()
            
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                self.alertAction(title: "", message: noInternetConnection)
                _  =  self.activityIndicatorView.isAnimating ? self.activityIndicatorView.stopAnimating() : ()
                
            }
        }
    }
    
    
    
    //MARK :: - Alert
    func alertAction(title:String, message : String ) {
        let alertAction = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertAction.addAction(defaultAction)
        self.present(alertAction, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchActive ? filtered.count : self.bikeList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: BikeListViewCell = tableView.dequeueReusableCell(withIdentifier:bikeListViewCell, for: indexPath) as! BikeListViewCell
        let object = searchActive  ?  self.filtered[indexPath.row] : self.bikeList[indexPath.row]
        cell.bikeName.text = object.bikeName!
        cell.bikeId.text = "ID: " + object.bikeId!
        cell.country.text = object.locationDetails.city
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let object = searchActive  ?  self.filtered[indexPath.row] : self.bikeList[indexPath.row]
        self.performSegue(withIdentifier: "isShowDetail", sender: object)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        let con = segue.destination as! BikeDetailController
        con.object = sender as! BikeDetail
    }
    
    
}

// MARK: -  Additional funtionalities for UIView to use in xib or storyboard using IBInspectable
extension UIView {
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
    @IBInspectable var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable var borderColor: UIColor? {
        get {
            return UIColor(cgColor: layer.borderColor!)
        }
        set {
            layer.borderColor = newValue?.cgColor
        }
    }
}
