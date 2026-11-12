import SwiftUI
import SceneKit

private enum GamePage: String, CaseIterable {
    case home = "Home"
    case rooms = "Rooms"
    case avatar = "Avatar"
    case create = "Create"
    case play = "Play"
    case social = "Social"
}

struct ContentView: View {
    @StateObject private var game = ArenaGameController()
    @State private var page: GamePage = .home
    @State private var selectedRoom = "Rec Center"
    @State private var avatarColor = "Cyan"
    @State private var roomName = "My Room"
    @State private var roomDescription = "A room made by me"
    @State private var placedObjects: [String] = []

    private let colors: [(String, Color)] = [
        ("Cyan", .cyan), ("Purple", .purple), ("Green", .green),
        ("Orange", .orange), ("Pink", .pink), ("Blue", .blue)
    ]
    private let rooms = [
        ("Rec Center", "Social hub • Local preview", "person.3.fill", "A bright place to meet and explore."),
        ("Paintball Arena", "Team game • Local preview", "target", "A colorful arena for friendly matches."),
        ("Parkour Course", "Obstacle course • Local preview", "figure.run", "Jump across platforms and reach the finish."),
        ("Dorm Room", "Hangout • Local preview", "house.fill", "A cozy room to decorate.")
    ]

    var body: some View {
        ZStack {
            Color(red: 0.035, green: 0.045, blue: 0.11).ignoresSafeArea()
            Group {
                switch page {
                case .home: homePage
                case .rooms: roomsPage
                case .avatar: avatarPage
                case .create: createPage
                case .play: playPage
                case .social: socialPage
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 3) {
                Text("REC ROOM").font(.system(size: 13, weight: .black, design: .rounded)).tracking(4).foregroundStyle(.cyan)
                Text("REBORN").font(.system(size: 29, weight: .black, design: .rounded)).foregroundStyle(.white)
            }
            Spacer()
            Text("OFFLINE BUILD").font(.system(size: 10, weight: .heavy, design: .rounded)).tracking(1)
                .padding(.horizontal, 12).padding(.vertical, 9)
                .background(.orange.opacity(0.18), in: Capsule()).foregroundStyle(.orange)
        }
    }

    private var homePage: some View {
        VStack(alignment: .leading, spacing: 20) {
            header.padding(.top, 12)
            Text("WELCOME BACK, PLAYER")
                .font(.system(size: 17, weight: .semibold, design: .rounded)).foregroundStyle(.white.opacity(0.8))
            Button { page = .play } label: {
                ZStack(alignment: .bottomLeading) {
                    RoundedRectangle(cornerRadius: 26).fill(LinearGradient(colors: [.blue, .purple, .cyan], startPoint: .topLeading, endPoint: .bottomTrailing))
                    VStack(alignment: .leading, spacing: 8) {
                        Image(systemName: "gamecontroller.fill").font(.system(size: 34))
                        Text("PLAY").font(.system(size: 25, weight: .black, design: .rounded))
                        Text("@Player  •  " + selectedRoom).font(.system(size: 13, weight: .semibold))
                    }.foregroundStyle(.white).padding(22)
                }.frame(height: 170)
            }.buttonStyle(.plain)
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                homeTile("Explore Rooms", "square.grid.2x2.fill", .cyan) { page = .rooms }
                homeTile("Customize Avatar", "person.crop.circle.fill", .purple) { page = .avatar }
                homeTile("Create a Room", "hammer.fill", .orange) { page = .create }
                homeTile("Social Lobby", "person.3.fill", .green) { page = .social }
            }
            Spacer()
            Text("A colorful social game world • Offline prototype")
                .font(.system(size: 11, weight: .medium)).foregroundStyle(.white.opacity(0.5))
        }.padding(20)
    }

    private func homeTile(_ title: String, _ symbol: String, _ tint: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
                Image(systemName: symbol).font(.system(size: 25, weight: .bold)).foregroundStyle(tint)
                Text(title).font(.system(size: 15, weight: .bold, design: .rounded)).foregroundStyle(.white)
            }.frame(maxWidth: .infinity, minHeight: 92, alignment: .leading).padding(16)
                .background(.white.opacity(0.07), in: RoundedRectangle(cornerRadius: 18))
                .overlay(RoundedRectangle(cornerRadius: 18).stroke(.white.opacity(0.08)))
        }.buttonStyle(.plain)
    }

    private var roomsPage: some View {
        VStack(alignment: .leading, spacing: 16) {
            pageHeader("Explore Rooms", subtitle: "Choose a place to visit")
            ForEach(rooms, id: \.0) { room in
                Button { selectedRoom = room.0; game.selectRoom(room.0) } label: {
                    HStack(spacing: 14) {
                        Image(systemName: room.2).font(.system(size: 25, weight: .bold)).foregroundStyle(.cyan)
                            .frame(width: 54, height: 54).background(.cyan.opacity(0.12), in: RoundedRectangle(cornerRadius: 14))
                        VStack(alignment: .leading, spacing: 4) {
                            Text(room.0).font(.system(size: 16, weight: .bold)).foregroundStyle(.white)
                            Text(room.1).font(.system(size: 11, weight: .semibold)).foregroundStyle(.cyan)
                            Text(room.3).font(.system(size: 12)).foregroundStyle(.white.opacity(0.65))
                        }
                        Spacer()
                        Image(systemName: selectedRoom == room.0 ? "checkmark.circle.fill" : "circle")
                            .foregroundStyle(selectedRoom == room.0 ? .green : .white.opacity(0.3))
                    }.padding(14).background(.white.opacity(0.07), in: RoundedRectangle(cornerRadius: 18))
                }.buttonStyle(.plain)
            }
            Button { page = .play } label: { primaryButton("ENTER \(selectedRoom.uppercased())", color: .cyan) }
            Spacer()
        }.padding(20)
    }

    private var avatarPage: some View {
        VStack(alignment: .leading, spacing: 20) {
            pageHeader("Avatar Studio", subtitle: "Choose your prototype avatar color")
            ZStack {
                RoundedRectangle(cornerRadius: 28).fill(.white.opacity(0.06))
                VStack(spacing: 12) {
                    Image(systemName: "person.fill").font(.system(size: 100, weight: .regular)).foregroundStyle(colorForAvatar)
                    Text("PLAYER").font(.system(size: 13, weight: .black, design: .rounded)).tracking(3).foregroundStyle(.white)
                    Text("Starter avatar preview").font(.system(size: 12)).foregroundStyle(.white.opacity(0.6))
                }
            }.frame(height: 270)
            Text("AVATAR COLOR").font(.system(size: 12, weight: .black)).tracking(2).foregroundStyle(.white.opacity(0.7))
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 12) {
                ForEach(colors, id: \.0) { item in
                    Button { avatarColor = item.0 } label: {
                        HStack { Circle().fill(item.1).frame(width: 20, height: 20); Text(item.0).font(.system(size: 13, weight: .bold)); Spacer(); if avatarColor == item.0 { Image(systemName: "checkmark") } }
                            .foregroundStyle(.white).padding(12).background(.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 12))
                    }.buttonStyle(.plain)
                }
            }
            Text("This is a color preview for now. Full character models, outfits, and accessories are still being developed.")
                .font(.system(size: 11)).foregroundStyle(.white.opacity(0.5))
            Spacer()
        }.padding(20)
    }

    private var colorForAvatar: Color { colors.first(where: { $0.0 == avatarColor })?.1 ?? .cyan }

    private var createPage: some View {
        VStack(alignment: .leading, spacing: 16) {
            pageHeader("Room Creator", subtitle: "Make a simple local room plan")
            Text("ROOM NAME").font(.system(size: 11, weight: .black)).tracking(2).foregroundStyle(.white.opacity(0.7))
            TextField("My Room", text: $roomName).textFieldStyle(.roundedBorder)
            Text("DESCRIPTION").font(.system(size: 11, weight: .black)).tracking(2).foregroundStyle(.white.opacity(0.7))
            TextField("Describe your room", text: $roomDescription).textFieldStyle(.roundedBorder)
            Text("ADD OBJECTS").font(.system(size: 11, weight: .black)).tracking(2).foregroundStyle(.white.opacity(0.7))
            ForEach(["Cube", "Platform", "Sphere", "Light"], id: \.self) { item in
                Button { placedObjects.append(item) } label: {
                    HStack { Image(systemName: "plus.circle.fill").foregroundStyle(.cyan); Text(item).foregroundStyle(.white); Spacer(); Text("ADD").font(.system(size: 10, weight: .black)).foregroundStyle(.cyan) }
                        .padding(14).background(.white.opacity(0.07), in: RoundedRectangle(cornerRadius: 13))
                }.buttonStyle(.plain)
            }
            Text("Room draft: \(roomName.isEmpty ? "Untitled" : roomName) • \(placedObjects.count) objects")
                .font(.system(size: 13, weight: .bold)).foregroundStyle(.green)
            if !placedObjects.isEmpty {
                Text(placedObjects.joined(separator: "  •  ")).font(.system(size: 11)).foregroundStyle(.white.opacity(0.6))
                Button("Clear draft") { placedObjects.removeAll() }.foregroundStyle(.orange)
            }
            Text("This saves a temporary in-app draft only. Publishing rooms and a full Maker Pen editor still need to be built.")
                .font(.system(size: 11)).foregroundStyle(.white.opacity(0.5))
            Spacer()
        }.padding(20)
    }

    private var socialPage: some View {
        VStack(alignment: .leading, spacing: 18) {
            pageHeader("Social Lobby", subtitle: "Friends and multiplayer")
            Image(systemName: "person.3.fill").font(.system(size: 58)).foregroundStyle(.cyan).frame(maxWidth: .infinity).padding(.top, 34)
            Text("ONLINE SERVICES NOT CONNECTED").font(.system(size: 15, weight: .black, design: .rounded)).foregroundStyle(.orange).frame(maxWidth: .infinity)
            Text("This version has no account system, friends list, chat, matchmaking, or live multiplayer server. The lobby screen is a placeholder until a backend is added.")
                .font(.system(size: 14)).foregroundStyle(.white.opacity(0.75)).multilineTextAlignment(.center)
            Spacer()
        }.padding(20)
    }

    private var playPage: some View {
        ZStack {
            ArenaSceneView(controller: game).ignoresSafeArea()
            VStack {
                HStack {
                    Button { page = .home } label: { Image(systemName: "chevron.left").font(.system(size: 17, weight: .black)).padding(12).background(.black.opacity(0.5), in: Circle()) }
                    VStack(alignment: .leading, spacing: 2) {
                        Text(selectedRoom.uppercased()).font(.system(size: 17, weight: .black, design: .rounded))
                        Text("LOCAL PLAY • \(avatarColor.uppercased()) AVATAR").font(.system(size: 9, weight: .heavy)).tracking(1).foregroundStyle(.cyan)
                    }
                    Spacer()
                    Text("BETA").font(.system(size: 10, weight: .black)).padding(9).background(.orange.opacity(0.2), in: Capsule()).foregroundStyle(.orange)
                }.padding(.horizontal, 18).padding(.top, 12)
                Text(game.message).font(.system(size: 12, weight: .semibold)).padding(10).background(.black.opacity(0.5), in: Capsule())
                Spacer()
                HStack(alignment: .bottom) {
                    Joystick { x, z in game.setMovement(x: x, z: z) }
                    Spacer()
                    VStack(spacing: 12) {
                        ControlButton(title: "JUMP", symbol: "arrow.up", color: .cyan) { game.jump() }
                        ControlButton(title: "INTERACT", symbol: "hand.tap", color: .orange) { game.interact() }
                    }
                }.padding(.horizontal, 24).padding(.bottom, 28)
            }.foregroundStyle(.white)
        }
    }

    private func pageHeader(_ title: String, subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack {
                Button { page = .home } label: { Image(systemName: "chevron.left").font(.system(size: 16, weight: .black)).padding(10).background(.white.opacity(0.1), in: Circle()) }
                Text(title).font(.system(size: 24, weight: .black, design: .rounded))
            }
            Text(subtitle).font(.system(size: 13, weight: .medium)).foregroundStyle(.white.opacity(0.6))
        }.padding(.top, 10)
    }

    private func primaryButton(_ title: String, color: Color) -> some View {
        Text(title).font(.system(size: 13, weight: .black, design: .rounded)).tracking(1)
            .foregroundStyle(.black).frame(maxWidth: .infinity).padding(16)
            .background(color, in: RoundedRectangle(cornerRadius: 15))
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

    func selectRoom(_ room: String) {
        scene.rootNode.childNodes.forEach { $0.removeFromParentNode() }
        lastTime = 0
        grounded = true
        verticalSpeed = 0
        player.position = SCNVector3(0, 0.78, 4)
        message = "Welcome to \(room) • Explore!"
        buildArena(room: room)
    }

    private func buildArena(room: String = "Rec Center") {
        let isDorm = room == "Dorm Room"
        let isParkour = room == "Parkour Course"
        let wood = UIColor(red: 0.58, green: 0.34, blue: 0.17, alpha: 1)
        let cream = UIColor(red: 0.91, green: 0.86, blue: 0.72, alpha: 1)
        let orange = UIColor(red: 0.96, green: 0.39, blue: 0.12, alpha: 1)
        scene.background.contents = UIColor(red: 0.55, green: 0.72, blue: 0.82, alpha: 1)

        let camera = SCNCamera()
        camera.fieldOfView = 66
        cameraNode.camera = camera
        cameraNode.position = SCNVector3(0, 5.8, 9)
        scene.rootNode.addChildNode(cameraNode)

        let floor = SCNFloor()
        floor.reflectivity = 0
        floor.firstMaterial?.diffuse.contents = wood
        let floorNode = SCNNode(geometry: floor)
        floorNode.position.y = -0.08
        scene.rootNode.addChildNode(floorNode)

        // Warm room walls, orange trim and ceiling beams.
        addBox(width: 24, height: 7, length: 0.35, at: SCNVector3(0, 3.5, -12), color: cream)
        addBox(width: 0.35, height: 7, length: 24, at: SCNVector3(-12, 3.5, 0), color: cream)
        addBox(width: 0.35, height: 7, length: 24, at: SCNVector3(12, 3.5, 0), color: cream)
        addBox(width: 24, height: 0.22, length: 0.42, at: SCNVector3(0, 2.1, -11.75), color: orange)
        addBox(width: 24, height: 0.22, length: 0.42, at: SCNVector3(0, 2.1, 11.75), color: orange)
        addBox(width: 24, height: 0.25, length: 0.25, at: SCNVector3(0, 6.9, -12), color: wood)
        addBox(width: 0.25, height: 0.25, length: 24, at: SCNVector3(-12, 6.9, 0), color: wood)
        addBox(width: 0.25, height: 0.25, length: 24, at: SCNVector3(12, 6.9, 0), color: wood)

        // Large blue-tinted windows and timber frames.
        for x in [-8.0, -3.0, 3.0, 8.0] {
            addBox(width: 3.2, height: 2.4, length: 0.12, at: SCNVector3(Float(x), 4.5, -11.78), color: UIColor(red: 0.28, green: 0.68, blue: 0.83, alpha: 1))
            addBox(width: 0.10, height: 2.7, length: 0.18, at: SCNVector3(Float(x - 1.65), 4.5, -11.65), color: wood)
            addBox(width: 0.10, height: 2.7, length: 0.18, at: SCNVector3(Float(x + 1.65), 4.5, -11.65), color: wood)
            addBox(width: 3.4, height: 0.10, length: 0.18, at: SCNVector3(Float(x), 3.15, -11.65), color: wood)
            addBox(width: 3.4, height: 0.10, length: 0.18, at: SCNVector3(Float(x), 5.85, -11.65), color: wood)
        }

        // Ceiling grid.
        for x in stride(from: -10.0, through: 10.0, by: 2.0) {
            addBox(width: 0.12, height: 0.12, length: 7, at: SCNVector3(x, 6.7, -5), color: wood)
        }
        for z in stride(from: -8.0, through: -2.0, by: 2.0) {
            addBox(width: 20, height: 0.12, length: 0.12, at: SCNVector3(0, 6.7, z), color: wood)
        }

        if isDorm {
            // Dorm bed, mattress, bedside table and wall poster.
            addBox(width: 3.4, height: 0.45, length: 6.0, at: SCNVector3(7.2, 1.25, -5.5), color: wood)
            addBox(width: 3.2, height: 0.35, length: 5.8, at: SCNVector3(7.2, 1.65, -5.5), color: UIColor(red: 0.28, green: 0.48, blue: 0.76, alpha: 1))
            addBox(width: 3.5, height: 0.25, length: 0.25, at: SCNVector3(7.2, 2.3, -8.5), color: wood)
            addBox(width: 1.8, height: 1.4, length: 0.12, at: SCNVector3(-5, 4.0, -11.7), color: orange)
            addBox(width: 2.0, height: 0.9, length: 1.5, at: SCNVector3(-7, 0.45, -5), color: wood)
            addBox(width: 2.0, height: 0.18, length: 1.5, at: SCNVector3(-7, 0.98, -5), color: cream)
        } else if isParkour {
            for i in 0..<6 {
                let x = Float(-7 + i * 2)
                let z = Float(-5 - (i % 2) * 3)
                addBox(width: 2.0, height: 0.45, length: 2.0, at: SCNVector3(x, Float(0.45 + (i % 3) * 0.35), z), color: i.isMultiple(of: 2) ? .systemTeal : .systemPurple)
            }
        } else {
            // Rec Center welcome desk and colorful activity portals.
            addBox(width: 5.0, height: 1.3, length: 1.2, at: SCNVector3(0, 0.75, -8.5), color: UIColor(red: 0.08, green: 0.35, blue: 0.62, alpha: 1))
            addBox(width: 5.2, height: 0.16, length: 1.35, at: SCNVector3(0, 1.48, -8.5), color: orange)
            addBox(width: 3.0, height: 2.5, length: 0.2, at: SCNVector3(-7.5, 2.2, -11.65), color: .systemBlue)
            addBox(width: 3.0, height: 2.5, length: 0.2, at: SCNVector3(7.5, 2.2, -11.65), color: .systemGreen)
            addBox(width: 3.2, height: 1.5, length: 0.2, at: SCNVector3(0, 4.0, -11.55), color: orange)
        }

        if !isParkour {
            addBox(width: 2.2, height: 0.9, length: 1.8, at: SCNVector3(-5, 0.45, -3), color: .systemBrown)
            addBox(width: 2.2, height: 0.9, length: 1.8, at: SCNVector3(5, 0.45, 1), color: .systemBrown)
        }

        let body = SCNCapsule(capRadius: 0.34, height: 1.55)
        body.firstMaterial?.diffuse.contents = UIColor.systemCyan
        body.firstMaterial?.emission.contents = UIColor(red: 0.02, green: 0.18, blue: 0.28, alpha: 1)
        player.geometry = body
        player.position = SCNVector3(0, 0.78, 4)
        scene.rootNode.addChildNode(player)

        let orbGeometry = SCNSphere(radius: 0.38)
        orbGeometry.firstMaterial?.diffuse.contents = UIColor.systemYellow
        orbGeometry.firstMaterial?.emission.contents = UIColor.systemOrange
        orb.geometry = orbGeometry
        orb.position = SCNVector3(0, 0.7, -6)
        scene.rootNode.addChildNode(orb)

        let ambient = SCNNode()
        ambient.light = SCNLight()
        ambient.light?.type = .ambient
        ambient.light?.intensity = 700
        scene.rootNode.addChildNode(ambient)

        let sun = SCNNode()
        sun.light = SCNLight()
        sun.light?.type = .omni
        sun.light?.intensity = 1100
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
