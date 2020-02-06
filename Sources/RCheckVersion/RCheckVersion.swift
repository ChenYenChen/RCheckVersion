//
//  RCheckVersion.swift
//

import UIKit

/// App 版本 檢查
public class RCheckVersion {
    
    public static let share: RCheckVersion = RCheckVersion()
    /// 大版號位置 代表數字  (1.0.0 ->  [0, 1, 2])
    public var majorVersion: Int = 2
    // 取得版本資訊網址
    private var linkURL: String = "https://itunes.apple.com/tw/lookup?bundleId=\(Bundle.main.bundleIdentifier ?? "")"
    // Alert 屬性
    private var alertOption: RAlertOption = RAlertOption()
    // 目前版本
    lazy private var currentVersion: String = {
        guard let current = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String else { return "" }
        return current
    }()
    // getVersion call back
    private var getVersionBlock: (([String: Any]) -> ((version: String, storeLink: String)))?
    
    // custom action
    private var customAction: ((VersionData) -> Void)?
    
    // 版本資訊
    public typealias VersionData = (updateType: UpdateType, storeLink: String)
    
    public enum UpdateType {
        /// 大版更新
        case bigVersion
        /// 小版更新
        case smallVersion
        /// 不需更新
        case none
    }
    
    // MARK: - 設定 Alert 屬性
    
    /// 設定 Alert 屬性
    /// - Parameter option: 設定 Alert 文字訊息
    public func setAlert(option: RAlertOption) {
        self.alertOption = option
    }
    
    // MARK: - 自訂版本控制網址
    
    /// 自訂版本控制網址
    /// - Parameters:
    ///   - url: 自訂網址
    ///   - getVersion: 解析回傳 架上版本 與 商店位址
    ///   - customAction: 自訂版本控制事件 。default： 顯示彈跳視窗
    public func custom(url: String, getVersion: @escaping ([String: Any]) -> ((version: String, storeLink: String)), customAction: ((VersionData) -> Void)? = nil) {
        self.linkURL = url
        self.getVersionBlock = getVersion
        self.customAction = customAction ?? self.setDefaultAction()
        self.getVersion()
    }
    
    // MARK: - 檢查版本
    
    /// 至 itunes 取得版本資訊
    /// - Parameter customAction: 自訂版本控制事件 。default： 顯示彈跳視窗
    public func checkVersion(customAction: ((VersionData) -> Void)? = nil) {
        self.customAction = customAction ?? self.setDefaultAction()
        self.getVersionBlock = { [unowned self] data in
            return self.parser(json: data)
        }
        self.getVersion()
    }
    
    // MARK: - error action
    private func errorBlock() {
        DispatchQueue.main.async {
            self.customAction?((.none, ""))
        }
    }
    
    // MARK: - 至 App Store 查看版本資訊
    private func getVersion() {
        guard let url = URL(string: self.linkURL) else {
            self.errorBlock()
            return
        }
        URLSession.shared.dataTask(with: url) { (responseData, response, error) in
            guard let data = responseData, let urlResponse = response as? HTTPURLResponse, urlResponse.statusCode == 200 else {
                self.errorBlock()
                return
            }
            do {
                guard let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] else {
                    self.errorBlock()
                    return
                }
                guard let version = self.getVersionBlock?(json) else {
                    self.errorBlock()
                    return
                }
                let type = self.checkVersion(store: version.version, with: self.currentVersion, version: self.majorVersion)
                DispatchQueue.main.async {
                    self.customAction?((type, version.storeLink))
                }
            } catch {
                self.errorBlock()
            }
        }.resume()
    }
    
    /// - Parameters:
    ///   - version: 線上版本
    ///   - currentVersion: 本機版本
    ///   - position: 版本號哪個位置(包含)之前的為大版號
    private func checkVersion(store version: String,with currentVersion: String, version position: Int) -> UpdateType {
        var storeArray = version.components(separatedBy: ".")
        var localArray = currentVersion.components(separatedBy: ".")
        let differentCount = abs(storeArray.count - localArray.count)
        if storeArray.count > localArray.count {
            for _ in 0..<differentCount {
                localArray.append("0")
            }
        } else if storeArray.count < localArray.count {
            for _ in 0..<differentCount {
                storeArray.append("0")
            }
        }
        guard storeArray.count > 0 && localArray.count > 0 else { return .none }
        guard storeArray.count > position && localArray.count > position else {
            return self.checkVersion(store: version, with: currentVersion, version: localArray.count - 1)
        }
        for row in 0..<localArray.count {
            if let storeVersion = Int(storeArray[row]), let local = Int(localArray[row]), storeVersion != local {
                if storeVersion > local {
                    return row < position ? .bigVersion : .smallVersion
                } else {
                    return .none
                }
            }
        }
        return .none
    }
    
    // MARK: - parser itunes json
    private func parser(json: [String: Any]) -> (version: String, storeLink: String) {
        var versionData: (version: String, storeLink: String) = ("", "")
        guard let result = json["data"] as? [String: Any],
            let track = result["store"] as? String,
            let version = result["version"] as? String else { return versionData }
        versionData.version = version
        versionData.storeLink = track
        return versionData
    }
    
    // MARK: - default set Alert Action
    private func setDefaultAction() -> ((VersionData) -> Void) {
        return { [unowned self] information in
            guard information.updateType != .none else { return }
            self.Alert(store: information.storeLink, updateType: information.updateType)
        }
    }
    
    // MARK: - Alert
    private func Alert(store url: String, updateType: UpdateType) {
        let alert = UIAlertController(title: self.alertOption.alertTitle, message: "", preferredStyle: .alert)
        var button = UIAlertAction(title: self.alertOption.confirmTitle, style: .default) { (action) in
            self.openAppStore(with: url)
        }
        alert.addAction(button)
        
        if self.alertOption.showNextType.contains(updateType) {
            button = UIAlertAction(title: self.alertOption.nextTimeTitle, style: .cancel) { (action) in
                self.alertOption.nextUpdateAction?()
            }
            alert.addAction(button)
        }
        
        UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
    }
    // MARK: - open Apple Store
    private func openAppStore(with trackURL: String) {
        guard let url = URL(string: trackURL) else { return }
        guard UIApplication.shared.canOpenURL(url) else { return }
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
    }
}

