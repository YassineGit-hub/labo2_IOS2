import UIKit

class WordViewController: UIViewController {
    
    @IBOutlet weak var wordInProgressLabel: UILabel!
    @IBOutlet weak var letterInputField: UITextField!
    @IBOutlet weak var guessedLettersLabel: UILabel!
    @IBOutlet weak var errorCountLabel: UILabel!

    private let jeu = JeuPenduDictionnary()
    var userName: String? // Ajout de la propriété pour accepter le nom d'utilisateur

    override func viewDidLoad() {
        super.viewDidLoad()

        jeu.startNewGame { success in
            if success {
                DispatchQueue.main.async {
                    self.wordInProgressLabel.text = self.jeu.getCurrentState()
                    self.errorCountLabel.text = "Erreurs: \(self.jeu.getErrorsCount())"
                }
            } else {
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "Erreur", message: "Impossible de charger un nouveau mot.", preferredStyle: .alert)
                    let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alert.addAction(OKAction)
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }

    @IBAction func validateBtn(_ sender: Any) {
        guard let res = letterInputField.text, res.count == 1, let character = res.first else { return }
        jeu.guessLetter(character)

        wordInProgressLabel.text = jeu.getCurrentState()
        guessedLettersLabel.text = jeu.getGuessedLetters()  // Update the guessed letters label
        letterInputField.text = ""
        errorCountLabel.text = "Erreurs: \(jeu.getErrorsCount())"

        if jeu.hasGameEnded() {
            let wordToGuess = jeu.getWordToGuess() // Ajoutez cette méthode dans JeuPenduDictionnary si elle n'existe pas
            let message = jeu.getErrorsCount() >= 6 ? "Désolé, vous avez perdu!" : "Félicitations, vous avez gagné!"
            
            // Navigate to ResultViewController
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let resultVC = storyboard.instantiateViewController(withIdentifier: "ResultViewControllerID") as? ResultViewController {
                resultVC.finalMessage = message + "\nMot était: \(wordToGuess)"
                navigationController?.pushViewController(resultVC, animated: true)
            }
        }
    }
    
    func saveScore(score: Int) {
        let gameType = "Dictionnary Word"
        let newScore = Score(name: userName ?? "defaultUser", value: score, gameType: gameType)
        Score.saveScore(newScore)
    }
}
