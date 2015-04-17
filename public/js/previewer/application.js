/* jshint esnext: true */
/* global vg: true, console: true, NProgress: true */
(function() {
    'use strict';

    let vega_options = {
        el: '#vega-container',
        renderer: 'svg'
    };

    /**
     * Sends a message to the socket.
     *
     * @param [WebSocket] socket
     * @param [Object] payload
     */
    let send = function(socket, payload) {
        let message = JSON.stringify(payload);

        socket.send(message);
    };

    /**
     * Connects to the given websocket server and returns a new socket.
     *
     * @param [String] address
     * @return [WebSocket]
     */
    let connect = function(address) {
        let socket = new WebSocket(address);

        socket.onopen = function() {
            console.log(`Connected to ${address}`);

            NProgress.done();
        };

        socket.onerror = function() {
            NProgress.done();
        };

        socket.onmessage = function(event) {
            NProgress.start();

            let payload        = JSON.parse(event.data);
            let input_filename = document.getElementById('filename');

            NProgress.set(0.5);

            // Only update the DOM if the file we're viewing is the one being
            // changed.
            if ( payload.name == input_filename.value ) {
                console.log(`Received update for ${payload.name}`);

                vg.parse.spec(payload.content, function(chart) {
                    chart(vega_options).update();

                    NProgress.done();
                });
            }
        };

        return socket;
    };

    document.addEventListener('DOMContentLoaded', function() {
        var socket; // variable so we can re-assign it upon reconnecting

        NProgress.start();

        let input_server   = document.getElementById('server');
        let input_filename = document.getElementById('filename');

        input_server.value = `ws://${window.location.hostname}:9001`;

        // Reconnect whenever the server address is changed.
        input_server.addEventListener('change', function() {
            NProgress.start();

            console.log(`Reconnecting to ${this.value}`);

            if ( socket ) socket.close();

            socket = connect(this.value);
        });

        // Request the spec whenever we change the file name instead of waiting
        // for any changes.
        input_filename.addEventListener('change', function() {
            if ( socket && this.value !== '' ) {
                send(socket, {name: this.value});
            }
        });

        NProgress.set(0.5);

        socket = connect(input_server.value);
    });
})();
