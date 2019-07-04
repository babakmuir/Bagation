//
//  MapViewController.swift
//  Bagation
//
//  Created by vivek soni on 10/01/18.
//  Copyright © 2018 IOSAppExpertise. All rights reserved.
//

import UIKit
import MapKit
import InteractiveSideMenu
import CoreLocation
import Crashlytics

class MapViewController: UIViewController, SideMenuItemContent, UITextFieldDelegate,UITableViewDataSource,UITableViewDelegate {
    
    @IBOutlet var btnMenu: UIButton!
    @IBOutlet var btnListing: UIButton!
    @IBOutlet var searchField: UITextField!
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var tableListView: UITableView!
    @IBOutlet var viewListingContainer: UIView!
    let regionRadius: CLLocationDistance = 10000
    var initialLocation = CLLocation(latitude: 0.0, longitude: 0.0)
    var artworks: [Artwork] = []
    let locationManager = CLLocationManager()
    var isSearchOn : Bool!
    var arrAddressResult : NSMutableArray = []
    var arrListingBagHandler : NSMutableArray = []
    var arrSearchAddressResult : NSMutableArray = []
    var arrJsonResult : [JSON] = []
    var isOnline : Int?
    var availableDays = ""
    var arrAvailableDays : [String] = []
    var bagHandlerID : Int?
    var arrBagHandlerID : [Int] = []
    var arrIsOnline : [String] = []
    var onlineStatus = ""
    var loadDataTimer = Timer()
    var lastSearchKey : String = ""
    var days = ""
    var presentDay : Int?
    var arrAvail : [String] = []
    var availableToday : Bool?
    var arrAvailString : [String] = []
    
    func loadInitialData() {
        // 1
        guard let fileName = Bundle.main.path(forResource: "PublicArt", ofType: "json")
            else { return }
        let optionalData = try? Data(contentsOf: URL(fileURLWithPath: fileName))
        
        guard
            let data = optionalData,
            // 2
            let json = try? JSONSerialization.jsonObject(with: data),
            // 3
            let dictionary = json as? [String: Any],
            // 4
            //let works = dictionary["data"] as? [[Any]]
            let _ = dictionary["data"] as? [[Any]]
            else { return }
        // 5
        //let validWorks = works.flatMap { Artwork(json: $0) }
        //artworks.append(contentsOf: validWorks)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.isSearchOn = false
        searchField.delegate = self
        searchField.addTarget(self, action: #selector(UITextFieldDelegate.textFieldShouldEndEditing(_:)), for: UIControlEvents.editingChanged)
        tableListView.tableFooterView = UIView(frame: .zero)
        tableListView.dataSource = self
        tableListView.delegate = self
//        self.buttonBook.isHidden = true
       // NotificationCenter.default.addObserver(self, selector: #selector(callNearByPlacesFromAPI), name: NSNotification.Name(rawValue: "searchNearByAPI"), object: nil)
        // Do any additional setup after loading the view.
        
        //Crashlytics.sharedInstance().crash()
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateLoadDataTimer(_:)), name: NSNotification.Name.init("update_load_timer"), object: nil)
        
        loadDataTimer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: (#selector(updateBagHadlers)), userInfo: nil, repeats: true)
    }
    
    func configureMapView() {
        //Need to set current location.
        centerMapOnLocation(location: initialLocation)
        
        mapView.delegate = self
        self.btnMenu.layer.shadowColor = UIColor.white.cgColor
        self.btnMenu.layer.shadowOffset = CGSize(width: 0, height: 1.0)
        self.btnMenu.layer.shadowOpacity = 1.0;
        self.btnMenu.layer.masksToBounds = true
        self.btnMenu.layer.shadowRadius = 1.0;
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
        let date = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .weekday], from: date)
        
        let year =  components.year
        let month = components.month
        presentDay = components.weekday
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkLocationAuthorizationStatus()
        initialLocation = LocationManager.sharedInstance.getLastLocation()
        self.configureMapView()
        self.viewListingContainer.isHidden = true
        if(self.arrListingBagHandler.count != 0) {
                self.arrListingBagHandler.removeAllObjects()
        }
        
        if ( UserDefaults.standard.value(forKey: Constants.Key_UserLastCity) != nil) {
            let strCity = UserDefaults.standard.value(forKey: Constants.Key_UserLastCity)as! String
            
            if (strCity.count != 0) {
                self.CallApiForSearchPlace(strSearch: strCity)
            }
        } else {
             mapView.showsUserLocation = true
        }
    }
    
    @objc func updateLoadDataTimer(_ notification: NSNotification) {
        if let status = notification.userInfo?["TimerStatus"] as? Bool {
            if status {
                loadDataTimer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: (#selector(updateBagHadlers)), userInfo: nil, repeats: true)
            } else {
                loadDataTimer.invalidate()
            }
        }
    }
    
    @objc func updateBagHadlers() {
        if lastSearchKey.isEmpty {
            return
        }
//        self.mapView.delegate = self
        self.arrAvailableDays = []
        let value = ["straddress": lastSearchKey]
        self.isSearchOn = true
        APIManager.getRequestWith(strURL: Constants.requestAPISearch, Param: value) { (Dict, Error) in
            Utility.hideHUD()
            if Error == nil {
                if let value = Dict {
                    if (self.arrSearchAddressResult.count != 0) {
                        self.arrSearchAddressResult.removeAllObjects()
                    }
                    
                    if (self.arrListingBagHandler.count != 0) {
                        self.arrListingBagHandler.removeAllObjects()
                    }
                    
                    
                    self.isSearchOn = false
                    let arrTempResult = value.object(forKey: "GetAllAddressesResult") as! NSMutableArray
                    for (_, element) in arrTempResult.enumerated() {
                        let dic = element as! [String : Any]
                        if (dic["Latitude"] != nil && dic["Longitude"] != nil) {
                            if ((dic["Latitude"] as! String).count != 0) && ((dic["Longitude"] as! String).count != 0) {
                                print(dic)
                                let dd = dic["IsOnline"] as? String ?? ""
                                let dr = dic["BagHandlerID"] as? Int ?? 0
                                let df = dic["AvailabilityDays"] as? String ?? ""
                                
                                self.arrIsOnline.append(dd)
                                self.arrBagHandlerID.append(dr)
                                self.arrAvailableDays.append(df)
//                                self.bagHandlerID = Int(dr!)
                                if dd == "0" || dd == "False"
                                {
                                    self.isOnline = 0
//                                    self.buttonBook.isHidden = true
                                    
                                }
                                else if dd == "1" || dd == "True"
                                {
                                    self.isOnline = 1
//                                    self.buttonBook.isHidden = false
                                }
                                
                                UserDefaults.standard.set(self.isOnline, forKey: "status")
                                UserDefaults.standard.set(dr, forKey: "bagHandlerID")
                                UserDefaults.standard.set(self.arrIsOnline, forKey: "statusArray")
                                UserDefaults.standard.set(self.arrBagHandlerID, forKey: "bagHandlerIDArray")
                                UserDefaults.standard.synchronize()
                                self.arrSearchAddressResult.add(dic)
                                self.arrListingBagHandler.add(dic)
                                self.mapView.delegate = self
                            }
                        }
                    }
                    
                    self.showAllAnnotationOnMap()
                }
            }
        }
    }
  
    func fetchCountryAndCity(location: CLLocation, completion: @escaping (String, String) -> ()) {
        CLGeocoder().reverseGeocodeLocation(location) { placemarks, error in
            if let error = error {
                print(error)
            } else if let country = placemarks?.first?.country,
                let city = placemarks?.first?.locality {
                completion(country, city)
            }
        }
    }
    
    
    func CallApiForSearchPlace(strSearch:String){
        if (AppDelegate.objAppDelegate.isConnectedToInternet()) {
        Utility.showHUD(msg: "")
        
        let value = ["strAddress": strSearch ]
        self.isSearchOn = true
        APIManager.getRequestWith(strURL: Constants.requestAPISearch, Param: value) { (Dict, Error) in
            Utility.hideHUD()
            if Error == nil {
                if let value = Dict {
                    print(value)
                    
                    self.lastSearchKey = strSearch
                
                    self.isSearchOn = false
                    let arrTempResult = value.object(forKey: "GetAllAddressesResult") as! NSMutableArray
                    
                    let arrInvalidAddress = NSMutableArray()
                    
                    for (_, element) in arrTempResult.enumerated() {
                        let dic = element as! [String : Any]
                        if (dic["Latitude"] != nil && dic["Longitude"] != nil) {
                            if ((dic["Latitude"] as! String).count != 0) && ((dic["Longitude"] as! String).count != 0) {
                                self.arrAddressResult.add(dic)
                                self.arrListingBagHandler.add(dic)
                            } else {
                                arrInvalidAddress.add(dic)
                            }
                        }
                    }
                    
                    if (arrInvalidAddress.count != 0) {
                        for (_, element) in arrTempResult.enumerated() {
                            var dic = element as! [String : Any]
                            print (dic)
                            let geocoder = CLGeocoder()
                            geocoder.geocodeAddressString(dic["Address"] as! String) {
                                placemarks, error in
                                let placemark = placemarks?.first
                                let lat = placemark?.location?.coordinate.latitude
                                let lon = placemark?.location?.coordinate.longitude
                               
                                dic[(lat?.toString())!] = "Latitude"
                                dic[(lon?.toString())!] = "Longitude"
                                self.arrListingBagHandler.add(dic)
                                self.arrAddressResult.add(dic)
                                self.tableListView.reloadData()
                                // print("Lat: \(lat), Lon: \(lon)")
                            }
                        }
                    }
                    
                    self.tableListView.reloadData()
                    self.artworks.removeAll();
                    //self.mapView.removeAnnotations(self.mapView.annotations)
                    let validWorks = self.arrAddressResult.compactMap { Artwork(json:  $0 as! NSDictionary) }
                    self.artworks.append(contentsOf: validWorks)
                    self.mapView.addAnnotations(self.artworks)
                    
                    if (self.arrAddressResult.count != 0) {
                        let dic = self.arrAddressResult.firstObject as! NSDictionary
                        let strLat = dic ["Latitude"] as! String
                        let strLong = dic ["Longitude"] as! String
                        if let latitude = Double(strLat),
                            let longitude = Double(strLong) {
                            self.initialLocation = CLLocation(latitude: latitude, longitude: longitude)
                            self.centerMapOnLocation(location: self.initialLocation)
                        }
                    }
                    
                    
                    
                    print("Sorted records",self.arrAddressResult)
                    
//                    if ((value.object(forKey: "ResponseCode")) as! Int == 200) {
//                        
//                    } else {
//                        self.showAlert(strMessage: (value.object(forKey: "Message")) as! String)
//                    }
                }
            } else {
                self.showAlert(strMessage: "")
            }
        }
        } else {
        self.showAlert(strMessage: Constants.errorNetworkMessage)
        }
    }
    
    func CallApiForAutoSearchPlace(strSearch:String) {
        if (AppDelegate.objAppDelegate.isConnectedToInternet()) {
        if (self.btnListing.isSelected == true) {
            self.viewListingContainer.isHidden = true
            self.btnListing.isSelected = false
            self.btnListing.setImage(UIImage(named: "list-dots"), for: .normal)
        }
        
        
        Utility.showHUD(msg: "")
        
        let value = ["straddress": strSearch ]
        self.isSearchOn = true
        APIManager.getRequestWith(strURL: Constants.requestAPISearch, Param: value) { (Dict, Error) in
            Utility.hideHUD()
            if Error == nil {
                if let value = Dict {
                    print(value)
                    if (self.arrSearchAddressResult.count != 0) {
                        self.arrSearchAddressResult.removeAllObjects()
                    }
                    
                    if (self.arrListingBagHandler.count != 0) {
                        self.arrListingBagHandler.removeAllObjects()
                    }
                    
                    self.lastSearchKey = strSearch
                    
                    self.isSearchOn = false
                    let arrTempResult = value.object(forKey: "GetAllAddressesResult") as! NSMutableArray
                    let arrInvalidAddress = NSMutableArray()
                    for (_, element) in arrTempResult.enumerated() {
                        let dic = element as! [String : Any]
                        if (dic["Latitude"] != nil && dic["Longitude"] != nil) {
                            
                            let bagSpace = dic["BagSpace"] as? String ?? "0"
                            
                            if ((dic["Latitude"] as! String).count != 0) && ((dic["Longitude"] as! String).count != 0 && Int(bagSpace)! > 0) {
                                self.arrSearchAddressResult.add(dic)
                                self.arrListingBagHandler.add(dic)
                            } else {
                                arrInvalidAddress.add(dic)
                            }
                        }
                    }
                    
                    self.showAllAnnotationOnMap()
                    self.tableView.isHidden = false
                    self.tableView.reloadData()
                    self.tableListView.reloadData()
                }
            } else {
                self.showAlert(strMessage: "")
            }
        }
        } else {
            self.showAlert(strMessage: Constants.errorNetworkMessage)
        }
    }
    
    
    func showAllAnnotationOnMap()
    {
        self.artworks = []
        self.mapView.removeAnnotations(self.mapView.annotations)
        
        for (_,element) in self.arrSearchAddressResult.enumerated() {
            //let dicData = element as! NSMutableDictionary
            let dicData = element as! [String : Any]
            let validWorks = self.arrSearchAddressResult.compactMap { _ in Artwork(json:  dicData as NSDictionary) }
            self.artworks.append(contentsOf: validWorks)
            print(self.artworks)
        }
        
        self.mapView.addAnnotations(self.artworks)
    }
    
    //MARK:- TableView
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (tableView == self.tableListView) {
                return self.arrListingBagHandler.count
        } else {
            if (self.arrSearchAddressResult.count == 0) {
                return 1
            } else {
                 return self.arrSearchAddressResult.count
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (tableView == self.tableListView) {
            return 125.0
        } else {
                return 44.0
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (tableView == self.tableListView) {
            guard let cell:SearchPlaceTableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell") as! SearchPlaceTableViewCell? else {
                return UITableViewCell()
            }
           
            let store = self.arrListingBagHandler.object(at: indexPath.row) as! NSDictionary
            cell.lblStorageName?.text = store.object(forKey: "StoreName") as? String
//            print(store.object(forKey: "AvailabilityDays") as? String)
            cell.lblPriceAvailability.text = String(format:"$4.00 per hour per bag")
            
            if (store.object(forKey: "IsOnline") as? String) == "0"
            {
                cell.lblStatus.text = "Status: Inactive"
                self.onlineStatus = "0"
            }
            else if (store.object(forKey: "IsOnline") as? String) == "1"
            {
                cell.lblStatus.text = "Status: Active"
                self.onlineStatus = "1"
            }
            if (store.object(forKey: "AvailabilityDays") as? String)?.isEmpty == false
            {
                let str = (store.object(forKey: "AvailabilityDays") as? String)
                let arr = str?.components(separatedBy: ",")
                print(arr!)
                
                for ind in 0..<arr!.count
                {
                    let a = arr![ind]
                    print(a)
                    if a == "1"
                    {
                     days = days + ",Mon"
                    }
                    if a == "2"
                    {
                        days = days + ",Tue"
                    }
                    if a == "3"
                    {
                        days = days + ",Wed"
                    }
                    if a == "4"
                    {
                        days = days + ",Thurs"
                    }
                    if a == "5"
                    {
                        days = days + ",Fri"
                    }
                    if a == "6"
                    {
                        days = days + ",Sat"
                    }
                    if a == "7"
                    {
                        days = days + ",Sun"
                    }
                    print(days)
                }
                days = String(days.dropFirst())
                cell.lblDays.text = "Availability: " + days
                UserDefaults.standard.set(days, forKey: "avDays")
                UserDefaults.standard.synchronize()
                days = ""
            }
            
            
            
            
            cell.lblSapceAvailability.text = String(format:"%@ storage space",(store.object(forKey: "BagSpace") as? String)!)

            cell.btnChat.tag = indexPath.row
            cell.btnBooknow.tag = indexPath.row
            
            cell.btnChat.addTarget(self, action: #selector(pressChatButton(button:)), for: .touchUpInside)
            cell.btnBooknow.addTarget(self, action: #selector(pressBookNowButton(button:)), for: .touchUpInside)
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
            
            if (self.arrSearchAddressResult.count == 0) {
                cell.textLabel?.text = "No Records Found"
            } else {
                let dic = self.arrSearchAddressResult.object(at: indexPath.row) as! NSDictionary
                cell.textLabel?.text = dic.object(forKey: "Address") as? String
            }
            
           
            return cell
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      
        if (self.tableView == tableView) {
            if ((self.arrSearchAddressResult.count - 1 )  >= indexPath.row ) {
                 let dicData = self.arrSearchAddressResult.object(at: indexPath.row) as! NSDictionary
                self.tableView.isHidden = true
                self.searchField.text = ""
                
                var strLat = dicData ["Latitude"] as! String
                var strLong = dicData ["Longitude"] as! String
                strLat = strLat.replacingOccurrences(of: "some(\"", with: "")
                strLat = strLat.replacingOccurrences(of: "\")", with: "")
                strLong = strLong.replacingOccurrences(of: "some(\"", with: "")
                strLong = strLong.replacingOccurrences(of: "\")", with: "")
               
                if let latitude = Double(strLat),
                    let longitude = Double(strLong) {
                    self.initialLocation = CLLocation(latitude: latitude, longitude: longitude)
                    self.centerMapOnLocation(location: self.initialLocation)
                }
                self.tableView.isHidden = true
                self.arrSearchAddressResult.removeAllObjects()
                self.tableView.reloadData()
                
            }
        }
    }
    
     // MARK: - UITextField
    func textFieldDidBeginEditing(_ textField: UITextField) {    //delegate method
        
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        print(string)
        print(textField.text ?? "")
        let newString = NSString(string: textField.text!).replacingCharacters(in: range, with: string)
        print(newString)
        
        if (newString.count >= 3 && self.isSearchOn == false) {
            self.CallApiForAutoSearchPlace(strSearch: textField.text!)
        }
        return true;
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {   //delegate method
        textField.resignFirstResponder()
        textField.text = ""
        tableView.isHidden = true
        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        textField.text = ""
        textField.resignFirstResponder()
        tableView.isHidden = true
        return false
    }
    
    // MARK: - IBAction
    @IBAction func btnActionForListingMenu(_ sender: Any) {
        let btnAction = sender as! UIButton
        tableView.reloadData()
        tableListView.reloadData()
        
        if (arrListingBagHandler.count == 0) {
            self.showAlert(strMessage: "There are no bag handler records")
        } else {
            if (btnAction.isSelected == false) {
                self.viewListingContainer.isHidden = false
                btnAction.isSelected = true
                self.btnListing.setImage(UIImage(named: "maps"), for: .normal)
            } else {
                self.viewListingContainer.isHidden = true
                btnAction.isSelected = false
                self.btnListing.setImage(UIImage(named: "list-dots"), for: .normal)
            }
        }
    }
    
    @IBAction func openMenu(_ sender: UIButton) {
        self.searchField.text = ""
        showSideMenu()
    }

    
    @objc func pressChatButton(button: UIButton) {
        let tagValue = self.arrListingBagHandler.object(at: button.tag) as!NSDictionary
        
        let store = StorageDAO(storageDict: [:])
        store.StoreName = tagValue.object(forKey: "StoreName") as? String
        store.BagHandlerFireBaseID = tagValue.object(forKey: "BagHandlerFireBaseID") as? String
        let obj:ConversationViewController = self.storyboard?.instantiateViewController(withIdentifier: "conversationView") as! ConversationViewController
        obj.objUser = store
        self.navigationController?.pushViewController(obj, animated: true)
    }
    
    @objc func pressBookNowButton(button: UIButton) {
        guard let tagValue = self.arrListingBagHandler.object(at: button.tag) as? [String : Any] else {
            return
        }
        print(self.artworks)

        print(self.onlineStatus)
        print(self.arrSearchAddressResult)

     
        print(tagValue)
        let valueStatus = tagValue["IsOnline"] as? String ?? ""
        let availability = tagValue["AvailabilityDays"] as? String ?? ""
        let arr = Array(availableDays)
        print(valueStatus)
        print(arr)
        let arrAvailability = Array(availability)
        print(arrAvailability)
        let arr1 = availability.components(separatedBy: ",")
        print(arr1)

        let day = (presentDay!-1)
        let today = "\(day)"
        print(today)
        if arr1.contains(today)
        {
            availableToday = true
        }
        else
        {
            availableToday = false
        }
        
        if valueStatus == "1" && availableToday == true
        {
            let obj = self.storyboard?.instantiateViewController(withIdentifier: "bookingId") as! BookingViewController
            obj.dicBagHanlderDetail = tagValue
            self.navigationController?.pushViewController(obj, animated: true)
        }
        else 
        {
            let alert = UIAlertController(title: "Alert!", message: "You can't make booking because store is currently closed.", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .cancel) { (actoin) in
            }
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
        }

    }
    
    func getTimeValue(aTime: String)->Date{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm a"
        let date = dateFormatter.date(from: aTime)
        if let _date = date{
            return _date
        }
        return Date()
    }
    
    func checkIfBetween(aStartTime: String, aEndTime:String)-> Bool{
        //let _startTime = getTimeValue(aTime: aStartTime)
        //let _endTime = getTimeValue(aTime: aEndTime)
        let _curTime = Date()
        let _calendar = Calendar(identifier: .gregorian);
        
        let _nYear = _calendar.component(.year, from: _curTime)
        let _nMonth = _calendar.component(.month, from: _curTime)
        let _nDay = _calendar.component(.day, from: _curTime)
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd hh:mm a"
        
        let _startTime = formatter.date(from: String(format:"%d/%d/%d %@",_nYear,_nMonth,_nDay,aStartTime))
        let _endTime = formatter.date(from: String(format:"%d/%d/%d %@",_nYear,_nMonth,_nDay,aEndTime))
        
        if((_startTime?.compare(_curTime) == .orderedAscending ||
            _startTime?.compare(_curTime) == .orderedSame)
            && (_endTime?.compare(_curTime) == .orderedDescending ||
            _endTime?.compare(_curTime) == .orderedSame)){
            return true;
        }
        self.showAlert(strMessage: "You can only book between \(aStartTime) and \(aEndTime).")
        return false;
    }
    
    @IBAction func btnActionForPricing(_ sender: Any) {
        let obj = self.storyboard?.instantiateViewController(withIdentifier: "calenderView")
        self.navigationController?.pushViewController(obj!, animated: true)
    }
    
    func checkLocationAuthorizationStatus() {
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            mapView.showsUserLocation = true
        } else {
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius, regionRadius)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        guard let location = view.annotation as? Artwork else {
            self.showAlert(strMessage: "Can't get location. Please try again.")
            return
        }
        print(Artwork.self)
        print(location.detailDic)
        guard let valueStatus = location.detailDic["IsOnline"] as? String else {
            return
        }
        //Book Now
        if (control == view.rightCalloutAccessoryView) {
            
            if (location.detailDic ["StripAccountID"] != nil) {
                let stripeAccountId = location.detailDic ["StripAccountID"] as? String
                if (stripeAccountId?.count != 0) {
                    if valueStatus == "0"
                    {
                        let alert = UIAlertController(title: "Alert!", message: "You can't make booking because store is currently closed.", preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "OK", style: .cancel) { (actoin) in
                            
                        }
                        alert.addAction(okAction)
                        self.present(alert, animated: true, completion: nil)
                    }
                    else if valueStatus == "1"
                    {
                        let obj = self.storyboard?.instantiateViewController(withIdentifier: "bookingId") as! BookingViewController
                        guard let detailsDic = location.detailDic as? [String : Any] else {
                            return
                        }
                        obj.dicBagHanlderDetail = detailsDic
                        self.navigationController?.pushViewController(obj, animated: true)
                        
                    }
                    
                } else {
                    self.showAlert(strMessage: "You can't book storage because bag handler doesn't setup payment yet.")
                }
            } else {
                self.showAlert(strMessage: "You can't book storage because bag handler doesn't setup payment yet.")
            }
            
        }
        
        //Chat
        if (control == view.leftCalloutAccessoryView) {
            let store = StorageDAO(storageDict: [:])
            store.StoreName = location.detailDic.object(forKey: "StoreName") as? String
            store.BagHandlerFireBaseID = location.detailDic.object(forKey: "BagHandlerFireBaseID") as? String
            store.FirebaseReceiverDeviceToken = location.detailDic.object(forKey: "DeviceToken") as? String
            let obj:ConversationViewController = self.storyboard?.instantiateViewController(withIdentifier: "conversationView") as! ConversationViewController
            obj.objUser = store
            self.navigationController?.pushViewController(obj, animated: true)
        }
        
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

extension MapViewController: MKMapViewDelegate {
    // 1
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
      
        if #available(iOS 11.0, *) {
            guard let annotation = annotation as? Artwork else { return nil }
            
            let identifier = "marker"
            var view: MKMarkerAnnotationView
            
            if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)  as? MKMarkerAnnotationView {
                dequeuedView.annotation = annotation
                view = dequeuedView
            } else {
                //view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                view = CustomAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                view.canShowCallout = true
                view.calloutOffset = CGPoint(x: -5, y: 5)
                
                let image = UIImage(named: "chat-64")
                let button = UIButton(type: .custom)
                button.frame = CGRect(x: 0, y: 0, width: 32, height: 32)
                button.setImage(image, for: UIControlState())
                view.leftCalloutAccessoryView = button
                
                //let imageBooking = UIImage(named: "icon_chat")
                let buttonBook = UIButton(type: .custom)
                buttonBook.frame = CGRect(x: 0, y: 0, width: 68, height: 32)
                //buttonBook.setImage(imageBooking, for: UIControlState())
                buttonBook.setTitle("Book Now", for: .normal)
                buttonBook.titleLabel?.font = UIFont(name: "GothamRounded-Medium", size: 13)
                buttonBook.setTitleColor(.red, for: .normal)
                view.rightCalloutAccessoryView = buttonBook
                //view.frame = CGRect(x: view.frame.origin.x, y: view.frame.origin.y, width: view.frame.size.width, height: 200)

            }
            view.subtitleVisibility = MKFeatureVisibility.hidden
            view.animatesWhenAdded = true
            return view
        } else {
            let annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "pin-annotation")
            annotationView.animatesDrop = true
            annotationView.canShowCallout = true
            return nil
        }
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView)
    {
        print("Annotation tapped \(String(describing: view.annotation?.title))")
    }
}

