//
//  FontSelectionViewController.swift
//  DailyAthkar
//
//  Created by Mohamed ElSIfi on 8/19/18.
//  Copyright © 2018 Badi3.com. All rights reserved.
//

import UIKit

class FontSelectionViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var tableView: UITableView!
    var fonts : [UIFont] {
        switch LanguageManager.currentLanguageCode()! {
        case "ar":
            return [
                DA_STYLE.arabicFonts.AlQalamQuranMajeed1,
                DA_STYLE.arabicFonts.AmiriRegular,
                DA_STYLE.arabicFonts.DroidArabicKufi,
                DA_STYLE.arabicFonts.DroidArabicNaskh,
                DA_STYLE.arabicFonts.Lateef,
                DA_STYLE.arabicFonts.MohammadBoldArt2,
                DA_STYLE.arabicFonts.noorHiraFont,
                DA_STYLE.arabicFonts.PDMS_Saleem_QuranFont,
                DA_STYLE.arabicFonts.Scheherazade
            ]
        case "en":
            return [
                DA_STYLE.englishFonts.DroidSans,
                DA_STYLE.englishFonts.DroidSerif,
                DA_STYLE.englishFonts.DroidSerifItalic,
                DA_STYLE.englishFonts.OpenSans,
                DA_STYLE.englishFonts.OpenSansItalic,
                DA_STYLE.englishFonts.OpenSansLight,
                DA_STYLE.englishFonts.OpenSansLightItalic,
                DA_STYLE.englishFonts.RobotoThin,
                DA_STYLE.englishFonts.UbuntuLight,
                DA_STYLE.englishFonts.UbuntuLightItalic
            ]
        default:
            return []
        }
    }
    
    @IBOutlet weak var stepper: UIStepper!
    var testText = LanguageManager.currentLanguageCode()! == "ar" ? "هكذا سيبدو النص النهائي \n وهذا سطر آخر لضمان سهولة القراءة" : "This is how the text will appear. \n And this is another line to make sure text is legible"
    var tableTestText = LanguageManager.currentLanguageCode()! == "ar" ? "اضغط لتجربة هذا الخط" : "Tap to try this font"

    @IBOutlet weak var topLabel: UILabel!{
        didSet{
            topLabel.text = self.testText
        }
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = UITableView.automaticDimension
        topLabel.font = DA_STYLE.savedFont

        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "save".localized, style: .plain, target: self, action: #selector(saveAction))

        
    }
    
    @objc func saveAction(){
        

        DA_STYLE.saveFont(font: topLabel.font)
        _ = self.navigationController?.popViewController(animated: true)
        
    }
    @IBAction func stepperAction(_ sender: UIStepper) {
        self.topLabel.font = self.topLabel.font.withSize(CGFloat.init(sender.value))
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fonts.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let font = self.fonts[indexPath.row]
        self.stepper.value = Double.init(font.pointSize)
        topLabel.font = font
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        let label = cell.viewWithTag(1) as! UILabel
        let font = self.fonts[indexPath.row]
        label.font = font
        label.text = self.tableTestText
        return cell
    }

}
