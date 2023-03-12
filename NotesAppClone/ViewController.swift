//
//  ViewController.swift
//  NotesAppClone
//
//  Created by Emir Arıkan on 12.03.2023.
//

import UIKit

class ViewController: UITableViewController {
    var notes = [Note]()
    let defaults = UserDefaults.standard
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Welcome Notes!"
        
        loadNotes()
        
        navigationController?.isToolbarHidden = false
        
        let addNote = UIBarButtonItem(image: UIImage(systemName: "square.and.pencil"), style: .done, target: self, action: #selector(addNote))
        
        addNote.tintColor = UIColor.systemOrange
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        toolbarItems = [spacer,addNote]
        self.refreshControl?.addTarget(self, action: #selector(refresh), for: UIControl.Event.valueChanged)

        
    }
    override func viewWillAppear(_ animated: Bool) {
        self.loadNotes()
        self.tableView.reloadData()
    }

    @objc func addNote(){
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "NoteDetail") as? NoteDetailViewController else { return }
        vc.notes = notes
        navigationController?.pushViewController(vc, animated: true)
    }
    func loadNotes(){
        if let savedData = defaults.object(forKey: "notes") as? Data{
            let jsonDecoder = JSONDecoder()
            do{
                notes = try jsonDecoder.decode([Note].self, from: savedData)
                self.notes.sort { note1, note2 in
                    note1.id < note2.id
                }
            }catch{
                print("Failed to load Notes")
                
            }
        }
    }
    @objc func refresh(sender:AnyObject){
        loadNotes()
        self.tableView.reloadData()
        self.refreshControl?.endRefreshing()
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Note" , for:indexPath)
        cell.textLabel?.text = notes[indexPath.row].title
        var noteDetail = ""
        if notes[indexPath.row].detail.split(separator: "\n").count >= 2 {
            noteDetail = notes[indexPath.row].detail.split(separator: "\n")[1].description
        }
        cell.detailTextLabel?.text = noteDetail
        return cell
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        notes.count
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "NoteDetail") as? NoteDetailViewController else { return }
        
        vc.noteTitle = notes[indexPath.row].title
        vc.noteDetail = notes[indexPath.row].detail
        vc.noteId = notes[indexPath.row].id
        vc.notes = notes
        navigationController?.pushViewController(vc, animated: true)
    }
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            notes.remove(at: indexPath.row)
            DispatchQueue.global(qos: .background).async {
                self.save()
                self.loadNotes()
            }
            self.tableView.reloadData()
        }
    }
    func save(){
        let jsonEncoder = JSONEncoder()
        if let savedData = try? jsonEncoder.encode(notes){
            defaults.set(savedData, forKey: "notes")
        }
        else{
            print("fail")
        }
    }
}
