//
//  TripReducer.swift
//  TravelApp
//
//  Created by Pankaj Rawat on 01/02/17.
//  Copyright © 2017 Pankaj Rawat. All rights reserved.
//

import ReSwift

func tripReducer(state: TripState?, action: Action) -> TripState {
    var state = state ?? initialTripState()
    
    switch action {
    case _ as ReSwiftInit:
        break
    case let action as SetFeedTrips:
        state.pushTrips(tripType: .feedTrips, trips: action.trips)
        break
    case let action as SetTrendingTrips:
        state.pushTrips(tripType: .trendingTrips, trips: action.trips)
        break
    case let action as UpdateTrips:
        action.trips.forEach({ (trip) in
            state.entities[trip.id!] = trip
        })
        break
    default:
        break
    }
    
    return state
}

func initialTripState() -> TripState {
    return TripState(feedTripIds: [], trendingTripIds: [], entities: [:], selectedTripId: nil, searchTerms: nil)
}
