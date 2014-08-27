// Columns configuration on list view
Wat.I.listColumns.osf = [
                {
                    'name': 'checks',
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
                    'name': 'overlay',
                    'display': true
                },
                {
                    'name': 'memory',
                    'display': true
                },
                {
                    'name': 'user_storage',
                    'display': true
                },
                {
                    'name': 'dis',
                    'display': true
                },
                {
                    'name': 'vms',
                    'display': true
                }
            ];

// Filters configuration on list view
Wat.I.formFilters.osf = [
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
                },
                {
                    'name': 'di',
                    'filterField': 'di_id',
                    'type': 'select',
                    'label': 'Disk image',
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