//
//  Environments.swift
//  artiusid
//
//  Created by Nelson Soler on 10/25/24.
//
public enum Environments: String, CaseIterable, Identifiable {
    case Development = "Development"
    case Localhost = "Local Host"
    case Production = "Production"
    case QA = "QA"
    case Staging = "Staging"
    public var id: Self { self }
}
