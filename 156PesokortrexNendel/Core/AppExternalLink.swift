//
//  AppExternalLink.swift
//  156PesokortrexNendel
//

import Foundation

enum AppExternalLink: String {
    case privacyPolicy = "https://pesokortrex156nendel.site/privacy/141"
    case termsOfUse = "https://pesokortrex156nendel.site/terms/141"

    var url: URL? {
        URL(string: rawValue)
    }
}
