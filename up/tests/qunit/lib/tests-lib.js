function getRandomInt () {
    return _.random(1, 255);
}

function getRandomStr () {
    return Math.random().toString(36).substring(7);
}

function performUpdation (values, updateValues) {
    $.each(updateValues, function (fieldName, fieldValue) {
        if (fieldName == '__properties_changes__') {
            /*
            $.each(fieldValue.delete, function (i, propertyName) {
                delete values['__properties__'][propertyName];
            });
            */
            
            $.each(fieldValue.set, function (propertyName, propertyValue) {
                values['__properties__'][propertyName] = propertyValue;
            });
        }
        else if (fieldName == '__tags_changes__') {
            values['__tags__'] = _.difference(values['__tags__'], fieldValue.delete);
            
            values['__tags__'] = _.union(values['__tags__'], fieldValue.create);
        }
        else if (fieldName == '__roles_changes__') {
            values['roles'] = _.difference(values['roles'], fieldValue.unassign_roles);
            
            values['roles'] = _.union(values['roles'], fieldValue.assign_roles);
        }
        else if (fieldName == '__acls_changes__') {
            if (values['acls'] != undefined) {
                values['acls'] = {
                    "negative": [],
                    "positive": []
                };
            }
            
            if (fieldValue.assign_acls != undefined) {
                values['acls']['negative'] = _.union(values['acls']['negative'], fieldValue.unassign_acls);
            }
            
            if (fieldValue.assign_acls != undefined) {
                values['acls']['positive'] = _.union(values['acls']['positive'], fieldValue.assign_acls);
            }
        }
        else {
            values[fieldName] = fieldValue;
        }
    });
}

function convertPropsToExpected (props, qvdObj) {
    var propsExpected = {};
    $.each(props, function (propertyId, propertyValue) {
        var propertyName = propertyNames[qvdObj][propertyId];
        var propertyListId = propertyListIDs[propertyName];
        
        propsExpected[propertyListId] = {
            "key": propertyName,
            "tenant_id": 1,
            "value": propertyValue
        }
    });
    
    return propsExpected;
}
