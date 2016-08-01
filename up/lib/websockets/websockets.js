// Config
Up.WS = {
    websockets: {},
    debug: 0,
    openWebsocket: function (qvdObj, action, params, callback, stream, viewType) {    
        return;
        if ("WebSocket" in window) {
            if (Up.WS.debug) {
                console.info("WebSocket is supported by your Browser!");
            }
            
            var urlParams = Up.U.objToUrl(params);

            try {
                // Let us open a web socket
                var wsURI = Up.C.apiWSUrl + stream + '?action=' + action + urlParams + '&parameters=' + JSON.stringify({source: Up.C.source});
                var ws = new WebSocket(encodeURI(wsURI));

                ws.onopen = function() {
                    // Web Socket is connected, send data using send()
                    if (Up.WS.debug) {
                        console.info("Websocket opened");
                    }
                    ws.send("HI");
                };
                ws.onmessage = function (evt) { 
                    var received_msg = evt.data;

                    if (received_msg != 'AKN') {
                        var data = JSON.parse(received_msg);

                        if (params.filters) {
                            var id = params.filters.id
                        }

                        if (Up.WS.debug) {
                            console.info("Message is received: ");
                            console.info(action + ' : ' + id + ' : ' + JSON.stringify(data));
                        }

                        callback(qvdObj, id, data, ws, viewType);
                    }
                    setTimeout(function () {
                        if (ws.readyState == WS_OPEN) {
                            ws.send("AKN");
                        }
                    }, 500);
                };

                ws.onclose = function() { 
                    // websocket is closed.
                    if (Up.WS.debug) {
                        console.info("Connection is closed...");
                    }
                };

                if (this.websockets[this.cid] == undefined) {
                    this.websockets[this.cid] = [];
                }

                this.websockets[this.cid].push(ws);
                
                if (Up.WS.debug) {
                    if (window.console) {
                        console.info('#WS currently opened: ' + this.websockets[this.cid].length);
                    }
                }
                
            }
            catch (exception) { 
                if (Up.WS.debug) {
                    if (window.console) {
                        console.warn(exception);
                    }
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
    },
    
    openStatsWebsockets: function (qvdObj, fields, cid) {
        this.cid = cid;
        var that = this;
        
        that.openWebsocket(qvdObj, 'qvd_objects_statistics', { 
            fields: fields
        }, that.changeWebsocket, 'ws', 'stats');
    },
    
    openListWebsockets: function (qvdObj, collection, fields, cid) {
        this.closeViewWebsockets(cid);

        var that = this;
                
        // NON-EFFICIENT VERSION: Monitoring elements one per socket
        /*
        $.each(collection.models, function (iModel, model) {
            that.openDetailsWebsockets (qvdObj, model, fields, cid, 'list');
        });
        */
        
        // IMPROVED VERSION 1: Monitoring just the shown elements
        that.cid = cid;
        
        // Build an OR filter with the IDs of all visible elements
        var filters = {
            '-or': []
        };
        $.each(collection.pluck('id'), function (iId, id) {
            filters['-or'].push('id');
            filters['-or'].push(id);
        });
          
		// Add id to required fields to know which register belong wich element in retrieved data
        fields.push('id');
        
        that.openWebsocket(qvdObj, qvdObj + '_get_list', {
            filters: filters, 
            fields: fields
        }, that.changeWebsocket, 'ws', 'list');

        // IMPROVED VERSION 2: Live monitoring where some elements can dissapear from list and appear another ones
        /*
        that.openWebsocket(qvdObj, qvdObj + '_get_list', {
            offset: collection.offset, 
            block: collection.block, 
            filters: collection.filters, 
            order_by: collection.sort, 
            fields: fields
        }, that.changeWebsocket, 'ws', 'list');
        */
    },    
    
    openDetailsWebsockets: function (qvdObj, model, fields, cid, viewType) {
        this.cid = cid;
        var viewType = viewType || 'details';
        var that = this;
                
        var filters = {
            id: model.get('id')
        };
        
        that.openWebsocket(qvdObj, qvdObj + '_get_details', {
            filters: filters, 
            fields: fields
        }, that.changeWebsocket, 'ws', viewType);
    },
    
    changeWebsocket: function (qvdObj, id, data, ws, viewType) { 
        switch (viewType) {
            case 'list':
            case 'details':
                data = data.rows;
                break;
            case 'stats':
                data = [data];
                break;
        }
        
        $.each(data, function (iRow, row) {
            // If view type is a list. Id is taken from retrieved data
            if (viewType == 'list') {
                id = row.id;
                delete row.id;
        }
        
            $.each(row, function (field, value) {
                var paramsChange = {};
                paramsChange[field] = value;
                
                if (viewType == 'details' && Up.CurrentView.model) {
                    var model = Up.CurrentView.model;
                }
                else if (viewType == 'list' && Up.CurrentView.collection) {
                    var model = Up.CurrentView.collection.where({id: id})[0];
                }

                // Update model
                if (model) {
                model.set(paramsChange);
                }

                // Check visibility conditions of the selected items dialog. Usefull when this dialog is opened during websockets changes
                Up.I.checkVisibilityConditions();
                
            switch (qvdObj) {
                case 'vm':
                    Up.WS.changeWebsocketVm(id, field, value, viewType);
                    break;
                case 'user':
                    Up.WS.changeWebsocketUser(id, field, value);
                    break;
                case 'host':
                    Up.WS.changeWebsocketHost(id, field, value);
                    break;
                case 'osf':
                    Up.WS.changeWebsocketOsf(id, field, value);
                    break;
                case 'home':
                    Up.WS.changeWebsocketStats(field, value);
                    break;
            }
        });
        });
    }
}