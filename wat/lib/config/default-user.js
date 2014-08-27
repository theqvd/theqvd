// Columns configuration on list view
Wat.I.listColumns.user = [
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
                    'name': 'started_vms',
                    'display': true
                },
                {
                    'name': 'world',
                    'display': true,
                    'noTranslatable': true
                },
                {
                    'name': 'sex',
                    'display': true,
                    'noTranslatable': true
                }
            ];

// Filters configuration on list view
Wat.I.formFilters.user = [
                {
                    'name': 'name',
                    'filterField': 'name',
                    'type': 'text',
                    'label': 'Search by name',
                    'mobile': true
                },     
                {
                    'name': 'world',
                    'filterField': 'world',
                    'type': 'text',
                    'label': 'world',
                    'noTranslatable': true
                },     
                {
                    'name': 'sex',
                    'filterField': 'sex',
                    'type': 'text',
                    'label': 'sex',
                    'noTranslatable': true
                }
            ];