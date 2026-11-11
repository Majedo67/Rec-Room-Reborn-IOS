import SwiftUI

struct ContentView: View {
    @StateObject private var status = ServerStatus()
    private let accent = Color(red: 0.25, green: 0.68, blue: 1.0)

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [Color(red: 0.035, green: 0.055, blue: 0.13), Color(red: 0.10, green: 0.07, blue: 0.22)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 22) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("REC ROOM")
                                .font(.system(size: 13, weight: .heavy, design: .rounded))
                                .tracking(4)
                                .foregroundStyle(accent)
                            Text("REBORN")
                                .font(.system(size: 38, weight: .black, design: .rounded))
                                .foregroundStyle(.white)
                            Text("Your community companion")
                                .font(.subheadline)
                                .foregroundStyle(.white.opacity(0.7))
                        }
                        .padding(.top, 20)

                        VStack(alignment: .leading, spacing: 14) {
                            HStack {
                                Label("RECFLARE SERVER", systemImage: "network")
                                    .font(.caption.weight(.bold))
                                    .tracking(1)
                                Spacer()
                                Circle()
                                    .fill(status.isReachable == true ? Color.green : (status.isReachable == false ? Color.orange : Color.gray))
                                    .frame(width: 9, height: 9)
                            }
                            Text(status.message)
                                .font(.title3.weight(.semibold))
                            Text("This checks whether the RecFlare name-server endpoint responds. It does not guarantee that game sessions are available.")
                                .font(.footnote)
                                .foregroundStyle(.white.opacity(0.62))
                            Button {
                                Task { await status.check() }
                            } label: {
                                Label("Check connection", systemImage: "arrow.clockwise")
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(accent)
                        }
                        .padding(18)
                        .background(.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 20))

                        VStack(alignment: .leading, spacing: 12) {
                            Text("QUICK LINKS")
                                .font(.caption.weight(.bold))
                                .tracking(1)
                                .foregroundStyle(accent)
                            LinkCard(title: "RecFlare Website", subtitle: "Visit the project site", icon: "globe", url: URL(string: "https://recflare.net")!)
                            LinkCard(title: "RecFlare GitHub", subtitle: "Source code and updates", icon: "chevron.left.forwardslash.chevron.right", url: URL(string: "https://github.com/recflare")!)
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            Text("ABOUT THIS APP")
                                .font(.caption.weight(.bold))
                                .tracking(1)
                                .foregroundStyle(accent)
                            Text("An unofficial fan-made companion for RecFlare. This app does not contain or launch the Rec Room game, and it is not affiliated with Rec Room Inc.")
                                .font(.footnote)
                                .foregroundStyle(.white.opacity(0.65))
                        }
                        .padding(.bottom, 24)
                    }
                    .padding(.horizontal, 20)
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .task { await status.check() }
        }
    }
}

private struct LinkCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let url: URL

    var body: some View {
        Link(destination: url) {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(Color(red: 0.25, green: 0.68, blue: 1.0))
                    .frame(width: 42, height: 42)
                    .background(.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 12))
                VStack(alignment: .leading, spacing: 3) {
                    Text(title).font(.headline).foregroundStyle(.white)
                    Text(subtitle).font(.caption).foregroundStyle(.white.opacity(0.62))
                }
                Spacer()
                Image(systemName: "arrow.up.right")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.white.opacity(0.55))
            }
            .padding(14)
            .background(.white.opacity(0.07), in: RoundedRectangle(cornerRadius: 16))
        }
    }
}

@MainActor
final class ServerStatus: ObservableObject {
    @Published var isReachable: Bool? = nil
    @Published var message = "Checking server…"

    func check() async {
        message = "Checking server…"
        guard let url = URL(string: "https://ns.recflare.net") else {
            isReachable = false
            message = "Invalid server address"
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 12
        do {
            let (_, response) = try await URLSession.shared.data(for: request)
            guard let http = response as? HTTPURLResponse else {
                isReachable = false
                message = "No valid response"
                return
            }
            isReachable = (200...299).contains(http.statusCode)
            message = isReachable == true ? "Server endpoint reachable" : "Endpoint responded with HTTP \(http.statusCode)"
        } catch {
            isReachable = false
            message = "Could not reach server"
        }
    }
}
