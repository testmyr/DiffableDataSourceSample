//
//  MessagesVC.swift
//  DiffableDataSourceSample
//
//  Created by sdk on 23.01.2024.
//

import UIKit

protocol RoundedBgCollectionViewCell: UICollectionViewCell {
    func setRounded()
    func setText(_ text: String)
}

enum Section {
    case main
}

class MessagesVC: UIViewController {
    var messages: [MessageItem] = {
        var data_: [String] = ["Label dsfdsf fdsfdsf \n Sdfdsfdf \n Dsfdsfdsfdsf", "dsfdsfdfd", "dsfdsfh jkdhs fksdjh f"]
        for _ in 0...20 {
            var str = String()
            var definition: [String] = []
            for _ in 0...Int.random(in: 1...40) {
                let wordLength = Int.random(in: 1...10)
                definition.append(String(Array<Character>(repeating: "A", count: wordLength)))
            }
            data_.append(definition.joined(separator: " "))
        }
        return data_.map { MessageItem(owner: Bool.random() ? .own : .generated, text: $0) }
    }()
    
    @IBOutlet weak var txtFldMessage: UITextField!
    @IBOutlet private weak var cnstrStckVwBottom: NSLayoutConstraint!
    @IBOutlet private weak var clVwMessages: UICollectionView!
    
    private var keyboardHeight = CGFloat(0)
    private var isKeyboardShown = false
    
    private lazy var dataSource = configureDataSource()
    typealias DataSource = UICollectionViewDiffableDataSource<Section, MessageItem>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, MessageItem>
    
    override func viewDidLoad() {
        super.viewDidLoad()
        clVwMessages.backgroundColor = .gray
        clVwMessages.transform = CGAffineTransform(scaleX: 1, y: -1)
        clVwMessages.collectionViewLayout = createLayout()
        clVwMessages.dataSource = dataSource
        applySnapshot()
        clVwMessages.delegate = self
        txtFldMessage.addTarget(self, action: #selector(sendMessage), for: .editingDidEndOnExit)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardRect = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let keyBoardFrame = self.view.convert(keyboardRect, from: nil)
            keyboardHeight = keyBoardFrame.size.height
            raiseСontentUpByKeyboardHeight()
        }
    }
    @objc func keyboardWillHide(notification: NSNotification) {
        lowerСontentByKeyboardHeight()
    }
    
    @objc func sendMessage() {
        if let messageText = txtFldMessage.text {
            addMessage(MessageItem(owner: .own, text: messageText))
            txtFldMessage.text = nil
            Task.detached(priority: .userInitiated) {
                sleep(3)
                await self.addMessage(MessageItem(owner: .generated, text: String(messageText.reversed())))
            }
        }
    }
    private func addMessage(_ message: MessageItem) {
        messages.append(message)
        applySnapshot(animatingDifferences: true)
    }
    
    private func configureDataSource() -> UICollectionViewDiffableDataSource<Section, MessageItem> {
        let cellMessageOriginNib = UINib(nibName: "MessageOriginCollectionViewCell", bundle: nil)
        let cellMessageOriginRegistration = UICollectionView.CellRegistration(cellNib: cellMessageOriginNib.self) { (cell, indexPath, item: MessageItem) in
            (cell as? MessageOriginCollectionViewCell)?.setText(item.text)
        }
        let cellMessageRevertedNib = UINib(nibName: "MessageReversedCollectionViewCell", bundle: nil)
        let cellMessageRevertedRegistration = UICollectionView.CellRegistration(cellNib: cellMessageRevertedNib) { (cell, indexPath, item: MessageItem) in
            (cell as? MessageReversedCollectionViewCell)?.setText(item.text)
        }
        return UICollectionViewDiffableDataSource<Section, MessageItem>(collectionView: self.clVwMessages) { collectionView, indexPath, item in
            let cell = collectionView.dequeueConfiguredReusableCell(using: item.owner.isOwn ? cellMessageOriginRegistration : cellMessageRevertedRegistration, for: indexPath, item: item)
            (cell as? RoundedBgCollectionViewCell)?.setText(item.text)
            DispatchQueue.main.async {
                cell.setNeedsLayout()
            }
            return cell
        }
    }
    private func applySnapshot(animatingDifferences: Bool = true) {
        var snapshot = Snapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems(messages.reversed(), toSection: .main)
        dataSource.apply(snapshot, animatingDifferences: animatingDifferences)
    }
    
    private func createLayout() -> UICollectionViewCompositionalLayout {
        let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(10)))
        //item.contentInsets = NSDirectionalEdgeInsets(top: 20, leading: 5, bottom: 0, trailing: 5)
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(10)), repeatingSubitem: item, count: 1)
        //group.contentInsets = NSDirectionalEdgeInsets(top: 20, leading: 5, bottom: 100, trailing: 5)
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
        section.interGroupSpacing = 10
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    private func raiseСontentUpByKeyboardHeight() {
        UIView.animate(withDuration: 0.5, animations: {
            self.cnstrStckVwBottom.constant = self.keyboardHeight
            self.view.layoutIfNeeded()
        }) { completed in
            self.isKeyboardShown = true
        }
    }
    private func lowerСontentByKeyboardHeight() {
        if self.cnstrStckVwBottom.constant != 0 {
            self.isKeyboardShown = false
            UIView.animate(withDuration: 0.5, animations: {
                self.cnstrStckVwBottom.constant = 0
                self.view.layoutIfNeeded()
            })
        }
    }
}


extension MessagesVC: UICollectionViewDelegate {
    // hide keyboard after the scrolling down
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if isKeyboardShown && scrollView.panGestureRecognizer.translation(in: scrollView.superview).y > 0 {
            print(scrollView.panGestureRecognizer.translation(in: scrollView.superview).y)
            self.view.endEditing(true)
            lowerСontentByKeyboardHeight()
        }
    }
}
