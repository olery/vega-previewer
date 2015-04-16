# Vega Previewer

Vega Previewer is a small Javascript and Ruby application that allows one to
preview a [Vega][vega] chart and have it reloaded automatically every time the
underlying JSON specification is updated. This setup allows one to write a JSON
specification using their favourite editor, instead of being forced to write it
in a browser. The previewer uses websockets to receive file changes in
real-time. The websockets server is powered by Ruby.

A short demo can be seen here:
<http://downloads.yorickpeterse.com/files/vega_editor.webm>.

## Requirements

* Ruby 2.0 or newer
* A browser supporting ECMAScript 6 and websockets
* An editor to edit JSON files

## Usage

First install all the required Gems:

    bundle install

Start the servers:

    foreman start

Now point your browser to <http://localhost:9000> and you're good to go.

JSON files can be placed in the `./vega` directory (its contents are ignored by
Git). Any changes made to these JSON files are published to the connected
websocket clients.

## License

All source code in this repository is licensed under the MIT license unless
specified otherwise. A copy of this license can be found in the file "LICENSE"
in the root directory of this repository.

[vega]: http://trifacta.github.io/vega/
