// Config
Wat.WS = {
    websockets: {},
    debug: 0,
    openWebsocket: function (qvdObj, action, filters, fields, callback) {
        if ("WebSocket" in window) {
            if (Wat.WS.debug) {
                console.info("WebSocket is supported by your Browser!");
            }
            // Let us open a web socket
            var ws = new WebSocket(Wat.C.apiWSUrl + '?sid=' + Wat.C.sid + '&action=' + action + '&filters=' + JSON.stringify(filters) + '&fields=' + JSON.stringify(fields));
            
            ws.onopen = function() {
                // Web Socket is connected, send data using send()
                if (Wat.WS.debug) {
                    console.info("Websocket opened");
                }
            };
            ws.onmessage = function (evt) { 
                var received_msg = evt.data;
                
                if (received_msg != 'AKN') {
                    var received_obj = JSON.parse(received_msg);
                    
                    if (received_obj.rows) {
                        var data = received_obj.rows[0];
                    }
                    else {
                        var data = received_obj;
                    }
                    
                    if (Wat.WS.debug) {
                        console.info("Message is received: ");
                        console.info(action + ' : ' + filters.id + ' : ' + JSON.stringify(data));
                    }
                    
                    $.each(data, function (field, value) {
                        callback(qvdObj, filters.id, field, value);
                    });
                }
                ws.send("AKN");
            };
            
            ws.onclose = function() { 
                // websocket is closed.
                if (Wat.WS.debug) {
                    console.info("Connection is closed...");
                }
            };
            
            if (this.websockets[this.cid] == undefined) {
                this.websockets[this.cid] = [];
            }
            
            this.websockets[this.cid].push(ws);
        }
        else {
            // The browser doesn't support WebSocket
            if (Wat.WS.debug) {
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
        
        delete this.websockets[view];
    },
    
    openStatsWebsockets: function (qvdObj, fields, cid) {
        this.cid = cid;
        var that = this;

        var filters = {
            id: null
        };
        
        $.each(fields, function (iField, field) {
            that.openWebsocket(qvdObj, 'qvd_objects_statistics', filters, field, that.changeWebsocket);
        });
    },
    
    openListWebsockets: function (qvdObj, models, fields, cid) {
        this.closeViewWebsockets(cid);

        var that = this;
                
        $.each(models, function (iModel, model) {
            that.openDetailsWebsockets (qvdObj, model, fields, cid);
        });
    },    
    
    openDetailsWebsockets: function (qvdObj, model, fields, cid) {
        this.cid = cid;
        var that = this;
                
        var filters = {
            id: model.get('id')
        };
        
        that.openWebsocket(qvdObj, qvdObj + '_get_details', filters, fields, that.changeWebsocket);
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