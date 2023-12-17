import SwiftUI

struct ContentView: View {
    @State private var username = ""
    @State private var profileInfo: GitHubProfileInfo?
    @State private var avatarImage: Image?
    @State private var errorMessage: String?

    var body: some View {
        ZStack {
            Color(UIColor.systemBackground)
                .ignoresSafeArea()

            VStack {
                Spacer()
                    .frame(height: 20)

                Text("GitHub Profile Viewer")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)

                if let avatarImage = avatarImage {
                    avatarImage
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 120, height: 120)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.blue, lineWidth: 3))
                        .padding(.vertical, 20)
                }

                TextField("Enter GitHub username", text: $username)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.vertical, 10)
                    .padding(.horizontal, 20)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.blue)

                Button(action: {
                    searchGitHubProfile()
                }) {
                    Text("Search")
                        .foregroundColor(.white)
                        .padding(.vertical, 8)
                        .frame(width: 100)  // Set a fixed width for the button
                        .background(Color.blue)
                        .cornerRadius(15)
                        .shadow(color: .gray, radius: 5, x: 0, y: 2)
                }
                .padding(.vertical, 10)
                .padding(.horizontal, 20)

                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 20)
                        .multilineTextAlignment(.center)
                }

                if let profileInfo = profileInfo {
                    ProfileInfoView(profileInfo: profileInfo)
                        .padding(.vertical, 20)
                        .padding(.horizontal, 20)
                }

                Spacer()
            }
        }
        .onTapGesture {
            hideKeyboard()
        }
    }

    func searchGitHubProfile() {
        guard !username.isEmpty else {
            errorMessage = "Please enter a GitHub username."
            return
        }

        let apiURL = URL(string: "https://api.github.com/users/\(username)")!

        URLSession.shared.dataTask(with: apiURL) { data, response, error in
            DispatchQueue.main.async {
                if let data = data {
                    do {
                        let decoder = JSONDecoder()
                        self.profileInfo = try decoder.decode(GitHubProfileInfo.self, from: data)
                        self.errorMessage = nil
                        self.loadAvatarImage(from: URL(string: self.profileInfo?.avatarURL ?? ""))
                    } catch {
                        self.errorMessage = "Error decoding response."
                        print(error.localizedDescription)
                    }
                } else if let error = error {
                    self.errorMessage = "Error: \(error.localizedDescription)"
                }
            }
        }.resume()
    }

    func loadAvatarImage(from url: URL?) {
        guard let url = url else { return }

        URLSession.shared.dataTask(with: url) { data, _, _ in
            if let data = data, let uiImage = UIImage(data: data) {
                self.avatarImage = Image(uiImage: uiImage)
            }
        }.resume()
    }

    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

struct ProfileInfoView: View {
    var profileInfo: GitHubProfileInfo

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Username: \(profileInfo.login)")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.blue)
            Text("Name: \(profileInfo.name ?? "")")
                .foregroundColor(.blue)
            Text("Bio: \(profileInfo.bio ?? "")")
                .foregroundColor(.blue)
            Text("Public Repositories: \(profileInfo.publicRepos)")
                .foregroundColor(.blue)
            Text("Followers: \(profileInfo.followers)")
                .foregroundColor(.blue)
            Text("Following: \(profileInfo.following)")
                .foregroundColor(.blue)
            Text("GitHub URL:")
                .foregroundColor(.blue)
                .onTapGesture {
                    openURL(profileInfo.htmlURL)
                }
        }
        .foregroundColor(Color(UIColor.label))
    }

    private func openURL(_ url: String) {
        guard let url = URL(string: url) else { return }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
}

struct GitHubProfileInfo: Decodable {
    let login: String
    let name: String?
    let bio: String?
    let publicRepos: Int
    let followers: Int
    let following: Int
    let htmlURL: String
    let avatarURL: String

    enum CodingKeys: String, CodingKey {
        case login, name, bio
        case publicRepos = "public_repos"
        case followers, following
        case htmlURL = "html_url"
        case avatarURL = "avatar_url"
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


    @main
    struct GitHubProfileApp: App {
        var body: some Scene {
            WindowGroup {
                ContentView()
            }
        }
    }

