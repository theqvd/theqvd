// Columns configuration on list view
Wat.I.listColumns.di = [
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
                    'name': 'disk_image',
                    'display': true
                },
                {
                    'name': 'version',
                    'display': true
                },
                {
                    'name': 'osf',
                    'display': false
                },
                {
                    'name': 'default',
                    'display': true
                }
            ];

// Filters configuration on list view
Wat.I.formFilters.di = [
                {
                    'name': 'name',
                    'filterField': 'disk_image',
                    'type': 'text',
                    'label': 'Search by disk image',
                    'mobile': true
                },
                {
                    'name': 'osf',
                    'filterField': 'osf_id',
                    'type': 'select',
                    'label': 'OS Flavour',
                    'class': 'chosen-advanced',
                    'fillable': true,
                    'mobile': true
                }
            ];