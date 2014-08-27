// Columns configuration on list view
Wat.I.listColumns.node = [
                {
                    'name': 'checks',
                    'display': true
                },
                {
                    'name': 'info',
                    'display': true
                },
                {
                    'name': 'id',
                    'display': true
                },
                {
                    'name': 'name',
                    'display': true
                },
                {
                    'name': 'state',
                    'display': false
                },
                {
                    'name': 'address',
                    'display': true
                },
                {
                    'name': 'vms_connected',
                    'display': true
                },
                {
                    'name': 'Cosa',
                    'display': true
                }
            ];

// Filters configuration on list view
Wat.I.formFilters.node = [
                {
                    'name': 'name',
                    'filterField': 'name',
                    'type': 'text',
                    'label': 'Search by name',
                    'mobile': true
                },
                {
                    'name': 'vm',
                    'filterField': 'vm_id',
                    'type': 'select',
                    'label': 'Virtual machine',
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