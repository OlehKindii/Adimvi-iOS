
//  MostActiveVC.swift
//  adimvi
//  Created by javed carear  on 19/06/19.
//  Copyright © 2019 webdesky.com. All rights reserved.

import UIKit
import Alamofire
import SDWebImage
class MostActiveVC: BaseViewController {
    @IBOutlet weak var labelTitle: UINavigationItem!
    @IBOutlet weak var tablemostActive: UITableView!
    @IBOutlet weak var segmentMostActive: UISegmentedControl!
    @IBOutlet weak var textLB: UILabel!
    
    var OtherUserId:String!
    var Webservice:String!
    var SegmentType:String!
    var UserID:String!
    var arrayMost =  [[String: Any]]()
    var Title:String!
    let defaults = UserDefaults.standard
    
    private var refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UserID = UserDefaults.standard.string(forKey:"ID")
        segmentMostActive.selectedSegmentIndex = 0
        segmentMostActive.addTarget(self, action: #selector(MostActiveVC.indexChanged(_:)),for:.valueChanged)
        
        self.view.addSubview(segmentMostActive)
        
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        
        if #available(iOS 10.0, *) {
            tablemostActive.refreshControl = refreshControl
        } else {
            tablemostActive.addSubview(refreshControl)
        }
        textLB.text = Title
        CallWebserviceMostActive()
        let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.darkGray]
        navigationController?.navigationBar.titleTextAttributes = textAttributes
        
        UISegmentedControl.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.black], for: .selected)
        UISegmentedControl.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: .normal)
        
        self.navigationItem.rightBarButtonItem = nil
    }
    
    @objc func refreshData() {
        segmentMostActive.isHidden = true
        CallWebserviceMostActive()
    }
    
    @IBAction func OnBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UserID = UserDefaults.standard.string(forKey: "ID")
        CallWebserviceMostActive()
        self.tabBarController?.tabBar.isHidden = true
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        self.tabBarController?.tabBar.isHidden = false
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    @objc func indexChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex{
        case 0:
            SegmentType = "0"
            CallWebserviceMostActive()
            return
        case 1:
            SegmentType = "1"
            CallWebserviceMostActive()
            return
        case 2:
            SegmentType = "2"
            CallWebserviceMostActive()
            return
        default:
            break
        }
    }
    
    func CallWebserviceMostActive(){
        let Para =
            ["userid":"\(UserID!)","type":"\(SegmentType!)","per_page":"100","current_page":"0"] as [String : Any]
        let Api:String = "\(WebURL.BaseUrl)\(Webservice!)"
        print(Api)
        objActivity.startActivityIndicator()
        Alamofire.request(Api, method: .post,parameters:Para)
            .responseJSON { response in
                self.refreshControl.endRefreshing()
                self.segmentMostActive.isHidden = false
                switch(response.result) {
                case .success(_):
                    if response.result.value != nil{
                        debugPrint(response.result)
                        let myData = response.result.value as! [String :Any]
                        let code = myData["code"] as! String
                        if code == "200"{
                            self.tablemostActive.isHidden = false
                            if let arr = myData["response"] as? [String:Any]{
                                if let Data = arr["posts"]as? [[String:Any]]{
                                    self.arrayMost = Data
                                    self.tablemostActive.reloadData()
                                }
                            }
                        }else{
                            self.tablemostActive.isHidden = true
                        }
                        objActivity.stopActivity()
                    }
                    objActivity.stopActivity()
                    break
                case .failure(_):
                    objActivity.stopActivity()
                    print(response.result.error as Any)
                    break
                }
            }
    }
}


//Mark:- UITableView delegate Methods
extension MostActiveVC:UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
}
//Mark:- UItableView DataSource Methods
extension MostActiveVC:UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayMost.count
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.frame.height
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.frame.height
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MostActiveTVCell") as! MostActiveTVCell
        let dictData = self.arrayMost[indexPath.row]
        if let Title = dictData["title"] as? String {
            cell.lableTitle.text = Title
        }
        if let verify = dictData["verify"] as? String {
            cell.verifiedMarker.isHidden = verify == "1" ? false : true
        }
        if let CategotiesName = dictData["category_name"] as? String {
            cell.buttonCategoriesname.setTitle(CategotiesName, for: .normal)
        }
        if let PostContent = dictData["shortPostLink"] as? String {
            cell.webviewContent.backgroundColor = .clear
            cell.webviewContent.isOpaque = false
            cell.webviewContent.loadRequest(URLRequest(url: URL(string: "\(PostContent)")!))
        }
        if let userName = dictData["handle"] as? String {
            cell.labelUserName.text = userName
        }
        if let CategoriesName = dictData["category_name"] as? String {
            cell.buttonCategoriesname.setTitle( CategoriesName, for: .normal)
        }
        if let Like = dictData["like"] as? String {
            cell.buttonLike.setTitle( Like, for: .normal)
        }
        if let View = dictData["views"] as? String {
            cell.buttonSeen.setTitle( View, for: .normal)
        }
        if let comment = dictData["comments"] as? String {
            cell.buttonMessage.setTitle( comment, for: .normal)
        }
        if let Time = dictData["post_created"] as? String {
            cell.buttonSeenTime.setTitle(Time, for: .normal)
        }        
        if  let Image = dictData["post_image"] as? String{
            cell.imageMostActive.sd_setImage(with: URL(string: Image), placeholderImage: UIImage(named: "Place.png"))
        }
        if  let profilePic = dictData["avatarblobid"] as? String{
            let imageURl = "\(WebURL.ImageUrl)\(profilePic)"
            cell.ProfilePic.sd_setImage(with: URL(string: imageURl), placeholderImage: UIImage(named: "Splaceicon"))
        } else {
            cell.ProfilePic.image = UIImage(named: "Splaceicon")
        }
        if let hasRecentPost = dictData["hasRecentPost"] as? Int {
            if hasRecentPost == 1{
                if (dictData["userid"] as! String) != UserID {
                    cell.recentWallUV.layer.borderWidth = 2.0
                } else {
                    cell.recentWallUV.layer.borderWidth = 0.0
                }
            } else {
                cell.recentWallUV.layer.borderWidth = 0.0
            }
        }
        if let Post = dictData["post_followup"] as? String {
            if Post == "1"{
                cell.buttonFollow.isHidden = true
                cell.buttonUnFollow.isHidden = false
            }else{
                cell.buttonFollow.isHidden = false
                cell.buttonUnFollow.isHidden = true
            }
        }
        if let Pricer = dictData["pricer"] as? String{
            let Buy = dictData["post_buy"] as! String
            let Postuser = dictData["userid"]as! String
            if Pricer == "1"{
                cell.labelPrice.isHidden = false
                if Buy == "1"&&UserID != Postuser{
                    cell.labelPrice.isHidden = false
                    cell.labelPrice.text = "Libre"
                    cell.labelPrice.textColor = UIColor(named: "labelBuy")
                } else {                    
                    let price = dictData["price"] as! String
                    cell.labelPrice.text = price
                    cell.labelPrice.textColor = UIColor(named: "labelPrice")
                }
            }else{
                cell.labelPrice.isHidden = true
            }
        }
        if let Rating = dictData["avgRating"] as? Double {
            cell.RatingView.rating = Rating
        }
        if let Votas = dictData["ratingVotes"] as? String {
            cell.labelVotes.text = Votas
        }
        cell.buttonPostDetail.tag = indexPath.row
        cell.buttonPostDetail.addTarget(self, action: #selector(self.OnPostDetail(_:)), for: UIControl.Event.touchUpInside)
        cell.buttonProfileDetail.tag = indexPath.row
        cell.buttonProfileDetail.addTarget(self, action: #selector(self.OnProfile(_:)), for: UIControl.Event.touchUpInside)
        cell.buttonCategoriesname.tag = indexPath.row
        cell.buttonCategoriesname.addTarget(self, action: #selector(self.OnCategories(_:)), for: UIControl.Event.touchUpInside)
        cell.buttonShare.tag = indexPath.row
        cell.buttonShare.addTarget(self, action: #selector(self.OnShare(_:)), for: UIControl.Event.touchUpInside)
        cell.buttonFollow.tag = indexPath.row
        cell.buttonFollow.addTarget(self, action: #selector(self.OnFollow(_:)), for: UIControl.Event.touchUpInside)
        cell.buttonUnFollow.tag = indexPath.row
        cell.buttonUnFollow.addTarget(self, action: #selector(self.OnFollow(_:)), for: UIControl.Event.touchUpInside)
        cell.remuroUB.tag = indexPath.row
        cell.remuroUB.addTarget(self, action: #selector(onTapRemuroUB), for: .touchUpInside)
        cell.labelPrice.layer.cornerRadius = 8.0
        cell.labelPrice.layer.masksToBounds = true
        return cell
        
    }
    
    @objc func onTapRemuroUB(sender: UIButton) {
        let dict = self.arrayMost[sender.tag]
        let vc: ProfilerootViewController = self.storyboard?.instantiateViewController(withIdentifier:"ProfilerootViewController")as! ProfilerootViewController
        SharedManager.sharedInstance.otherProfile = "1"
        vc.isFromPostDetail = true
        vc.orginalPostData = [
            "origin_post_id": dict["postid"]!,
            "orgin_post_image": dict["post_image"]!,
            "orgin_post_title": dict["title"]!,
            "origin_post_created": dict["post_date"]!
        ]
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func OnPostDetail(_ sender : UIButton) {
        let dict = self.arrayMost[sender.tag]
        let Post = dict["postid"] as! String
        let vc: PostDetailsViewController = self.storyboard?.instantiateViewController(withIdentifier:"PostDetailsViewController")as! PostDetailsViewController
        vc.hidesBottomBarWhenPushed = true
        vc.PostID = Post
        SharedManager.sharedInstance.PostId = Post
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    @objc func OnProfile(_ sender : UIButton) {
        let dict = self.arrayMost[sender.tag]
        let OtherId = dict["userid"] as! String
        self.defaults.set(OtherId, forKey: "OtherUserID")
        let vc: ProfilerootViewController = self.storyboard?.instantiateViewController(withIdentifier:"ProfilerootViewController")as! ProfilerootViewController
        SharedManager.sharedInstance.otherProfile = "1"
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    @objc func OnCategories(_ sender : UIButton) {
        let dict = self.arrayMost[sender.tag]
        let Title = dict["category_name"] as! String
        let ID = dict["categoryid"] as! String
        let vc: CategoriesDetailViewController = self.storyboard?.instantiateViewController(withIdentifier: "CategoriesDetailViewController")as! CategoriesDetailViewController
        vc.hidesBottomBarWhenPushed = true
        vc.CategoriesID = ID
        vc.titleCategories.title = Title
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func OnFollow(_ sender: UIButton) {
        let dict = self.arrayMost[sender.tag]
        let User = dict["userid"] as! String
        OtherUserId = User
        CallWebSetFollow(sender.tag)
    }
    
    
    @objc func OnShare(_ sender : UIButton) {
        let dict = self.arrayMost[sender.tag]
        let ShareLink = dict["share_link"] as! String
        let shareText = "\(ShareLink)"
        let activityViewController = UIActivityViewController(activityItems: [shareText], applicationActivities: nil)
        DispatchQueue.main.async() { () -> Void in
            self.present(activityViewController, animated: true, completion: nil)
        }
    }
    
    func CallWebSetFollow(_ index: Int){
        let Para =
            ["entityid":"\(OtherUserId!)","userid":"\(UserID!)"] as [String : Any]
        
        
        let Api:String = "\(WebURL.BaseUrl)\(WebURL.setUserFollowing)"
        let dict = arrayMost[index] as [String: Any]
        if let Post = dict["post_followup"] as? String {
            if Post == "1"{
                NotificationCenter.default.post(name: .didChangePostByFollowUser, object: nil, userInfo: ["removeUserID": self.OtherUserId!])
            }else{
                NotificationCenter.default.post(name: .didChangePostByFollowUser, object: nil)
            }
        }
        Alamofire.request(Api, method: .post,parameters:Para)
            .responseJSON { response in
                switch(response.result) {
                case .success(_):
                    if response.result.value != nil{
                        self.CallWebserviceMostActive()
                    }
                    break
                case .failure(_):
                    objActivity.stopActivity()
                    print(response.result.error as Any)
                    break
                }
            }
        
    }
    
}

class MostActiveTVCell: UITableViewCell {
    @IBOutlet weak var buttonFollow: UIButton!
    @IBOutlet weak var buttonUnFollow: UIButton!
    @IBOutlet weak var imageMostActive: UIImageView!
    @IBOutlet weak var lableTitle: UILabel!
    @IBOutlet weak var labelUserName: UILabel!
    @IBOutlet weak var labelPrice: UILabel!
    @IBOutlet weak var ProfilePic: UIImageView!
    @IBOutlet weak var buttonSeen: UIButton!
    @IBOutlet weak var buttonSeenTime: UIButton!
    @IBOutlet weak var buttonShare: UIButton!
    @IBOutlet weak var buttonLike: UIButton!
    @IBOutlet weak var buttonMessage: UIButton!
    @IBOutlet weak var buttonCategoriesname: UIButton!
    @IBOutlet weak var buttonPostDetail: UIButton!
    @IBOutlet weak var buttonProfileDetail: UIButton!
    @IBOutlet weak var webviewContent: UIWebView!
    @IBOutlet weak var verifiedMarker: UIImageView!
    @IBOutlet weak var recentWallUV: UIView!
    
    @IBOutlet var RatingView: FloatRatingView!
    @IBOutlet weak var labelVotes: UILabel!
    @IBOutlet weak var remuroUB: UIButton!
}
