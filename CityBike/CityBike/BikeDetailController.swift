//
//  BikeDetailController.swift
//  CityBike
//
//  Created by Maharani on 15/12/17.
//   Copyright © 2017 Maharani SVS. All rights reserved.
//
import UIKit

class BikeDetailController: UIViewController {
    
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var navItem: UINavigationItem!
    @IBOutlet weak var detail_tbl_View: UITableView!
    @IBOutlet weak var companyDetailsValue: UILabel!
    @IBOutlet weak var bikeIdValue: UILabel!
    @IBOutlet weak var locationBtn: UIButton!
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var loadingActivity: UIActivityIndicatorView!
    @IBOutlet weak var headerText: UILabel!
    
    var object : BikeDetail!,stationObject : Stations!,stationList : Array<Stations> =  Array<Stations>(),isDetailedView = false
    var hrefURL = "https://api.citybik.es"
    
    //MARK :: - viewDidload Method
    override func viewDidLoad() {
        super.viewDidLoad()
        self.detail_tbl_View.register(UINib(nibName: stationTableViewCell, bundle: Bundle(for: type(of: self))), forCellReuseIdentifier: stationTableViewCell)
        self.detail_tbl_View.separatorColor = lightGreySet
        self.navItem.title = object.bikeName!
        self.navigationController?.navigationBar.tintColor = UIColor.white
        hrefURL = hrefURL + object.imgLink!
        self.loadingActivity.startAnimating()
        self.loadingView.isHidden = false
        urlRequest(url: hrefURL)
        self.bikeIdValue.text = object.bikeId
        self.detail_tbl_View.delegate = self
        self.detail_tbl_View.dataSource = self
    }
    
    //MARK :: -  API Call request method
    func urlRequest(url :String) {
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
                    let response = output[APIKeys.respDetail.rawValue] as! jsonDict
                    let company = response["company"] as! Array<String>
                    let stations = response["stations"] as! jsonArray
                    for stationObj in stations {
                        let station =  Stations(stationObject: stationObj)
                        self.stationList.append(station)
                    }
                    DispatchQueue.main.async {
                        self.loadingActivity.stopAnimating()
                        self.loadingView.isHidden = true
                        self.companyDetailsValue.text = company.joined(separator: "\n")
                        self.detail_tbl_View.reloadData()
                    }
                }
                catch  {
                    print("error")
                }
            }
            task.resume()
        } else {
            self.alertAction(title: "", message: noInternetConnection)
            self.loadingView.isHidden = false
            _  =  self.loadingActivity.isAnimating ? self.loadingActivity.stopAnimating() : ()
        }
    }
    
    //MARK :: - Alert
    func alertAction(title:String, message : String ) {
        let alertAction = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertAction.addAction(defaultAction)
        self.present(alertAction, animated: true, completion: nil)
    }
    
    //MARK :: - Load Map on clicking each Staion location icon
    @objc func loadMapView() {
        isDetailedView = true
        self.performSegue(withIdentifier: "isShowMapDetail", sender: stationObject)
    }
    
    //MARK :: - Load Map on Clicking Location icon in Company details
    @IBAction func locationActionView(_ sender: Any) {
        isDetailedView = false
        self.performSegue(withIdentifier: "isShowMapDetail", sender: object)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "isShowMapDetail" {
            let nv: UINavigationController = segue.destination as! UINavigationController
            let con = nv.topViewController as! MapViewController
            con.isDetailedView = isDetailedView
            if isDetailedView == false {
                con.object = sender as! BikeDetail
            } else {
                con.stationObject = sender as! Stations
            }
            
        }
    }
    
    
}

// MARK: - Table view data source
extension BikeDetailController : UITableViewDelegate,UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        
        let header : UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView
        header.textLabel?.text = "Stations"
        header.textLabel?.textAlignment = .left
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 45
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return stationList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : StationTableViewCell = tableView.dequeueReusableCell(withIdentifier: stationTableViewCell, for: indexPath) as! StationTableViewCell
        let Object = stationList[indexPath.row]
        cell.loadDetails(object :Object)
        cell.selectionCallback = {
            self.stationObject = Object
        }
        cell.locationBtn.addTarget(self, action: #selector(loadMapView), for: .touchUpInside)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 95
    }
    
}
