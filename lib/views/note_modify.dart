import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:notes_api/models/note.dart';
import 'package:notes_api/services/notes_service.dart';
import 'package:notes_api/models/note_manipulation.dart';

class NoteModify extends StatefulWidget {
  final String noteID;
  NoteModify({this.noteID});

  @override
  _NoteModifyState createState() => _NoteModifyState();
}

class _NoteModifyState extends State<NoteModify> {
  bool get isEditing => widget.noteID != null;

  NotesService get notesService => GetIt.instance<NotesService>();

  String errorMessage;
  Note note;
  TextEditingController _titleController = TextEditingController();
  TextEditingController _contentController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    if (isEditing) {
      setState(() {
        _isLoading = true;
      });

      notesService.getNote(widget.noteID).then((response) {
        setState(() {
          _isLoading = false;
        });
        if (response.error) {
          errorMessage = response.errorMessage ?? 'An error occured';
        }
        note = response.data;
        _titleController.text = note.noteTitle;
        _contentController.text = note.noteContent;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit note' : 'Create note'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  TextField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      hintText: 'Note title',
                    ),
                  ),
                  SizedBox(height: 8),
                  TextField(
                    controller: _contentController,
                    decoration: InputDecoration(
                      hintText: 'Note content',
                    ),
                  ),
                  SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 35,
                    child: RaisedButton(
                      onPressed: () async {
                        if (isEditing) {
                          setState(() {
                            _isLoading = true;
                          });
                          final note = NoteManipulation(
                            noteTitle: _titleController.text,
                            noteContent: _contentController.text,
                          );
                          final result = await notesService.updateNote(
                              widget.noteID, note);
                          setState(() {
                            _isLoading = false;
                          });
                          final title = 'Done!';
                          final text = result.error
                              ? (result.errorMessage ?? 'An error occured')
                              : 'Your note was updated';

                          showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: Text(title),
                              content: Text(text),
                              actions: [
                                FlatButton(
                                  child: Text('Ok'),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            ),
                          ).then((data) {
                            if (result.data) Navigator.of(context).pop();
                          });
                          //update note in API
                        } else {
                          setState(() {
                            _isLoading = true;
                          });
                          final note = NoteManipulation(
                            noteTitle: _titleController.text,
                            noteContent: _contentController.text,
                          );
                          final result = await notesService.createNote(note);
                          setState(() {
                            _isLoading = false;
                          });
                          final title = 'Done!';
                          final text = result.error
                              ? (result.errorMessage ?? 'An error occured')
                              : 'New note was saved';

                          showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: Text(title),
                              content: Text(text),
                              actions: [
                                FlatButton(
                                  child: Text('Ok'),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            ),
                          ).then((data) {
                            if (result.data) Navigator.of(context).pop();
                          });
                        }
                      },
                      child: Text(
                        'Save',
                        style: TextStyle(color: Colors.white),
                      ),
                      color: Theme.of(context).primaryColor,
                    ),
                  )
                ],
              ),
      ),
    );
  }
}
