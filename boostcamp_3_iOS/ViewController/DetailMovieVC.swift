//
//  DetailMovieViewController.swift
//  boostcamp_3_iOS
//
//  Created by admin on 05/12/2018.
//  Copyright © 2018 wndzlf. All rights reserved.
//

import UIKit

class DetailMovieVC: UIViewController {
    
    var id: String?
    var navigationTitle: String?
    
    var comments = [oneLine]()
    var movie:detailMovie?
    
    var fieldValue: Any?
    var fieldValue2: Any?
    
    @IBOutlet var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigation()
        
        
        if let movie_id = id {
                let url = "http://connect-boxoffice.run.goorm.io/movie?id=\(movie_id)"
                let commmentsURL = "http://connect-boxoffice.run.goorm.io/comments?movie_id=\(movie_id)"
            
                getJsonFromURL(getURL: url)
                getJsonFromCommentURL(getURL: commmentsURL)
        }
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.rowHeight = UITableView.automaticDimension
    }
    
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        let tappedImage = tapGestureRecognizer.view as! UIImageView
        
        let showVC = self.storyboard?.instantiateViewController(withIdentifier: "showFullPosterVC") as! showFullPosterVC
        
        self.present(showVC, animated: false) {
            showVC.fullScreen.image = tappedImage.image
        }
        
    }
    
    func setupNavigation() {
        navigationItem.title = navigationTitle
    }
    
    func getJsonFromCommentURL(getURL: String) {
        guard let url = URL(string: getURL) else {return}
        
        URLSession.shared.dataTask(with: url) { [weak self] (datas, response, error) in
           DispatchQueue.main.async {
                guard let `self` = self else {return}
            
                let httpResponse = response as! HTTPURLResponse
                self.fieldValue = httpResponse.allHeaderFields["Content-Length"]
                print(self.fieldValue)
            
                if error != nil {
                    let alter = UIAlertController(title: "네트워크 장애", message: "네트워크 신호가 불안정 합니다.", preferredStyle: UIAlertController.Style.alert)
                    let action = UIAlertAction(title: "확인", style: UIAlertAction.Style.default, handler: nil)
                    alter.addAction(action)
                    self.present(alter, animated: true, completion: nil)
                }
                guard let data = datas else {return}
            
                do{
                    let one = try JSONDecoder().decode(superoneLine.self, from: data)
                    self.comments = one.comments
                    self.tableView.reloadData()
                }catch{
                    let alter = UIAlertController(title: "네트워크 장애", message: "네트워크 신호가 불안정 합니다.", preferredStyle: UIAlertController.Style.alert)
                    let action = UIAlertAction(title: "확인", style: UIAlertAction.Style.default, handler: nil)
                    alter.addAction(action)
                    self.present(alter, animated: true, completion: nil)
                    print("error getJsonFromCommentURL")
                }
            }
        }.resume()
    }
    
    func getJsonFromURL(getURL: String) {
        guard let url = URL(string: getURL) else {return}
        URLSession.shared.dataTask(with: url) { [weak self] (datas, response, error) in
            DispatchQueue.main.async {
                guard let `self` = self else {return}
                
                let httpResponse = response as! HTTPURLResponse
                self.fieldValue2 = httpResponse.allHeaderFields["Content-Length"]
                print(self.fieldValue2!)
                
                if error != nil {
                    let alter = UIAlertController(title: "네트워크 장애", message: "네트워크 신호가 불안정 합니다.", preferredStyle: UIAlertController.Style.alert)
                    let action = UIAlertAction(title: "확인", style: UIAlertAction.Style.default, handler: nil)
                    alter.addAction(action)
                    self.present(alter, animated: true, completion: nil)
                }
                
                //response를 확인해보면 status code는 200으로 문제가 없지만 content-length가 가끔씩 짧은게 전송된다.
                //print(response.debugDescription)
                //10번에 1번꼴로 데이터를 받아오지 못함.
                guard let data = datas else {return}
                
                do{
                    let detail = try JSONDecoder().decode(detailMovie.self, from: data)
                    self.movie = detail
                    self.tableView.reloadData()
                    
                }catch{
                    let alter = UIAlertController(title: "네트워크 장애", message: "네트워크 신호가 불안정 합니다.", preferredStyle: UIAlertController.Style.alert)
                    let action = UIAlertAction(title: "확인", style: UIAlertAction.Style.default, handler: nil)
                    alter.addAction(action)
                    self.present(alter, animated: true, completion: nil)
                    print("Error getJsonFromURL")
                }
            }
        }.resume()
    }
    
}

extension DetailMovieVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 240
        //줄거리 길이에 따라 섹션 height 수정하기
        }else if indexPath.section == 1{
            return UITableView.automaticDimension
        }else {
            return 120
        }
        
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 3
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel()
        label.backgroundColor = .lightGray
        return label
    }
    
}

extension DetailMovieVC: UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }else if section == 1 {
            return 1
        }else {
            return self.comments.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = self.tableView.dequeueReusableCell(withIdentifier: "cellId") as! posterCell
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
            
            cell.poster.isUserInteractionEnabled = true
            cell.poster.addGestureRecognizer(tapGestureRecognizer)
            
            if let movie = self.movie {
                let url = URL(string: movie.image)!
                cell.poster.load(url: url)
                cell.title.text = movie.title
                cell.date.text = movie.date
                cell.genre.text = movie.genre
                cell.reservation_rate.text = "\(movie.reservation_rate)"
                cell.user_rating.text = "\(movie.user_rating)"
                cell.audience.text = "\(movie.audience)"
            }
            return cell
        }else if indexPath.section == 1{
            let cell = self.tableView.dequeueReusableCell(withIdentifier: "cellId1") as! contentsCell
            cell.content.text = self.movie?.synopsis
            cell.content.isScrollEnabled = false
            cell.content.isEditable = false
            return cell
        }else {
            let cell = self.tableView.dequeueReusableCell(withIdentifier: "cellId2") as! commentCell
            let comment = self.comments[indexPath.row]
            cell.writer.text = comment.writer
            cell.rating.text = "\(comment.rating)"
            
            
            let date = Date(timeIntervalSince1970: comment.timestamp)
            
            let dateFormatter = DateFormatter()
            dateFormatter.timeZone = TimeZone(abbreviation: "GMT") //Set timezone that you want
            dateFormatter.locale = NSLocale.current
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss" //Specify your format that you want
            let strDate = dateFormatter.string(from: date)
            

            cell.timestamp.text = "\(strDate)"
            cell.contents.text = comment.contents
            return cell
        }
        
    }
}
