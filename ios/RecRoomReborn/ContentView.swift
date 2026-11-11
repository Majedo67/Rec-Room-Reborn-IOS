import SwiftUI
import SceneKit

struct ContentView: View {
    @StateObject private var game = ArenaGameController()

    var body: some View {
        ZStack {
            Color(red: 0.025, green: 0.035, blue: 0.10).ignoresSafeArea()

            ArenaSceneView(controller: game)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("REC ROOM").font(.system(size: 12, weight: .black, design: .rounded)).tracking(3).foregroundStyle(Color.cyan)
                        Text("REBORN ARENA").font(.system(size: 23, weight: .black, design: .rounded)).foregroundStyle(.white)
                    }
                    Spacer()
                    Text("LOCAL PLAY")
                        .font(.system(size: 10, weight: .heavy, design: .rounded))
                        .tracking(1)
                        .padding(.horizontal, 11).padding(.vertical, 8)
                        .background(.green.opacity(0.18), in: Capsule())
                        .foregroundStyle(.green)
                }
                .padding(.horizontal, 20).padding(.top, 12)

                Text(game.message)
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 14).padding(.vertical, 9)
                    .background(.black.opacity(0.48), in: Capsule())
                    .padding(.top, 12)

                Spacer()

                HStack(alignment: .bottom) {
                    Joystick { x, z in game.setMovement(x: x, z: z) }

                    Spacer()

                    VStack(spacing: 14) {
                        ControlButton(title: "JUMP", symbol: "arrow.up", color: .cyan) {
                            game.jump()
                        }
                        ControlButton(title: "INTERACT", symbol: "hand.tap", color: .orange) {
                            game.interact()
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 30)
            }
        }
        .preferredColorScheme(.dark)
    }
}

private struct Joystick: View {
    let onMove: (Double, Double) -> Void
    @State private var offset: CGSize = .zero
    private let radius: CGFloat = 54

    var body: some View {
        ZStack {
            Circle().fill(.black.opacity(0.42)).overlay(Circle().stroke(.white.opacity(0.35), lineWidth: 2))
                .frame(width: 124, height: 124)
            Circle().fill(Color.cyan.opacity(0.85)).overlay(Circle().stroke(.white.opacity(0.8), lineWidth: 2))
                .frame(width: 54, height: 54)
                .offset(offset)
        }
        .frame(width: 124, height: 124)
        .contentShape(Circle())
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { value in
                    let dx = value.translation.width
                    let dy = value.translation.height
                    let length = max(1, sqrt(dx * dx + dy * dy))
                    let scale = min(radius, length) / length
                    offset = CGSize(width: dx * scale, height: dy * scale)
                    onMove(Double(offset.width / radius), Double(offset.height / radius))
                }
                .onEnded { _ in
                    withAnimation(.easeOut(duration: 0.12)) { offset = .zero }
                    onMove(0, 0)
                }
        )
        .accessibilityLabel("Movement joystick")
    }
}

private struct ControlButton: View {
    let title: String
    let symbol: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 5) {
                Image(systemName: symbol).font(.system(size: 22, weight: .bold))
                Text(title).font(.system(size: 10, weight: .black, design: .rounded)).tracking(1)
            }
            .foregroundStyle(.white)
            .frame(width: 82, height: 72)
            .background(color.opacity(0.78), in: RoundedRectangle(cornerRadius: 22))
            .overlay(RoundedRectangle(cornerRadius: 22).stroke(.white.opacity(0.65), lineWidth: 1.5))
        }
        .buttonStyle(.plain)
    }
}

private struct ArenaSceneView: UIViewRepresentable {
    @ObservedObject var controller: ArenaGameController

    func makeUIView(context: Context) -> SCNView {
        let view = SCNView()
        view.scene = controller.scene
        view.delegate = controller
        view.backgroundColor = UIColor(red: 0.04, green: 0.07, blue: 0.16, alpha: 1)
        view.isPlaying = true
        view.antialiasingMode = .multisampling4X
        view.pointOfView = controller.cameraNode
        return view
    }

    func updateUIView(_ uiView: SCNView, context: Context) {
        uiView.scene = controller.scene
    }
}

@MainActor
final class ArenaGameController: NSObject, ObservableObject, SCNSceneRendererDelegate {
    let scene = SCNScene()
    let cameraNode = SCNNode()
    @Published var message = "Explore the arena • Find the glowing orb"

    private let player = SCNNode()
    private let orb = SCNNode()
    private var moveX: Double = 0
    private var moveZ: Double = 0
    private var verticalSpeed: Float = 0
    private var lastTime: TimeInterval = 0
    private var grounded = true

    override init() {
        super.init()
        buildArena()
    }

    private func buildArena() {
        scene.background.contents = UIColor(red: 0.04, green: 0.07, blue: 0.16, alpha: 1)

        let camera = SCNCamera()
        camera.fieldOfView = 62
        cameraNode.camera = camera
        cameraNode.position = SCNVector3(0, 6, 9)
        scene.rootNode.addChildNode(cameraNode)

        let floor = SCNFloor()
        floor.reflectivity = 0
        floor.firstMaterial?.diffuse.contents = UIColor(red: 0.12, green: 0.16, blue: 0.27, alpha: 1)
        let floorNode = SCNNode(geometry: floor)
        floorNode.position.y = -0.08
        scene.rootNode.addChildNode(floorNode)

        addBox(width: 24, height: 0.35, length: 0.5, at: SCNVector3(0, 0.15, -12), color: .systemBlue)
        addBox(width: 24, height: 0.35, length: 0.5, at: SCNVector3(0, 0.15, 12), color: .systemBlue)
        addBox(width: 0.5, height: 0.35, length: 24, at: SCNVector3(-12, 0.15, 0), color: .systemBlue)
        addBox(width: 0.5, height: 0.35, length: 24, at: SCNVector3(12, 0.15, 0), color: .systemBlue)

        addBox(width: 2, height: 1.2, length: 2, at: SCNVector3(-4, 0.6, -4), color: .systemPurple)
        addBox(width: 2, height: 0.8, length: 2, at: SCNVector3(4, 0.4, -2), color: .systemTeal)
        addBox(width: 1.5, height: 1.5, length: 1.5, at: SCNVector3(4, 0.75, 5), color: .systemIndigo)

        let body = SCNCapsule(capRadius: 0.34, height: 1.55)
        body.firstMaterial?.diffuse.contents = UIColor.systemCyan
        body.firstMaterial?.emission.contents = UIColor(red: 0.02, green: 0.18, blue: 0.28, alpha: 1)
        player.geometry = body
        player.position = SCNVector3(0, 0.78, 4)
        scene.rootNode.addChildNode(player)

        let orbGeometry = SCNSphere(radius: 0.48)
        orbGeometry.firstMaterial?.diffuse.contents = UIColor.systemYellow
        orbGeometry.firstMaterial?.emission.contents = UIColor.systemOrange
        orb.geometry = orbGeometry
        orb.position = SCNVector3(0, 0.7, -6)
        scene.rootNode.addChildNode(orb)

        let ambient = SCNNode()
        ambient.light = SCNLight()
        ambient.light?.type = .ambient
        ambient.light?.intensity = 650
        scene.rootNode.addChildNode(ambient)

        let sun = SCNNode()
        sun.light = SCNLight()
        sun.light?.type = .omni
        sun.light?.intensity = 900
        sun.position = SCNVector3(0, 10, 5)
        scene.rootNode.addChildNode(sun)
    }

    private func addBox(width: CGFloat, height: CGFloat, length: CGFloat, at position: SCNVector3, color: UIColor) {
        let geometry = SCNBox(width: width, height: height, length: length, chamferRadius: 0.12)
        geometry.firstMaterial?.diffuse.contents = color
        let node = SCNNode(geometry: geometry)
        node.position = position
        scene.rootNode.addChildNode(node)
    }

    func setMovement(x: Double, z: Double) {
        moveX = x
        moveZ = z
    }

    func jump() {
        guard grounded else { return }
        verticalSpeed = 6.5
        grounded = false
    }

    func interact() {
        let dx = player.position.x - orb.position.x
        let dz = player.position.z - orb.position.z
        if sqrt(dx * dx + dz * dz) < 2.2 {
            orb.removeFromParentNode()
            message = "Orb collected! Nice work!"
        } else {
            message = "Move closer to the glowing orb to collect it."
        }
    }

    nonisolated func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        Task { @MainActor [weak self] in
            guard let self else { return }
            let delta = Float(min(max(time - (self.lastTime == 0 ? time : self.lastTime), 0), 0.05))
            self.lastTime = time

            let speed: Float = 4.2
            self.player.position.x += Float(self.moveX) * speed * delta
            self.player.position.z += Float(self.moveZ) * speed * delta
            self.player.position.x = min(10.8, max(-10.8, self.player.position.x))
            self.player.position.z = min(10.8, max(-10.8, self.player.position.z))

            if !self.grounded {
                self.verticalSpeed -= 16 * delta
                self.player.position.y += self.verticalSpeed * delta
                if self.player.position.y <= 0.78 {
                    self.player.position.y = 0.78
                    self.verticalSpeed = 0
                    self.grounded = true
                }
            }

            let p = self.player.position
            self.cameraNode.position = SCNVector3(p.x, p.y + 5.2, p.z + 8.0)
            self.cameraNode.look(at: SCNVector3(p.x, p.y + 0.7, p.z - 2.0))
        }
    }
}
