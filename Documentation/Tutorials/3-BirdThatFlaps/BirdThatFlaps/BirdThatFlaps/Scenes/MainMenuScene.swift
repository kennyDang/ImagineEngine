//
//  GameScene.swift
//  BirdThatFlaps
//
//  Created by Kenny Dang on 1/27/18.
//  Copyright © 2018 Kenny Dang. All rights reserved.
//

import ImagineEngine
import SpriteKit

final class MainMenuScene: Scene {

    // MARK: - Instance properties

    lazy var titleLabel: Label = {
        let label = Label(text: "Bird That Flaps")
        label.textColor = .white
        label.position = center
        label.position.y -= 100
        label.font = UIFont(name: "flappyBirdy", size: 80)!
        label.fadeIn(withDuration: 3)

        return label
    }()

    lazy var playButtonActor: Actor = {
        let actor = Actor(image: #imageLiteral(resourceName: "Play Button"))
        actor.position = center

        return actor
    }()

    // MARK: - Setup methods

    override func setup() {
        setupView()
        addActors()
        setupPlayButton()
    }

    private func setupView() {
        backgroundColor = .backgroundColor
    }

    private func addActors() {
        add(titleLabel)
        add(playButtonActor)
    }

    private func setupPlayButton() {
        playButtonActor.events.clicked.observe {
            self.game?.scene = BirdThatFlapsScene(size: UIScreen.main.bounds.size)
        }
    }
    
}
