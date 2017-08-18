import UIKit

class MovieTableViewController : UITableViewController {
    
    var movies:Array<Movie> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Top movies"
        
        let url = URL.init(string: "https://api.themoviedb.org/3/discover/movie?sort_by=popularity.desc&api_key=b827e898d3169afcf35ddca35ccd394c")
        let sessionTask = URLSession.shared.dataTask(with: url!, completionHandler: {(data, response, error) in
            guard let httpResponse = response as? HTTPURLResponse else {
                print("bad response!")
                return;
            }
            
            switch httpResponse.statusCode {
            case 200:
                guard let json = try? JSONSerialization.jsonObject(with: data!) as! [String:Any] else {
                    print("bad json!")
                    return
                }
                
                let results = json["results"] as! NSArray
                
                for case let movieJSON as [String:Any] in results {
                    let posterPath = movieJSON["poster_path"] as! String
                    
                    let movie = Movie(
                        title: movieJSON["title"] as! String,
                        description: movieJSON["overview"] as! String,
                        posterURL: URL.init(string: "https://image.tmdb.org/t/p/w500\(posterPath)?api_key=b827e898d3169afcf35ddca35ccd394c")!
                    )
                    self.movies.append(movie)
                }
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                return
            default:
                print("not 200!")
            }
        })
        
        sessionTask.resume()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.movies.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let movie = self.movies[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell") as! MovieTableViewCell
        cell.titleLabel.text = movie.title
        cell.descriptionLabel.text = movie.description
        cell.posterURL = movie.posterURL
        
        cell.posterImageView.image = nil
        
        downloadImageURL(downloadURL: movie.posterURL, ForCell: cell)
        
        return cell
    }
    
    func downloadImageURL(downloadURL: URL?, ForCell cell: MovieTableViewCell?) {
        let urlRequest = URLRequest(url: downloadURL!, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 30)
        
        
        let sessionTask = URLSession.shared.dataTask(with: urlRequest, completionHandler: { (data, response, error) in
            guard let httpResponse = response as? HTTPURLResponse else {
                print("bad response!")
                return;
            }
            
            switch httpResponse.statusCode {
            case 200:
                if downloadURL == cell?.posterURL {
                    let image = UIImage.init(data: data!)
                
                    DispatchQueue.main.async {
                        cell?.imageView?.image = image
                    }
                }
            default:
                print("not 200!")
            }
        })
        
        sessionTask.resume()
    }
}
