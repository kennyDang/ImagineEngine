import ImagineEngine

final class BirdThatFlapsScene: Scene {

    // MARK: - Instance properties

    lazy var bird: Actor = {
        let actor = Actor(image: #imageLiteral(resourceName: "Flying-1.png"))
        actor.position = center
        actor.scale = 0.1
        actor.size = Size(width: 50, height: 50)

        return actor
    }()

    lazy var scoreCounterLabel: Label = {
        let label = Label(text: "0")
        label.font = UIFont(name: "flappyBirdy", size: 80)!
        label.position = Point(x: center.x, y: center.y - 200)

        return label
    }()

    var backgrounds = [Actor]()
    var hasGameStarted = false
    var isGameInProgress = false
    var timer: Timer?
    var oldPosition: CGFloat = 0
    var scoreCounter = 0

    enum CollisionType: String {
        case Pipe = "Pipe"
        case Coin = "Coin"
    }

    // MARK: - Setup methods

    override func setup() {
        setupBackground()
        addActors()
        setupBird()
        setupGame()
        setupCamera()
    }

    private func setupBackground() {
        for i in 0...2 {
            let background = Actor(image: #imageLiteral(resourceName: "background"))
            background.size = UIScreen.main.bounds.size
            background.position = Point(x: CGFloat(i) * background.size.width, y: UIScreen.main.bounds.height / 2)
            backgrounds.append(background)

            add(background)
        }
    }

    private func addActors() {
        add(bird)
        add(scoreCounterLabel)
    }

    private func setupBird() {
        let flyingAnimation = Animation(images: [#imageLiteral(resourceName: "Flying-1.png"), #imageLiteral(resourceName: "Flying-2.png"), #imageLiteral(resourceName: "Flying-3.png"), #imageLiteral(resourceName: "Flying-4.png")], frameDuration: 0.09)
        _ = bird.playAnimation(flyingAnimation)
    }

    private func setupGame() {
        self.timer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(self.createPipes), userInfo: nil, repeats: true)

        self.hasGameStarted = true
        self.isGameInProgress = true

        for bg in self.backgrounds {
            bg.velocity.dx = -100
        }

        observeBackgrounds()
        observePipeCollisions()
        observeClickCollisions()
        observeBirdMovement()
        observeCoinCollisions()
    }

    private func setupCamera() {
        bird.events.moved.observe {
            self.camera.position = self.bird.position
        }

        camera.constrainedToScene = true
    }

    // MARK: - Observe methods

    private func observeBackgrounds() {
        guard let firstBackground = self.backgrounds.first else { return }

        firstBackground.events.moved.observe {
            for bg in self.backgrounds {
                if bg.position.x < -(self.size.width) {
                    bg.position.x += self.size.width * 3
                }
            }

            if self.isGameInProgress {
                self.bird.velocity.dy = 200
                self.isGameInProgress = false
            }
        }
    }

    private func observePipeCollisions() {
        bird.events.collided(withActorInGroup: Group.name("Pipe")).observe {
            let gameOverLabel = Label(text: "Game Over")
            gameOverLabel.font = UIFont(name: "flappyBirdy", size: 80)!
            gameOverLabel.position = Point(x: self.center.x, y: self.center.y - 100)

            let resetLabel = Label(text: "Tap to play again")
            resetLabel.font = UIFont(name: "flappyBirdy", size: 65)!
            resetLabel.position = Point(x: self.center.x, y: self.center.y - 50)

            self.add(gameOverLabel)
            self.add(resetLabel)

            self.isPaused = true
        }
    }

    private func observeCoinCollisions() {
        bird.events.collided(withActorInGroup: Group.name("Coin")).observe { (actor, coin) in
            coin.remove()
            self.scoreCounter += 1
            self.scoreCounterLabel.text = "\(self.scoreCounter)"
        }
    }

    private func observeClickCollisions() {
        events.clicked.observe {
            if self.isPaused {
                self.resetGame()
            }

            self.fly()
        }
    }

    private func observeBirdMovement() {
        bird.events.moved.observe {
            if self.oldPosition > self.bird.position.y {
                self.bird.rotation = 6
            } else {
                self.bird.rotation = -6
            }
        }
    }

    // MARK: - Helper methods

    @objc private func createPipes() {
        let randX = randomX()
        let randomOffset = random(min: -200, max: 200)
        guard let pipeType = CollisionType(rawValue: "Pipe") else { return }
        guard let coinType = CollisionType(rawValue: "Coin") else { return }
        let pipeGroup = Group.enumValue(pipeType)
        let coinGroup = Group.enumValue(coinType)

        let topPipe = Actor(image: #imageLiteral(resourceName: "Pipe"))
        topPipe.size = Size(width: 20, height: 100)
        topPipe.position = Point(x: randX, y: 0)
        topPipe.velocity.dx = -130
        topPipe.scale = 0.5
        topPipe.position.y += randomOffset
        topPipe.group = pipeGroup

        let bottomPipe = Actor(image: #imageLiteral(resourceName: "Pipe"))
        bottomPipe.size = Size(width: 20, height: 100)
        bottomPipe.position = Point(x: randX, y: UIScreen.main.bounds.height)
        bottomPipe.velocity.dx = -130
        bottomPipe.scale = 0.5
        bottomPipe.rotation = -.pi
        bottomPipe.position.y += randomOffset
        bottomPipe.group = pipeGroup

        let coin = Actor(image: #imageLiteral(resourceName: "Coin"))
        coin.size = Size(width: 100, height: 100)
        coin.position = Point(x: bottomPipe.position.x, y: topPipe.rect.maxY + 280)
        coin.scale = 2
        coin.velocity.dx = -130

        coin.group = coinGroup

        add(topPipe)
        add(bottomPipe)
        add(coin)

        timeline.after(interval: 5) {
            topPipe.remove()
            bottomPipe.remove()
            coin.remove()
        }
    }

    private func randomX() -> CGFloat {
        let screenWidth = UInt32(UIScreen.main.bounds.width)
        let randomX = CGFloat(arc4random_uniform(500 - screenWidth) + screenWidth)

        return randomX
     }

    private func random() -> CGFloat{
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }

    private func random(min: CGFloat, max: CGFloat) -> CGFloat{
        return random() * (max - min) + min
    }

    private func fly() {
        bird.move(byX: 0, y: -150, duration: 0.2)
        oldPosition = bird.position.y
    }

    private func resetGame() {
        isPaused = false
        isGameInProgress = false
        hasGameStarted = false
        timer?.invalidate()
        oldPosition = 0
        bird.velocity.dy = 0
        bird.position = center
        backgrounds.removeAll()
        scoreCounterLabel.text = "0"
        scoreCounter = 0
        reset()
    }

}
