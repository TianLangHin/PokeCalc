//
//  APIFetchable.swift
//  PokeCalc
//
//  Created by Tian Lang Hin on 10/10/2025.
//

/// This protocol defines the behaviour of all resources that fetch from an external API.
protocol APIFetchable<Parameters, FetchedData> {
    // The `Parameters` generic type is the kind of data used to customise the API call.
    associatedtype Parameters
    // The `FetchedData` generic type is the kind of data returned from the API call.
    associatedtype FetchedData

    // The API fetching resources must also provide a function that performs the API call.
    // This is an external-calling process, hence is marked asynchronous.
    func fetch(_: Parameters) async -> FetchedData?
}
