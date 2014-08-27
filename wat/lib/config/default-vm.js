// Columns configuration on list view
Wat.I.listColumns.vm = [
                {
                    'name': 'checks',
                    'display': true,
                    'fixed': true
                },
                {
                    'name': 'info',
                    'fields': 'block,state,expiration_soft,expiration_hard',
                    'display': true,
                    'fixed': true
                },
                {
                    'name': 'id',
                    'fields': 'id',
                    'display': true,
                    'fixed': true
                },
                {
                    'name': 'name',
                    'fields': 'id,name',
                    'display': true
                },
                {
                    'name': 'node',
                    'fields': 'host_id,host_name',
                    'display': true
                },        
                {
                    'name': 'user',
                    'fields': 'user_id,user_name',
                    'display': true
                },        
                {
                    'name': 'osf',
                    'fields': 'osf_id,osf_name',
                    'display': false
                },         
                {
                    'name': 'osf/tag',
                    'fields': 'osf_id,osf_name,di_tag,di_id',
                    'display': true
                },        
                {
                    'name': 'tag',
                    'fields': 'di_tag',
                    'display': false
                },        
                {
                    'name': 'di_version',
                    'fields': 'di_version',
                    'display': false
                },    
                {
                    'name': 'disk_image',
                    'fields': 'di_name,di_id',
                    'display': false
                },    
                {
                    'name': 'ip',
                    'fields': 'ip',
                    'display': false
                },    
                {
                    'name': 'next_boot_ip',
                    'fields': 'next_boot_ip',
                    'display': false
                },    
                {
                    'name': 'next_boot_ip',
                    'fields': 'next_boot_ip',
                    'display': false
                },    
                {
                    'name': 'serial_port',
                    'fields': 'serial_port',
                    'display': false
                },    
                {
                    'name': 'ssh_port',
                    'fields': 'ssh_port',
                    'display': false
                },    
                {
                    'name': 'vnc_port',
                    'fields': 'vnc_port',
                    'display': false
                },    
                {
                    'name': 'creation_date',
                    'fields': 'creation_date',
                    'display': false
                },    
                {
                    'name': 'creation_admin',
                    'fields': 'creation_admin',
                    'display': false
                }
            ];

// Filters configuration on list view
Wat.I.formFilters.vm = [
                {
                    'name': 'name',
                    'filterField': 'name',
                    'type': 'text',
                    'label': 'Search by name',
                    'mobile': true
                },
                {
                    'name': 'state',
                    'filterField': 'state',
                    'type': 'select',
                    'label': 'State',
                    'class': 'chosen-single',
                    'options': [
                        {
                            'value': -1,
                            'text': 'All',
                            'selected': true
                        },
                        {
                            'value': 'running',
                            'text': 'Running',
                            'selected': false
                        },
                        {
                            'value': 'stopped',
                            'text': 'Stopped',
                            'selected': false
                        }
                                ]
                },
                {
                    'name': 'user',
                    'filterField': 'user_id',
                    'type': 'select',
                    'label': 'User',
                    'class': 'chosen-advanced',
                    'fillable': true,
                    'options': [
                        {
                            'value': -1,
                            'text': 'All',
                            'selected': true
                        }
                                ]
                },
                {
                    'name': 'osf',
                    'filterField': 'osf_id',
                    'type': 'select',
                    'label': 'OS Flavour',
                    'class': 'chosen-advanced',
                    'fillable': true,
                    'options': [
                        {
                            'value': -1,
                            'text': 'All',
                            'selected': true
                        }
                                ]
                },
                {
                    'name': 'host',
                    'filterField': 'host_id',
                    'type': 'select',
                    'label': 'Node',
                    'class': 'chosen-advanced',
                    'fillable': true,
                    'options': [
                        {
                            'value': -1,
                            'text': 'All',
                            'selected': true
                        }
                                ]
                }
            ];