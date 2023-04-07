//
//  Localization.swift
//  ExaironMessenger.Framework.IOSSDK
//
//  Created by Exairon on 7.04.2023.
//

import Foundation

fileprivate class Exairon_en {
    func locale(key: String) -> String {
        switch key {
        case "howWasYourExp": return "How was your experience?"
        case "surveyHint": return "Please tell us about your opinion..."
        case "submit": return "Submit"
        case "name": return "Name"
        case "surname": return "Surname"
        case "email": return "E-mail"
        case "phone": return "Phone Number"
        case "namePlaceholder": return "Plase enter your name"
        case "surnamePlaceholder": return "Please enter your surname"
        case "emailPlaceholder": return "Please enter your e-mail"
        case "phonePlaceholder": return "Please enter your number"
        case "formTitle": return "Please fill in the details completely so what that we can keep in touch with you."
        case "formDesc": return "Fields ending with * are required to be filled."
        case "formError": return "Please fill in the fields correctly."
        case "startSession": return "Start Session"
        case "sessionFinishMessage": return "Do you really want to end the session?"
        case "yes": return "Yes"
        case "camera": return "Camera"
        case "gallery": return "Gallery"
        case "file": return "File"
        case "location": return "Location"
        case "cancel": return "Cancel"
        case "back": return "Back"
        case "fileSizeErrorTitle": return "File size error!"
        case "fileSizeErrorDescription": return "You can upload files up to 1MB in size."
        case "targetLocation": return "Target Location"
        case "chatActions": return "Chat Actions"
        default: return ""
        }
    }
}

fileprivate class Exairon_tr {
    func locale(key: String) -> String {
        switch key {
        case "howWasYourExp": return "Görüşme deneyimin nasıldı?"
        case "surveyHint": return "Lütfen bize görüşlerinizi bildirin..."
        case "submit": return "Gönder"
        case "name": return "Adınız"
        case "surname": return "Soyadınız"
        case "email": return "E-mail"
        case "phone": return "Telefon Numarası"
        case "namePlaceholder": return "Lütfen adınızı girin..."
        case "surnamePlaceholder": return "Lütfen soyadınızı girin..."
        case "emailPlaceholder": return "Lütfen e-postanızı girin..."
        case "phonePlaceholder": return "Lütfen numaranızı girin..."
        case "formTitle": return "Sizinle iletişimde kalabilmemiz için lütfen bilgilerinizi eksiksiz doldurunuz"
        case "formDesc": return "* ile biten alanların doldurulması zorunludur."
        case "formError": return "Lütfen alanları doğru şekilde doldurunuz."
        case "startSession": return "Oturumu Başlat"
        case "sessionFinishMessage": return "Gerçekten oturumu bitirmek istiyor musunuz?"
        case "yes": return "Evet"
        case "camera": return "Kamera"
        case "gallery": return "Galeri"
        case "file": return "Dosya"
        case "location": return "Konum"
        case "cancel": return "İptal"
        case "back": return "Geri"
        case "fileSizeErrorTitle": return "Dosya boyutu hatası!"
        case "fileSizeErrorDescription": return "En fazla 1MB boyutunda dosya yükleyebilirsiniz."
        case "targetLocation": return "Hedef Konum"
        case "chatActions": return "Görüşme Aksiyonları"
        default: return ""
        }
    }
}


struct Localization {
    func locale(key: String) -> String {
        if (Exairon.shared.language == "tr") {
            return Exairon_tr().locale(key: key)
        }
        return Exairon_en().locale(key: key)
    }
}
