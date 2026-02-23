import SpriteKit

/// Renders a stick figure using SKShapeNode joint tree.
/// The root node is positioned at the fighter's feet.
final class StickFigureRenderer {
    let rootNode: SKNode
    var color: SKColor {
        didSet { updateColors() }
    }

    // Joint nodes
    private let bodyNode = SKNode()    // offset for crouch/jump
    private let torso = SKShapeNode()
    private let head = SKShapeNode(circleOfRadius: K.Body.headRadius)

    // Arms
    private let leftUpperArm = SKShapeNode()
    private let leftLowerArm = SKShapeNode()
    private let rightUpperArm = SKShapeNode()
    private let rightLowerArm = SKShapeNode()

    // Legs
    private let leftUpperLeg = SKShapeNode()
    private let leftLowerLeg = SKShapeNode()
    private let rightUpperLeg = SKShapeNode()
    private let rightLowerLeg = SKShapeNode()

    // Hurtbox (invisible, for collision)
    let hurtboxNode: SKNode

    init(color: SKColor) {
        self.color = color
        self.rootNode = SKNode()
        self.hurtboxNode = SKNode()

        setupSkeleton()
        updateColors()
    }

    private func setupSkeleton() {
        rootNode.addChild(bodyNode)

        // Torso line
        let torsoPath = CGMutablePath()
        torsoPath.move(to: .zero)
        torsoPath.addLine(to: CGPoint(x: 0, y: K.Body.torsoLength))
        torso.path = torsoPath
        torso.position = CGPoint(x: 0, y: K.Body.upperLegLength + K.Body.lowerLegLength)
        bodyNode.addChild(torso)

        // Head on top of torso
        head.position = CGPoint(x: 0, y: K.Body.torsoLength + K.Body.headRadius)
        torso.addChild(head)

        // Shoulders at top of torso
        let shoulderPos = CGPoint(x: 0, y: K.Body.torsoLength)

        setupLimb(upper: leftUpperArm, lower: leftLowerArm,
                  upperLen: K.Body.upperArmLength, lowerLen: K.Body.lowerArmLength,
                  parent: torso, position: shoulderPos)

        setupLimb(upper: rightUpperArm, lower: rightLowerArm,
                  upperLen: K.Body.upperArmLength, lowerLen: K.Body.lowerArmLength,
                  parent: torso, position: shoulderPos)

        // Hips at bottom of torso (which is position of torso node)
        let hipPos = CGPoint.zero

        setupLimb(upper: leftUpperLeg, lower: leftLowerLeg,
                  upperLen: K.Body.upperLegLength, lowerLen: K.Body.lowerLegLength,
                  parent: torso, position: hipPos)

        setupLimb(upper: rightUpperLeg, lower: rightLowerLeg,
                  upperLen: K.Body.upperLegLength, lowerLen: K.Body.lowerLegLength,
                  parent: torso, position: hipPos)

        // Hurtbox
        let hurtboxShape = SKShapeNode(rectOf: CGSize(width: 40, height: 100))
        hurtboxShape.fillColor = .clear
        hurtboxShape.strokeColor = .clear
        hurtboxShape.position = CGPoint(x: 0, y: 60)
        hurtboxNode.addChild(hurtboxShape)

        let hurtboxBody = SKPhysicsBody(rectangleOf: CGSize(width: 40, height: 100),
                                         center: CGPoint(x: 0, y: 60))
        hurtboxBody.isDynamic = false
        hurtboxBody.categoryBitMask = K.Category.hurtbox
        hurtboxBody.contactTestBitMask = K.Category.hitbox
        hurtboxBody.collisionBitMask = 0
        hurtboxNode.physicsBody = hurtboxBody

        bodyNode.addChild(hurtboxNode)
    }

    private func setupLimb(upper: SKShapeNode, lower: SKShapeNode,
                           upperLen: CGFloat, lowerLen: CGFloat,
                           parent: SKNode, position: CGPoint) {
        let upperPath = CGMutablePath()
        upperPath.move(to: .zero)
        upperPath.addLine(to: CGPoint(x: 0, y: -upperLen))
        upper.path = upperPath
        upper.position = position
        parent.addChild(upper)

        let lowerPath = CGMutablePath()
        lowerPath.move(to: .zero)
        lowerPath.addLine(to: CGPoint(x: 0, y: -lowerLen))
        lower.path = lowerPath
        lower.position = CGPoint(x: 0, y: -upperLen)
        upper.addChild(lower)
    }

    private func updateColors() {
        let allShapes: [SKShapeNode] = [
            torso, head,
            leftUpperArm, leftLowerArm, rightUpperArm, rightLowerArm,
            leftUpperLeg, leftLowerLeg, rightUpperLeg, rightLowerLeg
        ]
        for shape in allShapes {
            shape.strokeColor = color
            shape.lineWidth = K.Body.lineWidth
            shape.lineCap = .round
        }
        head.fillColor = .clear
        head.lineWidth = K.Body.lineWidth
    }

    /// Apply a pose to the joint tree.
    func applyPose(_ pose: PoseData) {
        bodyNode.position.y = pose.bodyOffsetY
        torso.zRotation = pose.torsoLean

        leftUpperArm.zRotation = pose.leftShoulderAngle
        leftLowerArm.zRotation = pose.leftElbowAngle
        rightUpperArm.zRotation = pose.rightShoulderAngle
        rightLowerArm.zRotation = pose.rightElbowAngle

        leftUpperLeg.zRotation = pose.leftHipAngle
        leftLowerLeg.zRotation = pose.leftKneeAngle
        rightUpperLeg.zRotation = pose.rightHipAngle
        rightLowerLeg.zRotation = pose.rightKneeAngle

        head.zRotation = pose.headTilt
    }

    /// Flash white on hit.
    func flashHit() {
        let allShapes: [SKShapeNode] = [
            torso, head,
            leftUpperArm, leftLowerArm, rightUpperArm, rightLowerArm,
            leftUpperLeg, leftLowerLeg, rightUpperLeg, rightLowerLeg
        ]
        for shape in allShapes {
            shape.strokeColor = .white
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) { [weak self] in
            self?.updateColors()
        }
    }

    /// Get the world-space position of the fist (end of right lower arm).
    func fistWorldPosition() -> CGPoint {
        rightLowerArm.convert(CGPoint(x: 0, y: -K.Body.lowerArmLength), to: rootNode.scene ?? rootNode)
    }

    /// Get the world-space position of the foot (end of right lower leg).
    func footWorldPosition() -> CGPoint {
        rightLowerLeg.convert(CGPoint(x: 0, y: -K.Body.lowerLegLength), to: rootNode.scene ?? rootNode)
    }
}
