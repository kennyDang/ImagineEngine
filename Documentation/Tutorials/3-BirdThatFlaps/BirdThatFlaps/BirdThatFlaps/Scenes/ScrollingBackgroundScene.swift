//
//  ScrollingBackgroundScene.swift
//  BirdThatFlaps
//
//  Created by Kenny Dang on 1/27/18.
//  Copyright © 2018 Kenny Dang. All rights reserved.
//

import ImagineEngine

class ScrollingBackgroundScene: Scene {

    // MARK: - Instance properties

    var backgrounds = [Actor]()

    lazy var birdThatFlaps: Actor = {
        let actor = Actor(image: #imageLiteral(resourceName: "Flying-1.png"))
        actor.position = center
        actor.scale = 0.5
        actor.animation = Animation(name: "Flying-1", frameCount: 1, frameDuration: 1)

        return actor
    }()

    // MARK: - Setup methods

    override func setup() {
        setupBackground()
        addActors()
        setupGame()
        setupCamera()
    }

    private func addActors() {
        add(birdThatFlaps)
    }

    var hasFallen = false

    private func setupBackground() {
        for i in 0...2 {
            let background = Actor(image: #imageLiteral(resourceName: "background"))
            background.size = UIScreen.main.bounds.size
            background.position = Point(x: CGFloat(i) * background.size.width, y: UIScreen.main.bounds.height / 2)

            backgrounds.append(background)

            add(background)
        }
    }

    private func setupGame() {
        events.clicked.observe {
            for bg in self.backgrounds {
                bg.velocity.dx = -100
            }
        }

        guard let firstBackground = self.backgrounds.first else { return }
        firstBackground.events.moved.observe {
            for bg in self.backgrounds {
                if bg.position.x < -(self.size.width) {
                    bg.position.x += self.size.width * 3
                }
            }
        }
    }

    private func setupCamera() {
        birdThatFlaps.events.moved.observe {
            self.camera.position = self.birdThatFlaps.position
        }
    }

}
