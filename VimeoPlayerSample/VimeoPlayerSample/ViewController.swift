//
//  ViewController.swift
//  
//  
//  Created by maeda.tasuku on 2021/09/14
//  
//

import UIKit
import WebKit
import Combine

class ViewController: UIViewController {

    var subscriptions: Set<AnyCancellable> = []
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var contentViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var largeImageView: UIImageView!
    @IBOutlet weak var webViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var webView: WKWebView!
    var videoInfo: VimeoVideoInfo?
    
    let videoId: String = "601252574"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        contentViewHeightConstraint.constant = 1200
        webView.isHidden = true
        
        fetchVimeoVideoInfo(videoId: videoId)
    }
    
    func setupWebView() {
        guard let videoInfo = videoInfo else { return }
        let screenW = UIScreen.main.bounds.width
        let webViewHeight: CGFloat = (screenW - 30 * 2) * CGFloat(videoInfo.height) / CGFloat(videoInfo.width)
        
        webViewHeightConstraint.constant = webViewHeight
        
        guard let url = URL(string: "http://localhost:8090/?id=\(videoInfo.videoId)") else { return }
        let req = URLRequest(url: url)
        webView.navigationDelegate = self
        webView.load(req)
    }
    
    func fetchVimeoVideoInfo(videoId: String) {
        createVimeoGetVideoInfoRequest(videoId: videoId)
            .receive(on: DispatchQueue.global(qos: .userInitiated))
            .sink(receiveCompletion: { [weak self] completion in
                guard let self = self else { return }
                switch completion {
                case .finished:
                    DispatchQueue.main.async {
                        self.setupWebView()
                    }
                case .failure(let error):
                    print("Error: \(error.localizedDescription)")
                }
            }, receiveValue: { [weak self] videoInfo in
                self?.videoInfo = videoInfo
            }).store(in: &subscriptions)
    }
    
    func createVimeoGetVideoInfoRequest(videoId: String) -> AnyPublisher<VimeoVideoInfo, VimeoError> {
        let api = VimeoGetVideoInfoRequest(videoId: videoId)
        guard let url = api.url else {
            fatalError("cannot make url")
        }
        let req = URLRequest(url: url)
        return URLSession.shared.dataTaskPublisher(for: req)
            .tryMap { (data, response) -> Data in
                guard let httpRes = response as? HTTPURLResponse,
                      200 ..< 300 ~= httpRes.statusCode  else {
                    throw VimeoError.fetch
                }
                return data
            }
            .decode(type: VimeoVideoInfo.self, decoder: JSONDecoder())
            .mapError{ VimeoError.map($0) }
            .eraseToAnyPublisher()
    }
}

extension ViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if webView.isHidden {
            webView.isHidden = false
        }
    }
}
