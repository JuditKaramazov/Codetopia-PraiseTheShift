import Foundation

enum GithubAPI {
	static let repoFullName = "JuditKaramazov/Codetopia-PraiseTheShift"

	/// Base API endpoint for PraiseTheShift's GitHub repository.
	static let repoApiUrl = URL(string: "https://api.github.com/repos/\(repoFullName)/")!

	static func getLatestRelease(completion: @escaping (Result<Release, Error>) -> Void) {
		let endpoint = repoApiUrl.appendingPathComponent("releases/latest")
		let request = URLRequest(url: endpoint, cachePolicy: .reloadIgnoringLocalCacheData)

		URLSession.shared.dataTask(with: request) { (data, res, err) in
			if let error = err {
				completion(.failure(error))
				return
			}

			if let data = data {
				do {
					let decoder = JSONDecoder()
					let decoded = try decoder.decode(Release.self, from: data)
					completion(.success(decoded))
				} catch {
					completion(.failure(error))
				}
			}
		}.resume()
	}
}
