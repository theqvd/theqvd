// Config
Up.WS = {
    websockets: {},
    debug: 0,
    openWebsocket: function (stream, callback) {    
        if ("WebSocket" in window) {
            if (Up.WS.debug) {
                console.info("WebSocket is supported by your Browser!");
            }
            
            try {
                // Let us open a web socket
                var wsURI = Up.C.apiWSUrl + stream;
                var ws = new WebSocket(encodeURI(wsURI));

                ws.onopen = function() {
                    // Web Socket is connected, send data using send()
                    if (Up.WS.debug) {
                        console.info("Websocket opened");
                    }
                };
                ws.onmessage = function (evt) { 
                    var received_msg = evt.data;
                    
                    var data = JSON.parse(received_msg);

                    if (Up.WS.debug) {
                        console.info("Message is received: ");
                        console.info(stream + ' : ' + JSON.stringify(data));
                    }

                    callback(data);
                };

                ws.onclose = function() { 
                    // websocket is closed.
                    if (Up.WS.debug) {
                        console.info("Connection is closed...");
                    }
                };

                if (this.websockets[Up.CurrentView.cid] == undefined) {
                    this.websockets[Up.CurrentView.cid] = [];
                }
                
                // Store websocket on opened websockets list
                this.websockets[Up.CurrentView.cid].push(ws);
                
                if (Up.WS.debug) {
                    console.info('#WS currently opened: ' + this.websockets[Up.CurrentView.cid].length);
                }
                
            }
            catch (exception) { 
                if (Up.WS.debug) {
                    console.warn(exception);
                }
            }
        }
        else {
            // The browser doesn't support WebSocket
            if (Up.WS.debug) {
                console.error("WebSocket NOT supported by your Browser!");
            } 
        }
    },
    
    closeAllWebsockets: function () {
        var that = this;
        $.each(this.websockets, function (view) {
            that.closeViewWebsockets(view);
        });
    },
    
    closeViewWebsockets: function (view) {        
        if (this.websockets[view] == undefined) {
            return;
        }
        
        $.each(this.websockets[view], function (iWs, ws) {
            var closeTry = setInterval(function () {
                if (ws.readyState == WS_OPEN) {
                    ws.close();
                    clearInterval(closeTry);
                }
                else {
                    if (Up.WS.debug) {
                        console.error('Trying close connecting ws');
                    }
                }
            }, 1000);
        });
        
        delete this.websockets[view];
    }
}