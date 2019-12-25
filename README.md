# RCheckVersion

## Swift Package Manager
A description of this package.

## App 版本檢查

```
enum UpdateType {
    /// 大版更新
    case bigVersion
    /// 小版更新
    case smallVersion
    /// 不需更新
    case none
}
```

- 自訂版本更新時，是為重大更新或者微調整更新

```
RCheckVersion.share.majorVersion = 2
```

ex: 1. 架上版本為 1.0.2 手機本版為 1.0.1 則為 `微調更新`
    2. 架上版本為 1.1.0 手機本版為 1.0.1 則為 `重大更新`

設定

```
RCheckVersion.share.majorVersion = 1
```

ex: 1. 架上版本為 1.0.2 手機本版為 1.0.1 則為 `微調更新`
    2. 架上版本為 1.1.0 手機本版為 1.0.1 則為 `微調更新`
    3. 架上版本為 2.0.0 手機本版為 1.0.1 則為 `重大更新`

- 檢查版本

1. 版本資料來源於 itunes

需更新時 show Alert
```
RCheckVersion.share.checkVersion()
```

or 

自訂更新事件
```
RCheckVersion.share.checkVersion { (versioin) in
    /// 商店連結
    versioin.storeLink
    /// 版本訊息
    versioin.updateType
}
```

2. 自訂版本控制連結

回傳版本與商店連結
```
RCheckVersion.share.custom(url: "url") { ([String: Any]]) -> ((version: String, storeLink: String)) in
    
    ...

    return (version, storeLink)
}
```