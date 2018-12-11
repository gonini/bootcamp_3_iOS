//
//  ViewController.swift
//  boostcamp_3_iOS
//
//  Created by admin on 04/12/2018.
//  Copyright © 2018 wndzlf. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet var tableview: UITableView!
    var movies = [movie]()
    
    var filterType: filteringMethod?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableview.dataSource = self
        tableview.delegate = self
        
        setupNavigation()
        
        filterType = filteringMethod.init(rawValue: 0)
        
        let url = "http://connect-boxoffice.run.goorm.io/movies"
        getJsonFromURL(getURL: url)
        
        NotificationCenter.default.addObserver(self, selector: #selector(changeFilter(_:)), name: Notification.Name(rawValue: "filtering"), object: nil)
    }
    
    
    
    @objc func changeFilter(_ notification: Notification) {
        print("changeFilter")
        if let dict = notification.userInfo as NSDictionary? {
            if let id = dict["filterType"] as? filteringMethod{
                if id.rawValue == 0 {
                    self.navigationItem.title = "예매율순"
                    let url = "http://connect-boxoffice.run.goorm.io/movies?order_type=0"
                    self.getJsonFromURL(getURL: url)
                }else if id.rawValue == 1 {
                    self.navigationItem.title = "큐레이션"
                    let url = "http://connect-boxoffice.run.goorm.io/movies?order_type=1"
                    self.getJsonFromURL(getURL: url)
                }else {
                    self.navigationItem.title = "개봉일순"
                    let url = "http://connect-boxoffice.run.goorm.io/movies?order_type=2"
                    self.getJsonFromURL(getURL: url)
                }
            }
        }
    }
    
    @IBAction func flteringButton(_ sender: Any) {
        let actionSheet = UIAlertController(title: "정렬 방식 선택", message:"영화를 어떤 방식으로 정렬할까요?", preferredStyle: .actionSheet)
        
        //예매율 , 큐레이션, 개봉일 정렬
        let reservationRate = UIAlertAction(title: "예매율", style: .default) { [weak self] (action) in
            guard let `self` = self else {return}
            self.navigationItem.title = "예매율순"
            self.filterType = filteringMethod.init(rawValue: 0)
            let url = "http://connect-boxoffice.run.goorm.io/movies?order_type=0"
            self.getJsonFromURL(getURL: url)

            let dictat = ["filterType": self.filterType]
            NotificationCenter.default.post(name: Notification.Name("filtering2"), object: nil, userInfo: dictat as [AnyHashable : Any])
            
            let nc = self.tabBarController?.viewControllers?[1] as! UINavigationController
            if nc.topViewController is CollectionVC {
                let svc = nc.topViewController as! CollectionVC
                svc.filterType = self.filterType
            }
        }
        
        let quaration = UIAlertAction(title: "큐레이션", style: .default) { [weak self](action) in
            guard let `self` = self else {return}
            self.navigationItem.title = "큐레이션"
            self.filterType = filteringMethod.init(rawValue: 1)
            let url = "http://connect-boxoffice.run.goorm.io/movies?order_type=1"
            self.getJsonFromURL(getURL: url)
            
            let dictat = ["filterType": self.filterType]
            NotificationCenter.default.post(name: Notification.Name("filtering2"), object: nil, userInfo: dictat as [AnyHashable : Any])
            
            let nc = self.tabBarController?.viewControllers?[1] as! UINavigationController
            if nc.topViewController is CollectionVC {
                let svc = nc.topViewController as! CollectionVC
                svc.filterType = self.filterType
            }
        }
        
        let openTime = UIAlertAction(title: "개봉일", style: .default) { [weak self] (action) in
            guard let `self` = self else {return}
            self.navigationItem.title = "개봉일순"
            self.filterType = filteringMethod.init(rawValue: 2)
            let url = "http://connect-boxoffice.run.goorm.io/movies?order_type=2"
            self.getJsonFromURL(getURL: url)
            
            let dictat = ["filterType": self.filterType]
            NotificationCenter.default.post(name: Notification.Name("filtering2"), object: nil, userInfo: dictat as [AnyHashable : Any])
            
            let nc = self.tabBarController?.viewControllers?[1] as! UINavigationController
            if nc.topViewController is CollectionVC {
                let svc = nc.topViewController as! CollectionVC
                svc.filterType = self.filterType
            }
        }
        
        
        
        let cancle = UIAlertAction(title: "취소", style: .cancel)
        
        actionSheet.addAction(reservationRate)
        actionSheet.addAction(quaration)
        actionSheet.addAction(openTime)
        actionSheet.addAction(cancle)
        
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    func setupNavigation() {
        navigationItem.title = "예매율순"
        let barColor = UIColor(red:0.47, green:0.42, blue:0.91, alpha:1.0)
        navigationController?.navigationBar.barTintColor = barColor
    }
    
    func getJsonFromURL(getURL: String) {
        guard let url = URL(string: getURL) else {return}
        
        URLSession.shared.dataTask(with: url) { [weak self] (datas, response, error) in
            guard let `self` = self else {return}
            
            if error != nil {
                let alter = UIAlertController(title: "네트워크 장애", message: "네트워크 신호가 불안정 합니다.", preferredStyle: UIAlertController.Style.alert)
                let action = UIAlertAction(title: "확인", style: UIAlertAction.Style.default, handler: nil)
                alter.addAction(action)
                self.present(alter, animated: true, completion: nil)
            }
            
            guard let data = datas else {return}
        
            do {
                let order = try JSONDecoder().decode(orderType.self, from: data)
                
                self.movies = order.movies
                DispatchQueue.main.async {
                    self.tableview.reloadData()
                }
            }catch{
                let alter = UIAlertController(title: "네트워크 장애", message: "네트워크 신호가 불안정 합니다.", preferredStyle: UIAlertController.Style.alert)
                let action = UIAlertAction(title: "확인", style: UIAlertAction.Style.default, handler: nil)
                alter.addAction(action)
                self.present(alter, animated: true, completion: nil)
                print("Error")
            }
        }.resume()
    }
    
}


extension ViewController: UITableViewDataSource{

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellId") as! tableviewCell
        let movie = movies[indexPath.row]
    
        cell.movieDate.text = "개봉일: \(movie.date)"
        cell.movieReserRate.text = "예매율:\(movie.reservation_rate)"
        cell.movieGrade.text = "예매순위:\(movie.reservation_grade)"
        cell.movieRate.text = "평점:\(movie.user_rating)"
        cell.movieTitle.text = movie.title
        
        //download in background
        let imageURL = URL(string: movie.thumb)!
        cell.movieImage.load(url: imageURL)
    
        return cell
    }
}

extension ViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detailmoiveVC = self.storyboard?.instantiateViewController(withIdentifier: "DetailMovie") as! DetailMovieVC
        
        let backButton = UIBarButtonItem.init(title: "영화목록", style: UIBarButtonItem.Style.plain, target: nil, action: nil)
        navigationController?.navigationBar.topItem?.backBarButtonItem = backButton
        
        detailmoiveVC.navigationTitle = movies[indexPath.row].title
        detailmoiveVC.id = movies[indexPath.row].id
        self.navigationController?.pushViewController(detailmoiveVC, animated: true)
    }
}

//https://www.hackingwithswift.com/example-code/uikit/how-to-load-a-remote-image-url-into-uiimageview
//GCD개념 숙지
//한번 더 보기

//이걸 통해서 다운로드 하는게 훨씬 좋은거 같음
//https://medium.com/@rashpindermaan68/downloading-files-in-background-with-urlsessiondownloadtask-swift-xcode-download-progress-ios-2e278d6d76cb
extension UIImageView {
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
    func load(url: URL) {
        getData(from: url) { [weak self] data, response, error in
            guard let data = data, error == nil else { return }
            print("Download Finished")
            DispatchQueue.main.async() {
                self?.image = UIImage(data: data)
            }
        }
//        DispatchQueue.global(qos: .userInitiated).async {
//            if let data = try? Data(contentsOf: url) {
//                if let image = UIImage(data: data){
//                    DispatchQueue.main.async { [weak self] in
//                        guard let `self` = self else {return}
//                        self.image = image
//                    }
//                }
//            }
//        }
    }
}
extension UIImageView: URLSessionDownloadDelegate {
    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        print("다운로드 완료 하였습니다")
    }
    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        
        let progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
        
        DispatchQueue.main.async {
            print("다운로드 중입니다")
        }
    }
}
extension ViewController: URLSessionDelegate{
    
}

extension ViewController: URLSessionDataDelegate {
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        DispatchQueue.main.async {
        print("didReceive Data")
        }
    }
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didBecome downloadTask: URLSessionDownloadTask) {
        DispatchQueue.main.async {
        print("did become download Task")
        }
    }
}


