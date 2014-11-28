// Config
Wat.WS = {
    websockets: [],
    debug: false,
    openWebsocket: function (qvdObj, action, filters, field, callback) {
        if ("WebSocket" in window) {
            if (Wat.WS.debug) {
                console.info("WebSocket is supported by your Browser!");
            }
            // Let us open a web socket
            var ws = new WebSocket(Wat.C.apiWSUrl + '?sid=' + Wat.C.sid + '&action=' + action + '&filters=' + JSON.stringify(filters) + '&fields=' + JSON.stringify([field]));
            
            ws.onopen = function() {
                // Web Socket is connected, send data using send()
                if (Wat.WS.debug) {
                    console.info("Websocket opened");
                }
            };
            ws.onmessage = function (evt) { 
                var received_msg = evt.data;
                
                if (received_msg != 'ACK') {
                    var received_obj = JSON.parse(received_msg);
                    if (received_obj.rows) {
                        var data = received_obj.rows[0][field];
                    }
                    else {
                        var data = received_obj[field];
                    }
                    
                    if (Wat.WS.debug) {
                        console.info("Message is received: ");
                        console.info(action + ' : ' + filters.id + ' : ' + field + ' : ' + data);
                    }
                    callback(qvdObj, filters.id, field, data);
                }
                ws.send("ACK");
            };
            ws.onclose = function() { 
                // websocket is closed.
                if (Wat.WS.debug) {
                    console.info("Connection is closed...");
                }
            };
            
            this.websockets.push(ws);
        }
        else {
            // The browser doesn't support WebSocket
            if (Wat.WS.debug) {
                console.error("WebSocket NOT supported by your Browser!");
            }
        }
    },
    
    closeAllWebsockets: function () {
        $.each(this.websockets, function (iWs, ws) {
            var closeTry = setInterval(function () {
                if (ws.readyState != 0) {
                    ws.close();
                    clearInterval(closeTry);
                }
                else {
                    if (Wat.WS.debug) {
                        console.error('Trying close connecting ws');
                    }
                }
            }, 1000);
        });
    },
    
    openStatsWebsockets: function (qvdObj, fields) {
        var that = this;

        var filters = {
            id: null
        };
        
        $.each(fields, function (iField, field) {
            that.openWebsocket(qvdObj, 'qvd_objects_statistics', filters, field, that.changeWebsocket);
        });
    },
    
    openListWebsockets: function (qvdObj, models, fields) {
        var that = this;
                
        $.each(models, function (iModel, model) {
            that.openDetailsWebsockets (qvdObj, model, fields);
        });
    },    
    
    openDetailsWebsockets: function (qvdObj, model, fields) {
        var that = this;
                
        var filters = {
            id: model.get('id')
        };

        $.each(fields, function (iField, field) {
            that.openWebsocket(qvdObj, qvdObj + '_get_details', filters, field, that.changeWebsocket);
        });
    },
    
    changeWebsocket: function (qvdObj, id, field, data) {          
        switch (qvdObj) {
            case 'vm':
                Wat.WS.changeWebsocketVm(id, field, data);
                break;
            case 'user':
                Wat.WS.changeWebsocketUser(id, field, data);
                break;
            case 'host':
                Wat.WS.changeWebsocketHost(id, field, data);
                break;
            case 'osf':
                Wat.WS.changeWebsocketOsf(id, field, data);
                break;
            case 'home':
                Wat.WS.changeWebsocketStats(field, data);
                break;
        }
    }
}