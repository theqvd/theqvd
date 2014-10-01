function getRandomInt () {
    return _.random(1, 255);
}

function getRandomStr () {
    return Math.random().toString(36).substring(7);
}

function performUpdation (values, updateValues) {
    $.each(updateValues, function (fieldName, fieldValue) {
        if (fieldName != '__properties_changes__') {
            values[fieldName] = fieldValue;
        }
        else {
            $.each(fieldValue.delete, function (i, propertyName) {
                delete values['__properties__'][propertyName];
            });
            
            $.each(fieldValue.set, function (propertyName, propertyValue) {
                values['__properties__'][propertyName] = propertyValue;
            });
        }
    });
}
