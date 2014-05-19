<?php

class NoteController extends BaseController {

	public function index()
	{
		return View::make('note/index');
	}

	public function create()
	{
        if (Request::isMethod('post'))
        {
            $validation = Validator::make(
                Input::all(),
                array(
                    'name' => 'required',
                    'text' => 'required',
                )
            );
            if ($validation->fails())
            {
                return Redirect::route('create_note')->withErrors($validation);
            }
            $note = new Note(
                array(
                    'name' => Input::get('name'),
                    'text' => Input::get('text')
                )
            );
            $padId = (int)Input::get('pad_id');
            if ($padId) {
                $pad = Auth::user()->pads()->where('id', $padId)->firstOrFail();
                $note->pad_id = $pad->id;
            }
            Auth::user()->notes()->save($note);
            return Redirect::route('all_notes')
                ->with('success', 'Note is created.');
        }
		return View::make('note/create');
	}

    public function edit($id)
    {
        $note = Auth::user()->notes()->where('id', '=', $id)->firstOrFail();
        if (Request::isMethod('post'))
        {
            $validation = Validator::make(
                Input::all(),
                array(
                    'name' => 'required',
                    'text' => 'required',
                )
            );
            if ($validation->fails())
            {
                return Redirect::route('edit_note')->withErrors($validation);
            }
            $note->update(
                array(
                    'name' => Input::get('name'),
                    'text' => Input::get('text')
                )
            );
            $padId = (int)Input::get('pad_id');
            if ($padId) {
                $pad = Auth::user()->pads()->where('id', $padId)->firstOrFail();
                $note->pad_id = $pad->id;
            } else {
                $note->pad_id = null;
            }
            Auth::user()->notes()->save($note);

            return Redirect::route('all_notes')
                ->with('success', 'Note is updated.');
        }
		return View::make('note/edit', array('note' => $note));
    }
}