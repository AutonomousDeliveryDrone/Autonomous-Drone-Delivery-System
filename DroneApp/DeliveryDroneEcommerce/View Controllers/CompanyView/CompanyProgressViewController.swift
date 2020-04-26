//
//  CompanyProgressViewController.swift
//  DeliveryDroneEcommerce
//
//  Created by Michael Peng on 4/16/20.
//  Copyright © 2020 Michael Peng. All rights reserved.
//

import UIKit
import Firebase
import MapKit
import MBCircularProgressBar
import PMSuperButton


class CompanyProgressViewController: UIViewController {
    
    
    var name : String = ""
    var comp : String = ""
    var price : Double = 0
    var address : String = ""
    var time : String = ""
    var distIndex : Int = 0
    
    var status :  String = ""
    var place : Int = 0
    var userID : String = ""
    var companyID : String = ""
    var orderAmount: Int = 0
    
    var ref: DatabaseReference!
    @IBOutlet weak var droneMap: MKMapView!
    @IBOutlet weak var progressBar: MBCircularProgressBarView!
    @IBOutlet weak var productName: UILabel!
    @IBOutlet weak var timeOrdered: UILabel!
    //    @IBOutlet weak var deleteButton: UIBarButtonItem!
    
    @IBOutlet weak var deleteButton: UIButton!
    
    @IBOutlet weak var statusLabel: UILabel!
    
    @IBOutlet weak var transitButton: PMSuperButton!
    override func viewDidLoad() {
        
        super.viewDidLoad()
        ref = Database.database().reference()
        
        transitButton.layer.cornerRadius = 5
        
        deleteButton.isHidden = true
        
        statusLabel.text = "Status:\(status)"
        if status == "In Transit" {
            transitButton.isHidden = true
        }
        else if status == "Complete" {
            transitButton.isHidden = true
            deleteButton.isHidden = false
        }
        transitButton.touchUpInside {
            if self.status == "Processing" {
                let alert = UIAlertController(title: "Change Status", message: "Change Status of Order", preferredStyle: .alert)
                
                let change = UIAlertAction(title: "In Transit", style: .default) { (alert) in
                    self.ref.child("Orders").child("Users").child(self.userID).child(String(self.place)).updateChildValues(["Status" : "In Transit"])
                    self.ref.child("Orders").child("Companies").child(self.companyID).child(String(self.place)).updateChildValues(["Status" : "In Transit"])
                    self.transitButton.isHidden = true
                }
                let cancel = UIAlertAction(title: "Cancel", style: .default) { (alert) in
                    return
                }
                
                alert.addAction(change)
                alert.addAction(cancel)
                self.present(alert, animated: true, completion: nil)
                //                print(indexPath.row)
            }
        }
        
        
        
        
        
        productName.text = "Product: \(name)"
        
        timeOrdered.text = time
        
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
            
            
            //            progressBar.value =
            
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
        //            }
        //        }
        
        
        
        
        
        
        
        //        print(geoCoder.)
        
        
        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func deleteAct(_ sender: Any) {
        let alert = UIAlertController(title: "Delete Order", message: "Are you sure you are done with this order?", preferredStyle: .alert)
        
        let change = UIAlertAction(title: "Delete", style: .default) { (alert) in
            //            self.ref.child("Orders").child("Users").child(self.userID).child(String(self.place)).removeValue()
            self.ref.child("Orders").child("Companies").child(self.companyID).child(String(self.place)).removeValue()
            self.performSegue(withIdentifier: "leave", sender: self)
            
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
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
