//
//  APIFetchable.swift
//  PokeCalc
//
//  Created by Tian Lang Hin on 10/10/2025.
//

protocol APIFetchable<Parameters, FetchedData> {
    associatedtype Parameters
    associatedtype FetchedData

    func fetch(_: Parameters) async -> FetchedData?
}
