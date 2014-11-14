var standardViews = [
    'User',
    'VM',
    'OSF',
    'DI',
    'Host'
];
   
function viewTest () {
    module( "View tests", {
        setup: function() {
            // prepare something for all following tests
        },
        teardown: function() {
            // clean up after each test
        }
    });

        $.each(standardViews, function (i, view) {        
            test("Load " + view + " list view", function() {    
                // Number of Assertions we Expect     
                expect( 1 );

                Wat.Router.app_router.trigger('route:list' + view);        

                equal(Wat.CurrentView.qvdObj, view.toLowerCase(), view + " view rendered");

                WatTests.listViews[view.toLowerCase()] = _.extend({}, Wat.CurrentView);
            });
        });
}