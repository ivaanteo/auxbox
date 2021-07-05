//
//  GradientLayer.swift
//  AuxBox
//
//  Created by Ivan Teo on 27/4/21.
//

import UIKit

class Colors {
    var gl:CAGradientLayer!
    init() {
        self.gl = CAGradientLayer()
        self.gl.colors = [UIColor(named: K.Colours.orange)?.cgColor, UIColor(named: K.Colours.purple)?.cgColor]
        self.gl.locations = [0.0, 1.0]
        self.gl.startPoint = CGPoint(x: 0, y: 0)
        self.gl.endPoint = CGPoint(x: 1, y: 1)
    }
}

