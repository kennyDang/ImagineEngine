//
//  AccelerationPlugin.swift
//  BirdThatFlaps
//
//  Created by Kenny Dang on 2/1/18.
//  Copyright © 2018 Kenny Dang. All rights reserved.
//

import ImagineEngine
import Foundation

class AccelerationPlugin: Plugin {
    private let acceleration: Metric
    private var actionToken: ActionToken?

    init(acceleration: Metric) {
        self.acceleration = acceleration
    }

    func activate(for actor: Actor, in game: Game) {
        let acceleration = self.acceleration
        var velocity = actor.velocity.dy

        let action = ClosureAction<Actor>(duration: 1) { context in
            velocity += Metric(context.timeSinceLastUpdate) * acceleration
            context.object.position.y += velocity
        }

        actionToken = actor.perform(action)
    }

    func deactivate() {
        actionToken?.cancel()
        actionToken = nil
    }
}
