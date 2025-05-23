//
//  CarAtStartlineFeature.swift
//  VisionRera
//
//  Created by Mattias Emanuel on 23.05.25.
//

// Super simple feature because we don't need any special handeling of data between
// the car at startline event and the info to the race mode.
protocol CarAtStartlineProtocol {
    func carStandsAtStartline(_ isAtStart: Bool)
}
