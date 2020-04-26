//
//  ProgressScreenViewController.swift
//  DeliveryDroneEcommerce
//
//  Created by Michael Peng on 4/15/20.
//  Copyright © 2020 Michael Peng. All rights reserved.
//

import UIKit
import MBCircularProgressBar
import CoreLocation
import MapKit
import PMSuperButton
import Firebase


class ProgressScreenViewController: UIViewController {
    
    @IBOutlet weak var progressBar: MBCircularProgressBarView!
    @IBOutlet weak var droneMap: MKMapView!
    @IBOutlet weak var completeButton: PMSuperButton!
    
    var productName : String = ""
    var company : String = ""
    var price : Double = 0
    var address : String = ""
    var timeOrdered : String = ""
    var distIndex : Int = 0
    
    
    var status :  String = ""
    var place : Int = 0
    var userID : String = ""
    var companyID : String = ""
    var orderAmount : Int = 0
    
    @IBOutlet weak var time: UILabel!
    //    @IBOutlet weak var address: UILabel!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var comp: UILabel!
    //    @IBOutlet weak var company: UILabel!
    //    var ref : DatabaseReference!
    @IBOutlet weak var name: UILabel!
    
    var ref : DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
        completeButton.layer.cornerRadius = 5
        
        print("Status: \(status)")
        
        deleteButton.isHidden = true
        
        statusLabel.text = "Status:\(status)"
        if status == "Processing" {
            completeButton.isHidden = true
        }
        else if status == "Complete" {
            completeButton.isHidden = true
            deleteButton.isHidden = false
        }
        
        
        
        completeButton.touchUpInside {
            if self.status == "In Transit" {
                let alert = UIAlertController(title: "Complete Order", message: "Did the product deliver to your house yet?", preferredStyle: .alert)
                
                let change = UIAlertAction(title: "Complete", style: .default) { (alert) in
                    self.ref.child("Orders").child("Users").child(self.userID).child(String(self.place)).updateChildValues(["Status" : "Complete"])
                    self.ref.child("Orders").child("Companies").child(self.companyID).child(String(self.place)).updateChildValues(["Status" : "Complete"])
                    //                    self.performSegue(withIdentifier: "dip", sender: self)
                    self.deleteButton.isHidden = false
                    self.completeButton.isHidden = true
                    
                }
                let cancel = UIAlertAction(title: "Cancel", style: .default) { (alert) in
                    return
                }
                
                alert.addAction(change)
                alert.addAction(cancel)
                self.present(alert, animated: true, completion: nil)
                
            }
            print("This button was pressed!")
            
        }
        
        
        
        
        
        name.text = "Product: \(productName)"
        comp.text = "Company: \(company)"
        time.text = timeOrdered
        
        UIView.animate(withDuration: 1) {
            self.progressBar.value = CGFloat(Double(self.distIndex)*10.0)
        }
        
        
        ref.child("Orders").child("Pending").child("47").observeSingleEvent(of: .value, with: { (snapshot) in
            guard let value = snapshot.value as? NSDictionary else {
                print("could not collect data")
                return
            }
            
            var x = value["xCoord"] as! Double
            var y = value["yCoord"] as! Double
            let r = value["r"] as! Double
            
//            x = 37.304852
//            y = -122.029282
            let oahuCenter = CLLocation(latitude: 37.305540, longitude: -122.029070 )
            let region = MKCoordinateRegion(center: oahuCenter.coordinate, latitudinalMeters: 100, longitudinalMeters: 100)
            self.droneMap.setCameraBoundary(MKMapView.CameraBoundary(coordinateRegion: region), animated: true)
            
            
            let zoomRange = MKMapView.CameraZoomRange(maxCenterCoordinateDistance: 300)
            self.droneMap.setCameraZoomRange(zoomRange, animated: true)
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2D(latitude: x , longitude: y )
            let annotation2 = MKPointAnnotation()
            annotation2.coordinate = CLLocationCoordinate2D(latitude: 37.305540 , longitude: -122.029070 )
            //            self.droneMap.addAnnotation(annotation2)
            self.droneMap.addAnnotation(annotation2)
            self.droneMap.addAnnotation(annotation)
            
            print(r)
            
            self.progressBar.value = CGFloat((r/8.0) * 100)
            
        })
        //
        //        let address = "New York, NY"
        //
        //        let address2 = "1063 Oaktree Drive, San Jose, CA "
        //
        //
        //        var initialLat : CLLocationDegrees = 1
        //        var initialLon : CLLocationDegrees = 1
        //        var finalLat : CLLocationDegrees = 1
        //        var finalLon : CLLocationDegrees = 1
        //
        //        var geocoder = CLGeocoder()
        //        geocoder.geocodeAddressString(address) {
        //
        //            placemarks, error in
        //
        //            let placemark = placemarks?.first
        //            let lat = placemark?.location?.coordinate.latitude
        //            let lon = placemark?.location?.coordinate.longitude
        //
        //            initialLat = lat!
        //            initialLon = lon!
        //            print("Boat: Lat: \(lat), Lon: \(lon)")
        //            print(type(of: lat))
        //            //            let oahuCenter = CLLocation(latitude: lat!, longitude: lon!)
        //            //            let region = MKCoordinateRegion(center: oahuCenter.coordinate, latitudinalMeters: 50000, longitudinalMeters: 60000)
        //            //            self.droneMap.setCameraBoundary(MKMapView.CameraBoundary(coordinateRegion: region), animated: true)
        //            //
        //            //            let zoomRange = MKMapView.CameraZoomRange(maxCenterCoordinateDistance: 200000)
        //            //            self.droneMap.setCameraZoomRange(zoomRange, animated: true)
        //
        //            var yote = CLGeocoder()
        //            yote.geocodeAddressString(address2) {
        //                placemarks, error in
        //                let placemark = placemarks?.first
        //                let lat = placemark?.location?.coordinate.latitude
        //                let lon = placemark?.location?.coordinate.longitude
        //                finalLat = lat!
        //                finalLon = lon!
        //                print("Yote: Lat: \(lat), Lon: \(lon)")
        //
        //                //                let region = MKCoordinateRegion(center: oahuCenter.coordinate, latitudinalMeters: 50000, longitudinalMeters: 60000)
        //                //                self.droneMap.setCameraBoundary(MKMapView.CameraBoundary(coordinateRegion: region), animated: true)
        //                //
        //                //                let zoomRange = MKMapView.CameraZoomRange(maxCenterCoordinateDistance: 200000)
        //                //                self.droneMap.setCameraZoomRange(zoomRange, animated: true)
        //
        //
        //                print("\(initialLat) + \(initialLon) + \(finalLat) + \(finalLon)" )
        //                let diffLat : Double = Double(initialLat)-Double(finalLat)
        //                let diffLon : Double = Double(initialLon)-Double(finalLon)
        //                print("\(diffLat) + \(diffLon)")
        //                let ind = self.distIndex
        //
        //
        //                var arrLat : [Double] = []
        //                var arrLon : [Double] = []
        //                for i in stride(from: 1, to: 11, by: 1) {
        //                    let stepLat = 0.1 * diffLat
        //                    let stepLon = 0.1 * diffLon
        //
        //                    arrLat.append(Double(initialLat) - (Double(i) * stepLat))
        //                    arrLon.append(Double(initialLon) - (Double(i) * stepLon))
        //                    print(Double(initialLat) - (Double(i) * stepLat))
        //                    print(Double(initialLon) - (Double(i) * stepLon))
        //                }
        //
        //
        //                let oahuCenter = CLLocation(latitude: arrLat[ind], longitude: arrLon[ind])
        //                let region = MKCoordinateRegion(center: oahuCenter.coordinate, latitudinalMeters: 100000, longitudinalMeters: 100000)
        //                //                  self.droneMap.setCameraBoundary(MKMapView.CameraBoundary(coordinateRegion: region), animated: true)
        //
        //
        //                let zoomRange = MKMapView.CameraZoomRange(maxCenterCoordinateDistance: 200000)
        //                //                self.droneMap.setCameraZoomRange(zoomRange, animated: true)
        //                let annotation = MKPointAnnotation()
        //                annotation.coordinate = CLLocationCoordinate2D(latitude: arrLat[ind], longitude: arrLon[ind])
        //                let annotation2 = MKPointAnnotation()
        //                annotation2.coordinate = CLLocationCoordinate2D(latitude: finalLat, longitude: finalLon)
        //
        //                self.droneMap.addAnnotation(annotation2)
        //                self.droneMap.addAnnotation(annotation)
        //
        //
        //
        
        
        
        
        
        
        
        
        //        print(geoCoder.)
        
        
        
    }
    
    func createAnnonations(locations : [[String : Any]]) {
        //        for location in locations
    }
    
    @IBAction func deleteAct(_ sender: Any) {
        let alert = UIAlertController(title: "Delete Order", message: "Are you sure you are done with this order?", preferredStyle: .alert)
        
        let change = UIAlertAction(title: "Delete", style: .default) { (alert) in
            //            self.ref.child("Orders").child("Users").child(self.userID).child(String(self.place)).removeValue()
            self.ref.child("Orders").child("Users").child(self.userID).child(String(self.place)).removeValue()
            self.performSegue(withIdentifier: "dip", sender: self)
            
        }
        let cancel = UIAlertAction(title: "Cancel", style: .default) { (alert) in
            return
        }
        
        alert.addAction(change)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
    }
    /*
     // MARK: - Navigation
     
     @IBAction func deleteAct(_ sender: Any) {
     }
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
